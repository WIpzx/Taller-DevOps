#!/usr/bin/env bash
# Levanta el entorno PROD (UI:4000, API:4001, MySQL interno).
set -e
cd "$(dirname "$0")/.."

ENV_FILE=".env.prod"
if [ ! -f "$ENV_FILE" ]; then
  echo ">> $ENV_FILE no existe: lo creo desde .env.prod.example"
  cp .env.prod.example "$ENV_FILE"
fi

echo ">> Construyendo y levantando PROD..."
docker compose --env-file "$ENV_FILE" -f docker-compose.prod.yml up -d --build

echo ""
echo ">> Estado:"
docker compose --env-file "$ENV_FILE" -f docker-compose.prod.yml ps

echo ""
echo "============================================================"
echo " PROD levantado:"
echo "   UI:  http://localhost:4000"
echo "   API: http://localhost:4001/api/tutorials"
echo "============================================================"
