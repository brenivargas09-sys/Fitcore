@echo off
REM ============================================================================
REM FitCore - Preparacion del entorno de liberacion (Windows)
REM Verifica el toolchain necesario y resuelve dependencias.
REM ============================================================================
setlocal

echo [1/5] Verificando Git...
git --version || (echo ERROR: Git no esta instalado. & exit /b 1)

echo [2/5] Verificando Flutter...
flutter --version || (echo ERROR: Flutter no esta en PATH. & exit /b 1)

echo [3/5] Verificando Java 17...
java -version || (echo ERROR: Java 17 no esta instalado. & exit /b 1)

echo [4/5] Verificando Node (para Newman)...
node --version || (echo ADVERTENCIA: Node no esta instalado; Newman no podra ejecutarse.)

echo [5/5] Resolviendo dependencias Dart...
flutter pub get || (exit /b 1)

echo Entorno de liberacion listo.
endlocal
