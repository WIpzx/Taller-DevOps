#!/usr/bin/env bash
# Detiene el entorno PROD (conserva los volúmenes/datos).
set -e
cd "$(dirname "$0")/.."

ENV_FILE=".env.prod"
[ -f "$ENV_FILE" ] || ENV_FILE=".env.prod.example"

echo ">> Deteniendo PROD..."
docker compose --env-file "$ENV_FILE" -f docker-compose.prod.yml down
echo ">> PROD detenido (los datos del volumen taller_devops_db_prod se conservan)."
echo "   Para borrar también los datos: docker volume rm taller_devops_db_prod"
