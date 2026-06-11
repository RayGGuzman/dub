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

# Build with increased heap
ENV NODE_OPTIONS=--max-old-space-size=4096

# First build all dependencies
RUN pnpm build

# Then explicitly build the web app
RUN pnpm --filter=web build

# Verify .next was created in builder stage
RUN if [ ! -d "apps/web/.next" ]; then \
  echo "ERROR: .next directory not found after build!"; \
  ls -la apps/web/; \
  exit 1; \
fi

# Show what's in .next for debugging
RUN echo "✓ .next directory found" && ls -la apps/web/.next | head -20

# Runtime stage
FROM node:20-alpine

WORKDIR /app

# Install pnpm
RUN npm install -g pnpm@9.15.9

# Copy EVERYTHING from builder
COPY --from=builder /app ./

# Verify .next directory exists
RUN if [ ! -d "apps/web/.next" ]; then echo "ERROR: .next directory not found!"; exit 1; fi

# Set environment to production
ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1
ENV NODE_OPTIONS=--max-old-space-size=2048

# Expose port
EXPOSE 3000

# Start the web app using npm script
WORKDIR /app/apps/web
CMD ["pnpm", "start"]
