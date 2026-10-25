#!/usr/bin/env bash
# ============================================================================
# FitCore - Preparacion del entorno de liberacion (Linux/macOS y CI)
# Verifica el toolchain necesario y resuelve dependencias.
# ============================================================================
set -euo pipefail

echo "[1/5] Verificando Git..."
git --version

echo "[2/5] Verificando Flutter..."
flutter --version

echo "[3/5] Verificando Java 17..."
java -version

echo "[4/4] Resolviendo dependencias Dart..."
flutter pub get

echo "Entorno de liberacion listo."
