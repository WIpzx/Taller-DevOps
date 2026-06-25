#!/usr/bin/env bash
# ============================================================
# Crea/configura el Quality Gate "QualityTaller2" en SonarQube,
# le agrega las 15 condiciones del taller y lo deja como predeterminado.
#
# Requisitos:
#   - SonarQube accesible (por defecto http://localhost:9000)
#   - curl disponible
#   - Variable de entorno SONAR_TOKEN con un token de un usuario admin
#     (o token global de análisis con permiso de administrar Quality Gates).
#
# Uso:
#   export SONAR_TOKEN=xxxxxxxx           # NO se hardcodea en el repo
#   export SONAR_HOST_URL=http://localhost:9000   # opcional
#   bash scripts/configure-sonar-quality-gate.sh
#
# Compatible con SonarQube 9.9 LTS Community (parámetros por nombre: gateName/name).
# ============================================================
set -euo pipefail

SONAR_HOST_URL="${SONAR_HOST_URL:-http://localhost:9000}"
GATE_NAME="QualityTaller2"
BUILTIN_GATE="Sonar way"   # gate por defecto de fábrica (para poder borrar el nuestro al re-ejecutar)

if [[ -z "${SONAR_TOKEN:-}" ]]; then
  echo "ERROR: define la variable de entorno SONAR_TOKEN (token de admin de SonarQube)." >&2
  echo "       Ejemplo: export SONAR_TOKEN=xxxxxxxx" >&2
  exit 1
fi

# curl con autenticación por token (token como usuario, password vacío)
api() {
  # $1 = método (POST/GET), $2 = endpoint, $3 = datos (opcional)
  local method="$1" endpoint="$2" data="${3:-}"
  curl -s -u "${SONAR_TOKEN}:" -X "${method}" "${SONAR_HOST_URL}${endpoint}" ${data:+--data-urlencode "${data}"} "${@:4}"
}

echo ">> Esperando a que SonarQube esté disponible en ${SONAR_HOST_URL} ..."
ATTEMPTS=0
MAX_ATTEMPTS=60
until curl -s "${SONAR_HOST_URL}/api/system/status" | grep -q '"status":"UP"'; do
  ATTEMPTS=$((ATTEMPTS+1))
  if [[ ${ATTEMPTS} -ge ${MAX_ATTEMPTS} ]]; then
    echo "ERROR: SonarQube no respondió UP tras ${MAX_ATTEMPTS} intentos." >&2
    curl -s "${SONAR_HOST_URL}/api/system/status" || true
    exit 1
  fi
  printf '.'
  sleep 5
done
echo ""
echo ">> SonarQube está UP."

# --- Idempotencia: si el gate ya existe, lo dejamos limpio ---
echo ">> Limpiando estado previo (si existiera)..."
api POST "/api/qualitygates/set_as_default" "name=${BUILTIN_GATE}" >/dev/null 2>&1 || true
api POST "/api/qualitygates/destroy" "name=${GATE_NAME}" >/dev/null 2>&1 || true

# --- Crear el Quality Gate ---
echo ">> Creando Quality Gate '${GATE_NAME}'..."
CREATE_RESP="$(api POST "/api/qualitygates/create" "name=${GATE_NAME}")"
echo "   Respuesta: ${CREATE_RESP}"

# --- SonarQube 9.9 pre-puebla el gate con condiciones CAYC por defecto
#     (p. ej. new_coverage LT 80, new_security_hotspots_reviewed...).
#     Las eliminamos para dejar EXACTAMENTE las 15 condiciones del taller. ---
echo ">> Eliminando condiciones por defecto (CAYC) del gate recién creado..."
SHOW_JSON="$(curl -s -u "${SONAR_TOKEN}:" "${SONAR_HOST_URL}/api/qualitygates/show?name=${GATE_NAME}")"
CONDS_PART="$(echo "${SHOW_JSON}" | sed 's/.*"conditions":\[//; s/\].*//')"
echo "${CONDS_PART}" | grep -o '"id":"[^"]*"' | sed 's/"id":"//; s/"$//' | while read -r cid; do
  [ -n "${cid}" ] && curl -s -u "${SONAR_TOKEN}:" -X POST \
    "${SONAR_HOST_URL}/api/qualitygates/delete_condition" \
    --data-urlencode "id=${cid}" >/dev/null 2>&1
done

# --- Definición de las 15 condiciones: "metric|op|error" ---
# Ratings: A=1, B=2, C=3, D=4, E=5  => "worse than A" = GT 1
CONDITIONS=(
  "blocker_violations|GT|5"               # Blocker Issues > 5
  "bugs|GT|0"                             # Bugs > 0
  "code_smells|GT|20"                    # Code Smells > 20
  "coverage|LT|70"                       # Coverage < 70
  "new_coverage|LT|75"                   # Coverage on New Code < 75
  "critical_violations|GT|10"            # Critical Issues > 10
  "new_duplicated_lines_density|GT|3"    # Duplicated lines on New Code > 3%
  "sqale_rating|GT|1"                    # Maintainability Rating worse than A
  "new_maintainability_rating|GT|1"      # Maintainability Rating on New Code worse than A
  "major_violations|GT|15"               # Major Issues > 15
  "new_blocker_violations|GT|0"          # New Blocker Issues > 0
  "reliability_rating|GT|1"              # Reliability Rating worse than A
  "new_reliability_rating|GT|1"          # Reliability Rating on New Code worse than A
  "security_rating|GT|1"                 # Security Rating worse than A
  "new_security_rating|GT|1"             # Security Rating on New Code worse than A
)

echo ">> Agregando ${#CONDITIONS[@]} condiciones..."
for cond in "${CONDITIONS[@]}"; do
  IFS='|' read -r metric op error <<< "${cond}"
  RESP="$(curl -s -u "${SONAR_TOKEN}:" -X POST \
    "${SONAR_HOST_URL}/api/qualitygates/create_condition" \
    --data-urlencode "gateName=${GATE_NAME}" \
    --data-urlencode "metric=${metric}" \
    --data-urlencode "op=${op}" \
    --data-urlencode "error=${error}")"
  if echo "${RESP}" | grep -q '"errors"'; then
    echo "   [WARN] ${metric} (${op} ${error}) -> ${RESP}"
  else
    echo "   [OK]   ${metric} ${op} ${error}"
  fi
done

# --- Dejar como predeterminado ---
echo ">> Estableciendo '${GATE_NAME}' como Quality Gate predeterminado..."
api POST "/api/qualitygates/set_as_default" "name=${GATE_NAME}" >/dev/null
echo "   Hecho."

echo ""
echo ">> Verificación final del gate:"
curl -s -u "${SONAR_TOKEN}:" \
  "${SONAR_HOST_URL}/api/qualitygates/show?name=${GATE_NAME}"
echo ""
echo "============================================================"
echo " Quality Gate '${GATE_NAME}' configurado y dejado por defecto."
echo "============================================================"
