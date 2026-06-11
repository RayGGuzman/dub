# Build stage
FROM node:20-alpine AS builder

# Install pnpm
RUN npm install -g pnpm@9.15.9

WORKDIR /app

# Copy workspace configuration and root config files
COPY pnpm-workspace.yaml pnpm-lock.yaml package.json turbo.json ./
COPY .npmrc* ./
COPY prettier.config.js ./
COPY packages ./packages
COPY apps ./apps

# Install dependencies
RUN pnpm install --frozen-lockfile

# Build packages and app
RUN pnpm build

# Runtime stage
FROM node:20-alpine

# Install pnpm
RUN npm install -g pnpm@9.15.9

WORKDIR /app

# Copy from builder
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/packages ./packages
COPY --from=builder /app/apps ./apps

# Set environment to production
ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1

# Expose port
EXPOSE 3000

# Start the web app
WORKDIR /app/apps/web
CMD ["node_modules/.bin/next", "start", "-p", "3000"]
