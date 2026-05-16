# =========================
# Build Stage
# =========================
FROM node:18 AS builder

# Create app directory
RUN mkdir -p /usr/src/app

WORKDIR /usr/src/app

# Add local node binaries to PATH
ENV PATH=/usr/src/app/node_modules/.bin:$PATH

# Copy package files
COPY package.json /usr/src/app/package.json

# Optional: only if your environment has SSL issues
RUN npm config set strict-ssl false

# Install dependencies
RUN npm install --legacy-peer-deps

# Copy source code
COPY . /usr/src/app

# Build React application
RUN npm run build


# =========================
# Production Stage
# =========================
FROM nginx:alpine

# Create non-root group and user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Copy build files from builder stage
COPY --from=builder /usr/src/app/build /usr/share/nginx/html

# Change ownership of nginx html directory
RUN chown -R appuser:appgroup /usr/share/nginx/html

# Change nginx to listen on non-privileged port 8080
RUN sed -i 's/listen 80;/listen 8080;/g' /etc/nginx/conf.d/default.conf

# Switch to non-root user
USER appuser

# Expose application port
EXPOSE 8080

# Healthcheck
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
CMD wget --spider http://localhost:8080 || exit 1

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
