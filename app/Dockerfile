# Stage 1: Build & Install Production Dependencies
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

# Stage 2: Production Hardened Container Runner
FROM node:20-alpine AS runner
LABEL maintainer="DevOps Team <devops@octabyte.ai>"
LABEL description="Production microservice container for OctaByte DevOps Assignment"

WORKDIR /app

# Security: Create non-root user and group
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001 -G nodejs

# Copy artifacts from builder stage
COPY --from=builder /app/node_modules ./node_modules
COPY package*.json ./
COPY src ./src

# Set ownership to non-root user
RUN chown -R nodejs:nodejs /app

USER nodejs

EXPOSE 3000

ENV NODE_ENV=production
ENV PORT=3000

# Container Liveness & Readiness Healthcheck
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1

CMD ["node", "src/index.js"]
