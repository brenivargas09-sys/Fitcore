@echo off
REM ============================================================================
REM FitCore - Script de generacion del despliegue (Windows)
REM Requiere las variables de entorno SUPABASE_URL y SUPABASE_ANON_KEY.
REM ============================================================================
setlocal

if "%SUPABASE_URL%"=="" (echo ERROR: define SUPABASE_URL & exit /b 1)
if "%SUPABASE_ANON_KEY%"=="" (echo ERROR: define SUPABASE_ANON_KEY & exit /b 1)

echo ^>^> Compilando APK de liberacion
flutter build apk --release --dart-define=SUPABASE_URL=%SUPABASE_URL% --dart-define=SUPABASE_ANON_KEY=%SUPABASE_ANON_KEY% || (exit /b 1)

echo ^>^> APK en build\app\outputs\flutter-apk\app-release.apk
endlocal
