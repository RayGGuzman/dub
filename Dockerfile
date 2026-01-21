FROM node:24-alpine

WORKDIR /app

RUN npm install -g pnpm@9.15.9

COPY package.json pnpm-workspace.yaml pnpm-lock.yaml turbo.json ./

COPY packages/ ./packages/
COPY apps/ ./apps/

# Prisma (ajusta según tu estructura)
COPY packages/db/prisma ./packages/db/prisma

RUN pnpm install --frozen-lockfile

RUN cd apps/web && pnpm prisma:generate

RUN turbo run build --filter=web

EXPOSE 3000

CMD ["pnpm", "--filter", "web", "start"]
