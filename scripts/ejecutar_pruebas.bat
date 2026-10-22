@echo off
REM ============================================================================
REM FitCore - Script de pruebas del entorno de liberacion (Windows)
REM ============================================================================
setlocal
echo ^>^> Analisis estatico
flutter analyze || (exit /b 1)

echo ^>^> Pruebas automatizadas con cobertura
flutter test --coverage || (exit /b 1)

echo Pruebas completadas.
endlocal
