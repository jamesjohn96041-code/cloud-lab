FROM nginx:alpine

# envsubst lives in gettext
RUN apk add --no-cache gettext

COPY nginx.conf.template /etc/nginx/templates/nginx.conf.template
COPY entrypoint.sh /entrypoint.sh
COPY index.html /usr/share/nginx/html/index.html

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
