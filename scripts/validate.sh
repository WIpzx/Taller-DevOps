#!/usr/bin/env bash
# ============================================================
# Validación del entorno y de los artefactos del taller.
# Imprime OK / FAIL / -- por cada verificación.
#   OK   = correcto
#   FAIL = falta algo obligatorio
#   --   = servicio no levantado (informativo, no es error)
# ============================================================
set -uo pipefail
cd "$(dirname "$0")/.."

PASS=0; FAILS=0

ok()   { printf "  [ OK ]  %s\n" "$1"; PASS=$((PASS+1)); }
bad()  { printf "  [FAIL]  %s\n" "$1"; FAILS=$((FAILS+1)); }
info() { printf "  [ -- ]  %s\n" "$1"; }

file_check() { if [ -f "$1" ]; then ok "existe $1"; else bad "falta $1"; fi; }

# devuelve 0 si la URL responde (cualquier código HTTP) en <5s
url_up() { curl -s -o /dev/null -m 5 "$1"; }

echo "=== Herramientas ==="
if command -v docker >/dev/null 2>&1; then ok "docker disponible ($(docker --version))"; else bad "docker no encontrado"; fi
if docker compose version >/dev/null 2>&1; then ok "docker compose disponible ($(docker compose version | head -1))"; else bad "docker compose no encontrado"; fi
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then ok "repositorio git válido (rama: $(git rev-parse --abbrev-ref HEAD))"; else bad "no es un repositorio git"; fi

echo ""
echo "=== Archivos Docker Compose ==="
file_check "docker-compose.dev.yml"
file_check "docker-compose.prod.yml"
file_check "docker-compose.cicd.yml"

echo ""
echo "=== Jenkinsfiles ==="
file_check "jenkins/Jenkinsfile.api.dev"
file_check "jenkins/Jenkinsfile.frontend.dev"
file_check "jenkins/Jenkinsfile.prod"
file_check "jenkins/Dockerfile"

echo ""
echo "=== SonarQube ==="
file_check "bezkoder-api/sonar-project.properties"
file_check "bezkoder-ui/sonar-project.properties"
file_check "scripts/configure-sonar-quality-gate.sh"

echo ""
echo "=== Servicios CI/CD (si están levantados) ==="
if url_up "http://localhost:8080"; then ok "Jenkins responde en http://localhost:8080"; else info "Jenkins no levantado (http://localhost:8080)"; fi
if url_up "http://localhost:9000"; then ok "SonarQube responde en http://localhost:9000"; else info "SonarQube no levantado (http://localhost:9000)"; fi

echo ""
echo "=== Entorno DEV (si está levantado) ==="
if url_up "http://localhost:3000"; then ok "UI DEV responde en http://localhost:3000"; else info "UI DEV no levantado (http://localhost:3000)"; fi
if url_up "http://localhost:3001"; then ok "API DEV responde en http://localhost:3001"; else info "API DEV no levantado (http://localhost:3001)"; fi

echo ""
echo "=== Entorno PROD (si está levantado) ==="
if url_up "http://localhost:4000"; then ok "UI PROD responde en http://localhost:4000"; else info "UI PROD no levantado (http://localhost:4000)"; fi
if url_up "http://localhost:4001"; then ok "API PROD responde en http://localhost:4001"; else info "API PROD no levantado (http://localhost:4001)"; fi

echo ""
echo "=== Coexistencia DEV + PROD ==="
if url_up "http://localhost:3000" && url_up "http://localhost:4000"; then
  ok "DEV (3000) y PROD (4000) responden simultáneamente"
else
  info "No se detectaron DEV y PROD activos a la vez"
fi

echo ""
echo "============================================================"
echo " Resultado: ${PASS} OK, ${FAILS} FAIL"
echo "============================================================"
[ "$FAILS" -eq 0 ]
