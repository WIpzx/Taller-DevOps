#!/usr/bin/env bash
# Detiene el entorno DEV (conserva los volúmenes/datos).
set -e
cd "$(dirname "$0")/.."

ENV_FILE=".env.dev"
[ -f "$ENV_FILE" ] || ENV_FILE=".env.dev.example"

echo ">> Deteniendo DEV..."
docker compose --env-file "$ENV_FILE" -f docker-compose.dev.yml down
echo ">> DEV detenido (los datos del volumen taller_devops_db_dev se conservan)."
echo "   Para borrar también los datos: docker volume rm taller_devops_db_dev"
