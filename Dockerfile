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
