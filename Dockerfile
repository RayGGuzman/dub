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

# Generate Prisma client
RUN pnpm --filter=@dub/prisma generate

# Build all packages and the web app with increased heap
ENV NODE_OPTIONS=--max-old-space-size=4096
RUN pnpm build

# Runtime stage
FROM node:20-alpine

WORKDIR /app

# Install pnpm
RUN npm install -g pnpm@9.15.9

# Copy pnpm files
COPY pnpm-workspace.yaml pnpm-lock.yaml package.json ./
COPY packages ./packages
COPY apps/web ./apps/web

# Install production dependencies only
RUN pnpm install --frozen-lockfile --prod

# Copy built app and packages from builder
COPY --from=builder /app/apps/web/.next ./apps/web/.next
COPY --from=builder /app/apps/web/public ./apps/web/public
COPY --from=builder /app/packages ./packages

# Clean up unused files
RUN rm -rf apps/web/.next/cache apps/web/public/videos

# Set environment to production
ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1
ENV NODE_OPTIONS=--max-old-space-size=2048

# Expose port
EXPOSE 3000

# Start the web app
WORKDIR /app/apps/web
CMD ["node_modules/.bin/next", "start", "-p", "3000"]
