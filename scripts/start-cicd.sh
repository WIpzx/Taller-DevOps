#!/usr/bin/env bash
# Levanta la infraestructura CI/CD: Jenkins (8080) + SonarQube (9000).
set -e
cd "$(dirname "$0")/.."

echo ">> Construyendo y levantando CI/CD (Jenkins + SonarQube)..."
docker compose -f docker-compose.cicd.yml up -d --build

echo ""
echo ">> Estado de los servicios:"
docker compose -f docker-compose.cicd.yml ps

echo ""
echo "============================================================"
echo " Jenkins:    http://localhost:8080"
echo " SonarQube:  http://localhost:9000   (usuario inicial: admin / admin)"
echo "============================================================"
echo ">> Contraseña inicial de administrador de Jenkins:"
docker exec taller_jenkins cat /var/jenkins_home/secrets/initialAdminPassword 2>/dev/null \
  || echo "   (Jenkins aún está arrancando; reintenta en ~30s con:"
echo "    docker exec taller_jenkins cat /var/jenkins_home/secrets/initialAdminPassword )"
