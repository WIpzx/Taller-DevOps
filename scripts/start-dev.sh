#!/usr/bin/env bash
# Levanta el entorno DEV (UI:3000, API:3001, MySQL interno).
set -e
cd "$(dirname "$0")/.."

ENV_FILE=".env.dev"
if [ ! -f "$ENV_FILE" ]; then
  echo ">> $ENV_FILE no existe: lo creo desde .env.dev.example"
  cp .env.dev.example "$ENV_FILE"
fi

echo ">> Construyendo y levantando DEV..."
docker compose --env-file "$ENV_FILE" -f docker-compose.dev.yml up -d --build

echo ""
echo ">> Estado:"
docker compose --env-file "$ENV_FILE" -f docker-compose.dev.yml ps

echo ""
echo "============================================================"
echo " DEV levantado:"
echo "   UI:  http://localhost:3000"
echo "   API: http://localhost:3001/api/tutorials"
echo "============================================================"
