# Stage 1: Runtime only — Nginx
FROM nginx:alpine

# Install gzip support
RUN apk add --no-cache gzip

# Copy custom nginx config
COPY server/nginx.conf /etc/nginx/nginx.conf

# Copy Flutter Web build from GitHub Actions pipeline
COPY build/web /usr/share/nginx/html

# Expose port
EXPOSE 80

# Re-gzip assets to ensure correct compression
CMD gzip -k -r -f /usr/share/nginx/html/ && nginx -g 'daemon off;'
