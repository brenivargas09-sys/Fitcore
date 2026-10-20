#!/usr/bin/env bash
# ============================================================================
# FitCore - Script de generacion del despliegue
# Compila el APK de liberacion inyectando las claves de Supabase por
# --dart-define (nunca quedan escritas en el codigo fuente).
#
# Uso:
#   SUPABASE_URL=https://xxx.supabase.co \
#   SUPABASE_ANON_KEY=eyJ... ./scripts/generar_despliegue.sh
# ============================================================================
set -euo pipefail

: "${SUPABASE_URL:?Define SUPABASE_URL}"
: "${SUPABASE_ANON_KEY:?Define SUPABASE_ANON_KEY}"

echo ">> Compilando APK de liberacion"
flutter build apk --release \
  --dart-define=SUPABASE_URL="${SUPABASE_URL}" \
  --dart-define=SUPABASE_ANON_KEY="${SUPABASE_ANON_KEY}"

echo ">> APK generado en build/app/outputs/flutter-apk/app-release.apk"

if command -v gh >/dev/null 2>&1 && [ "${1:-}" = "--release" ]; then
  VERSION=$(awk '/^version:/{print $2}' pubspec.yaml)
  echo ">> Publicando release v${VERSION}"
  gh release create "v${VERSION}-$(date +%s)" \
    build/app/outputs/flutter-apk/app-release.apk \
    --title "FitCore v${VERSION}" \
    --notes "Liberacion generada por el pipeline CI/CD de FitCore."
fi
