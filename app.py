import os
import time
import psycopg2
from flask import Flask, jsonify

app = Flask(__name__)

def connect_with_retry():
    dsn = os.getenv("DATABASE_URL")

    for i in range(30):  # retry ~30 seconds
        try:
            if dsn:
                return psycopg2.connect(dsn)
            else:
                return psycopg2.connect(
                    host=os.getenv("POSTGRES_HOST", "db"),
                    port=int(os.getenv("POSTGRES_PORT", "5432")),
                    dbname=os.getenv("POSTGRES_DB"),
                    user=os.getenv("POSTGRES_USER"),
                    password=os.getenv("POSTGRES_PASSWORD"),
                )
        except Exception as e:
            print(f"DB not ready, retrying... {i}")
            time.sleep(1)

    raise Exception("Database connection failed after retries")

conn = connect_with_retry()

@app.get("/health")
def health():
    return {"status": "ok"}, 200

@app.get("/data")
def data():
    cur = conn.cursor()
    cur.execute("SELECT version();")
    version = cur.fetchone()
    cur.close()
    return f"Connected to PostgreSQL! Version: {version}"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
