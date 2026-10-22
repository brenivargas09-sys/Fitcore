#!/usr/bin/env bash
# ============================================================================
# FitCore - Script de pruebas del entorno de liberacion
# Ejecuta analisis estatico, pruebas unitarias/widget y cobertura.
# ============================================================================
set -euo pipefail

echo ">> Analisis estatico"
flutter analyze

echo ">> Pruebas automatizadas con cobertura"
flutter test --coverage

echo ">> Resumen de cobertura"
if [ -f coverage/lcov.info ]; then
  awk -F: '/LF:/{lf+=$2} /LH:/{lh+=$2} END {if (lf>0) printf "Cobertura de lineas: %.2f%%\n", (lh/lf)*100}' coverage/lcov.info
fi

echo "Pruebas completadas."
