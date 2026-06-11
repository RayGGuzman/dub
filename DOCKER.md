# Docker Setup para Dub

Esta configuración permite ejecutar la aplicación Dub con todos sus servicios en Docker.

## 📋 Requisitos

- Docker & Docker Compose instalados
- Archivo `.env` configurado en la raíz del proyecto con variables necesarias

## 🚀 Inicio Rápido

### Construcción y ejecución

```bash
# Construir la imagen Docker
docker-compose build

# Iniciar todos los servicios
docker-compose up -d

# Ver logs de la app web
docker-compose logs -f web
```

### Parar los servicios

```bash
# Parar todos los servicios
docker-compose down

# Parar y eliminar volúmenes (limpia la BD)
docker-compose down -v
```

## 🔧 Servicios Incluidos

1. **web** (Puerto 3000)
   - Aplicación Next.js principal
   - Imagen construida desde el Dockerfile

2. **ps-mysql** (Puerto 3306)
   - Base de datos MySQL 8.0
   - Simula PlanetScale localmente
   - Volumen persistente: `ps-mysql`

3. **planetscale-proxy** (Puerto 3900)
   - Proxy HTTP para MySQL
   - Permite conexiones HTTP a la BD

4. **mailhog** (Puertos 1025, 8025)
   - SMTP para testing de emails
   - UI web: http://localhost:8025

## 🌍 URLs de Acceso

- **Aplicación web**: http://localhost:3000
- **Mailhog**: http://localhost:8025
- **MySQL**: localhost:3306
- **PlanetScale Proxy**: localhost:3900

## 📝 Variables de Entorno

Asegúrate de tener un archivo `.env` con las siguientes variables:

```env
# Database
DATABASE_URL=mysql://root@ps-mysql:3306/planetscale

# Authentication (Next Auth)
NEXTAUTH_SECRET=your-secret-key
NEXTAUTH_URL=http://localhost:3000

# Otras variables según tu configuración
```

## 🛠️ Comandos Útiles

```bash
# Ver estado de servicios
docker-compose ps

# Ejecutar comando en el contenedor web
docker-compose exec web pnpm prisma push

# Generar schema de Prisma
docker-compose exec web pnpm prisma:generate

# Ver logs de un servicio específico
docker-compose logs -f web

# Reconstruir sin usar cache
docker-compose build --no-cache

# Eliminar imágenes no usadas
docker image prune -a
```

## 🔄 Desarrollo

Para desarrollo local con hot-reload (opcional), puedes descomentar los volúmenes en `docker-compose.yml`:

```yaml
volumes:
  - .:/app
  - /app/node_modules
```

Luego cambia el CMD en el Dockerfile a:
```dockerfile
CMD ["pnpm", "dev"]
```

## 📦 Build Multistage

El Dockerfile usa un build multistage:

1. **builder**: Instala dependencias y construye la app
2. **runtime**: Imagen optimizada con solo archivos necesarios

Esto reduce significativamente el tamaño de la imagen final.

## ⚠️ Producción

Para usar en producción:

1. Configura variables de entorno apropiadas
2. Considera usar PostgreSQL en lugar de MySQL
3. Implementa estrategia de backups
4. Configura reverse proxy (Nginx/Caddy)
5. Actualiza `NEXTAUTH_URL` con tu dominio

## 🐛 Troubleshooting

**Error: "Cannot find module"**
```bash
docker-compose down -v
docker-compose build --no-cache
docker-compose up -d
```

**Base de datos no responde**
```bash
# Reinicia MySQL
docker-compose restart ps-mysql
```

**Ver error completo de build**
```bash
docker-compose up web
```

## 📚 Recursos Adicionales

- [Next.js Deployment](https://nextjs.org/docs/deployment)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
