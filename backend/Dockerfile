# ── Build stage ──────────────────────────────────────────────────────────────
FROM node:20-alpine AS builder

WORKDIR /app

# Copy manifests first for better layer caching
COPY package*.json ./
RUN npm ci --omit=dev

# ── Runtime stage ─────────────────────────────────────────────────────────────
FROM node:20-alpine AS runtime

# Create non-root user for security
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

# Copy installed production modules and source
COPY --from=builder /app/node_modules ./node_modules
COPY src ./src

# Set ownership
RUN chown -R appuser:appgroup /app

USER appuser

# Expose the application port (overridable via ENV)
ENV PORT=3000 \
    HOST=0.0.0.0 \
    LOG_LEVEL=info \
    CACHE_TTL_MINUTES=45 \
    NODE_ENV=production

EXPOSE 3000

# Health check (uses the /api/health endpoint)
HEALTHCHECK --interval=30s --timeout=10s --start-period=15s --retries=3 \
  CMD wget -qO- http://127.0.0.1:3000/api/health || exit 1

CMD ["node", "src/server.js"]
