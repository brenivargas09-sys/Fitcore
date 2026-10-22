# FitCore

Plataforma integral para la **gestion y transformacion digital del gimnasio Ciclic Studio**: socios, instructores, clases dirigidas, rutinas, membresias, pagos, avisos, planes e informacion del establecimiento.

- **Tecnologia:** Flutter 3.47.5 (Dart 3.13.4) + Supabase (PostgreSQL gestionado, PostgREST, GoTube, RLS)
- **Repositorio:** https://github.com/brenivargas09-sys/Fitcore
- **Documentacion del RA (Unidad II):** [`docs/RA_U2_FitCore.md`](docs/RA_U2_FitCore.md) y [`docs/RA_U2_FitCore.docx`](docs/RA_U2_FitCore.docx)

## Modulos funcionales

El panel administrativo contiene 11 pantallas verificables en `lib/pantallas/admin/`:

| Modulo | Pantalla | Descripcion |
|---|---|---|
| Inicio | `inicio_admin.dart` | Dashboard de operacion |
| Usuarios | `usuarios_admin.dart` | Socios e instructores (roles `admin` / `coach` / `socio`) |
| Clases | `clases_admin.dart` | Clases dirigidas (dia, hora, cupo, sala) |
| Rutinas | `rutinas_admin.dart` | Rutinas de entrenamiento por nivel |
| Membresias | `membresias_admin.dart` | Membresias activas por socio |
| Pagos | `pagos_admin.dart` | Pagos registrados (concepto, metodo, monto) |
| Avisos | `avisos_admin.dart` | Avisos y novedades del gimnasio |
| Informacion | `info_gimnasio_admin.dart` | Datos, horarios y servicios del establecimiento |
| Reportes | `reportes_admin.dart` | Indicadores por periodo |
| Configuracion | `configuracion_admin.dart` | Estado del backend y cierre de sesion |

## Estructura del proyecto

```
lib/
  core/        Configuracion de Supabase, tema, rutas, formato y errores
  datos/       Repositorios por entidad (con modo demo y modo real)
  estado/      Sesion y control de tema (provider)
  modelos/     Modelos de dominio
  pantallas/   Login, registro, panel administrativo
  widgets/     Widgets comunes
supabase/      Esquema SQL (tablas, RLS, politicas, trigger de perfil)
api-tests/     Coleccion Postman + entorno para las pruebas de contrato
scripts/       Scripts de entorno, pruebas y despliegue (.sh y .bat)
docs/          Reporte tecnico del RA U2 (Markdown + Word)
```

## Requisitos

| Herramienta | Version |
|---|---|
| Flutter | 3.47.5 (canal stable) |
| Dart | 3.13.4 |
| JDK | 17 (compilacion Android) |
| Node.js | 20 o superior (Newman, pruebas de API) |
| Android SDK | 36 / NDK 28.2.13676358 |

## Ejecucion local

### Modo demo (sin backend)

Si no se inyectan credenciales, FitCore arranca en **modo demo** con datos en memoria:

```bash
flutter pub get
flutter run
# usuario: admin@fitcore.com   clave: admin123
```

### Modo real (Supabase)

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://TU-PROYECTO.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJ...
```

El esquema de la base de datos esta versionado en `supabase/esquema.sql` y `supabase/esquema_extra.sql`; se ejecuta en el SQL Editor de Supabase. `lib/core/config_supabase.dart` resuelve URL y clave **solo** desde `--dart-define` o secretos de GitHub, nunca desde el codigo fuente.

## Pruebas y calidad

```bash
flutter analyze                 # analisis estatico
flutter test --coverage         # pruebas unitarias y de widget + cobertura
```

La cobertura se genera en `coverage/lcov.info`.

### Pruebas de contrato de la API (Postman / Newman)

```bash
npm install -g newman newman-reporter-htmlextra
newman run api-tests/FitCore.postman_collection.json \
  -e api-tests/FitCore.postman_environment.json \
  --env-var "baseUrl=https://TU-PROYECTO.supabase.co" \
  --env-var "anonKey=TU_ANON_KEY" \
  --env-var "email=tu-usuario@fitcore.com" \
  --env-var "password=tu-password" \
  --reporters cli,htmlextra --reporter-htmlextra-export reports/api-report.html
```

## Integracion y liberacion continua (CI/CD)

El pipeline vive en [`.github/workflows/ci-cd.yml`](.github/workflows/ci-cd.yml) y se ejecuta en cada `push` a `main`/`develop`, en cada Pull Request hacia `main` y de forma manual (`workflow_dispatch`).

| Job | Funcion | Artefacto |
|---|---|---|
| `entorno` | Prepara Flutter/Java/Node y resuelve dependencias | `pub-deps` |
| `calidad` | `flutter analyze` y verificacion de formato | — |
| `pruebas` | `flutter test --coverage` | `cobertura` |
| `api` | Pruebas de contrato con Newman | `reporte-api` |
| `construye` | `flutter build apk --release` | `fitcore-apk` |
| `despliegue` | Publica la Release con el APK adjunto | GitHub Release `v<version>-<build>` |

**Secretos requeridos** (Settings > Secrets and variables > Actions):

| Secreto | Uso |
|---|---|
| `SUPABASE_URL` | URL del proyecto Supabase |
| `SUPABASE_ANON_KEY` | Clave publica anonima |
| `FITCORE_TEST_EMAIL` | Usuario de prueba para Newman |
| `FITCORE_TEST_PASSWORD` | Contrasena del usuario de prueba |

> Si los secretos no estan configurados, el job `api` **omite** la prueba de contrato (dejandolo en verde) y el APK se compila en modo demo; el resto del pipeline continua y la Release se publica normalmente.
>
> Con los secretos configurados (estado actual del repositorio), el job `api` **ejecuta la coleccion Newman completa contra el proyecto Supabase real** (14 peticiones, 33 aserciones) y el reporte se **sanea** antes de publicarse como artifact `reporte-api`: contrasena, tokens JWT y claves publicables quedan reemplazados por `***`.

### Pruebas de API (Postman / Newman)

La coleccion `api-tests/FitCore.postman_collection.json` cubre autenticacion, lectura de las 8 tablas y seguridad (401 sin credenciales y RLS sin fuga de filas al rol anonimo):

```bash
npm install -g newman newman-reporter-htmlextra
newman run api-tests/FitCore.postman_collection.json \
  -e api-tests/FitCore.postman_environment.json \
  --env-var "baseUrl=$SUPABASE_URL" \
  --env-var "anonKey=$SUPABASE_ANON_KEY" \
  --env-var "email=$FITCORE_TEST_EMAIL" \
  --env-var "password=$FITCORE_TEST_PASSWORD" \
  --reporters cli,htmlextra --reporter-htmlextra-export reports/api-report.html
```

Ultima salida real: **14 peticiones, 33 aserciones, 0 fallas** (evidencias en `docs/evidencias/api-newman-consola.txt`, `docs/evidencias/api-newman-consola-ci.txt` y `docs/evidencias/api-newman-report.html`).

### Verificacion del backend con el cliente de la app

`tool/verificar_backend.dart` comprueba, con el mismo cliente `package:supabase` que usa la aplicacion, que el login real funciona, que el rol administrativo se resuelve, que las 8 tablas responden y que la RLS protege los datos:

```bash
# PowerShell
$env:SUPABASE_URL="https://TU-PROYECTO.supabase.co"
$env:SUPABASE_ANON_KEY="eyJ..."
$env:FITCORE_TEST_EMAIL="admin@fitcore.com"
$env:FITCORE_TEST_PASSWORD="admin123"
dart run tool/verificar_backend.dart
```

Salida real: `docs/evidencias/verificacion-backend.txt` (todas las comprobaciones `[OK]`). El pipeline ejecuta este script en el job *Pruebas automatizadas y cobertura*.

Ejecuciones y artefactos: https://github.com/brenivargas09-sys/Fitcore/actions
Releases: https://github.com/brenivargas09-sys/Fitcore/releases
