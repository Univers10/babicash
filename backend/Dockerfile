# ── Build stage ────────────────────────────────────────────────────────────────
FROM python:3.13-slim AS builder

WORKDIR /app

# Install system deps for asyncpg build
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc libpq-dev && \
    rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# ── Runtime stage ──────────────────────────────────────────────────────────────
FROM python:3.13-slim

WORKDIR /app

# Runtime deps only
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq5 curl && \
    rm -rf /var/lib/apt/lists/*

# Copy installed packages from builder
COPY --from=builder /install /usr/local

# Create non-root user
RUN groupadd -r babicash && useradd -r -g babicash -d /app -s /sbin/nologin babicash

# Copy application code
COPY alembic.ini .
COPY alembic/ alembic/
COPY app/ app/
COPY templates/ templates/
COPY static/ static/
COPY scripts/ scripts/

# Entrypoint script
COPY entrypoint.sh .
RUN chmod +x entrypoint.sh

# Fix ownership for non-root user
RUN chown -R babicash:babicash /app

USER babicash

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

ENTRYPOINT ["./entrypoint.sh"]
