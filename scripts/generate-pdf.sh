#!/usr/bin/env bash
# ============================================================
# Genera el PDF de la Quick Start Guide a partir del Markdown.
# - Si hay pandoc + motor LaTeX -> genera PDF directamente.
# - Si hay pandoc sin LaTeX     -> genera DOCX/HTML como alternativa.
# - Si no hay pandoc            -> indica alternativas (no falla en silencio).
# ============================================================
set -e
cd "$(dirname "$0")/.."

SRC="docs/quick-start-guide.md"
OUT_PDF="docs/quick-start-guide.pdf"
OUT_DOCX="docs/quick-start-guide.docx"
OUT_HTML="docs/quick-start-guide.html"

if [ ! -f "$SRC" ]; then
  echo "ERROR: no existe $SRC" >&2
  exit 1
fi

if command -v pandoc >/dev/null 2>&1; then
  echo ">> pandoc detectado."
  # ¿Hay un motor LaTeX para PDF?
  if command -v xelatex >/dev/null 2>&1 || command -v pdflatex >/dev/null 2>&1 || command -v wkhtmltopdf >/dev/null 2>&1; then
    ENGINE_OPT=""
    command -v xelatex   >/dev/null 2>&1 && ENGINE_OPT="--pdf-engine=xelatex"
    command -v wkhtmltopdf >/dev/null 2>&1 && [ -z "$ENGINE_OPT" ] && ENGINE_OPT="--pdf-engine=wkhtmltopdf"
    echo ">> Generando PDF ($ENGINE_OPT)..."
    pandoc "$SRC" -o "$OUT_PDF" $ENGINE_OPT --resource-path=docs --toc
    echo ">> PDF generado: $OUT_PDF"
  else
    echo ">> No hay motor LaTeX/wkhtmltopdf. Genero DOCX y HTML como alternativa."
    pandoc "$SRC" -o "$OUT_DOCX" --resource-path=docs
    pandoc "$SRC" -o "$OUT_HTML" --resource-path=docs --self-contained
    echo ">> Generados: $OUT_DOCX y $OUT_HTML"
    echo "   (Abre el DOCX y exporta a PDF, o instala LaTeX: 'tinytex'/'texlive-xetex')."
  fi
else
  echo ">> pandoc NO está instalado. Alternativas para generar el PDF:"
  echo "   1) Instalar pandoc + tinytex y reejecutar este script:"
  echo "        https://pandoc.org/installing.html"
  echo "   2) Abrir docs/quick-start-guide.md en VS Code con la extensión"
  echo "      'Markdown PDF' (yzane) y exportar a PDF."
  echo "   3) Subir el .md a https://dillinger.io y exportar como PDF."
  echo "   4) Con Docker (sin instalar nada):"
  echo "        docker run --rm -v \"\$PWD/docs\":/data pandoc/latex \\"
  echo "          quick-start-guide.md -o quick-start-guide.pdf --toc"
  exit 2
fi
