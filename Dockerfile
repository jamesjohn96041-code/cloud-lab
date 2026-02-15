# Use lightweight Python image
FROM python:3.12-alpine

# Set working directory inside container
WORKDIR /app

# Copy requirements first (to leverage caching)
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Expose port
EXPOSE 5000

# Start the app
CMD ["python", "app.py"]
