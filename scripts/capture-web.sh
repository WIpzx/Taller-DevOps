#!/usr/bin/env bash
# ============================================================
# Capturas automáticas OPCIONALES de páginas web públicas del taller.
# Usa Playwright vía npx (sin instalación global permanente).
#
# IMPORTANTE:
#   - Solo captura páginas que NO requieren login (frontend DEV/PROD y,
#     opcionalmente, las portadas de Jenkins/SonarQube).
#   - NO automatiza inicios de sesión ni maneja secretos.
#   - NO genera imágenes falsas: si una URL no responde, la omite y avisa.
#
# Las capturas que requieren sesión (dashboards de Jenkins/SonarQube ya
# logueado, Quality Gate, jobs, pipelines) deben tomarse a mano:
#   ver docs/checklist-capturas.md
# ============================================================
set -e
cd "$(dirname "$0")/.."

OUT="docs/capturas"
mkdir -p "$OUT"

if ! command -v npx >/dev/null 2>&1; then
  echo ">> No hay Node/npx disponible. Instala Node.js o toma las capturas a mano."
  echo "   Guía manual: docs/checklist-capturas.md"
  exit 2
fi

# Lista: "archivo|url|descripción"
TARGETS=(
  "12_app_dev.png|http://localhost:3000|Frontend DEV"
  "13_app_prod.png|http://localhost:4000|Frontend PROD"
  "04_sonarqube_dashboard.png|http://localhost:9000|SonarQube (portada; el dashboard logueado va a mano)"
)

url_up() { curl -s -o /dev/null -m 5 "$1"; }

echo ">> Preparando Playwright (puede descargar el navegador la primera vez)..."
SHOTS=""
for t in "${TARGETS[@]}"; do
  IFS='|' read -r file url desc <<< "$t"
  if url_up "$url"; then
    echo "   Capturando $desc -> $OUT/$file"
    SHOTS="${SHOTS}${OUT}/${file}|${url}\n"
  else
    echo "   [omitido] $desc no responde ($url)"
  fi
done

if [ -z "$SHOTS" ]; then
  echo ">> Ninguna URL respondió. Levanta los entornos y reintenta."
  exit 0
fi

# Script Node temporal que usa Playwright
TMPJS="$(mktemp).cjs"
cat > "$TMPJS" <<'EOF'
const { chromium } = require('playwright');
(async () => {
  const shots = process.env.SHOTS.trim().split('\n').filter(Boolean);
  const browser = await chromium.launch();
  const page = await browser.newPage({ viewport: { width: 1366, height: 900 } });
  for (const line of shots) {
    const [file, url] = line.split('|');
    try {
      await page.goto(url, { waitUntil: 'networkidle', timeout: 15000 });
      await page.screenshot({ path: file, fullPage: true });
      console.log('   OK', file);
    } catch (e) {
      console.log('   ERROR', url, e.message);
    }
  }
  await browser.close();
})();
EOF

SHOTS="$(printf "%b" "$SHOTS")" npx --yes playwright@latest install chromium >/dev/null 2>&1 || true
SHOTS="$(printf "%b" "$SHOTS")" npx --yes -p playwright@latest node "$TMPJS"
rm -f "$TMPJS"
echo ">> Capturas automáticas finalizadas en $OUT/"
