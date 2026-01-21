FROM node:24-alpine  
  
WORKDIR /app  
  
# Instalar pnpm  
RUN npm install -g pnpm@9.15.9  
  
# Copiar archivos de configuración del workspace  
COPY package.json pnpm-workspace.yaml pnpm-lock.yaml ./  
  
# Copiar todos los paquetes del workspace  
COPY packages/ ./packages/  
COPY apps/ ./apps/  
  
# Instalar dependencias del workspace  
RUN pnpm install --frozen-lockfile  
  
# Generar cliente de Prisma  
RUN pnpm prisma:generate  
  
# Construir todo el monorepo  
RUN pnpm build  
  
# Exponer puerto de la aplicación  
EXPOSE 3000  
  
# Comando de inicio  
CMD ["pnpm", "start"]