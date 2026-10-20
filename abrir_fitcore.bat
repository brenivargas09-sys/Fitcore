@echo off
setlocal
set ANDROID_HOME=D:\src\android-sdk
set ADB=%ANDROID_HOME%\platform-tools\adb.exe

echo ============================
echo   FitCore - Emulador
echo ============================

rem Si ya hay un emulador registrado, no arranca otro.
"%ADB%" devices | findstr /C:"emulator-" >nul
if %ERRORLEVEL%==0 goto esperar

echo Arrancando el emulador (fitcore)...
start "FitCore - Emulador" "%ANDROID_HOME%\emulator\emulator.exe" -avd fitcore -no-boot-anim

:esperar
echo Esperando a que el emulador arranque (1-2 minutos)...
"%ADB%" wait-for-device

:boot
set BOOT=
for /f "delims=" %%i in ('"%ADB%" shell getprop sys.boot_completed 2^>nul') do set BOOT=%%i
if "%BOOT%"=="1" goto listo
timeout /t 5 /nobreak >nul
goto boot

:listo
echo Emulador listo.
echo.
echo Ejecutando la app...
echo (para detener la app: Ctrl+C)
echo.
cd /d D:\src\fitcore
flutter run
