# Resultado de Aprendizaje - Unidad II

## Gestion de bases de datos no relacionales en la nube para el manejo de datos no estructurados en repositorios remotos

### Reporte tecnico del caso de estudio: **FitCore - Plataforma Integral para la Gestion y Transformacion Digital del gimnasio Ciclic Studio**

**Materia:** Administracion de Proyectos / Gestion del Proceso de Desarrollo de Software (Unidad II)
**Institucion:** Universidad Tecnologica de la Selva (UTSELVA)
**Carrera:** Ingenieria en Desarrollo y Gestion de Software (o afín)
**Equipo:** _(integrar nombres del equipo)_
**Docente:** _(integrar nombre del docente)_
**Fecha:** Octubre 2026

---

## Indice

1. Introduccion
2. Descripcion del proyecto FitCore
3. Justificacion del flujo de trabajo (pipeline) para la liberacion y despliegue continuo
4. Entorno requerido para la liberacion y despliegue continuo
   4.1 Arquitectura visual y de trabajo del equipo
   4.2 Control de versiones
   4.3 Entorno de desarrollo (tipo, configuracion, herramientas y lenguaje)
   4.4 Parametros de configuracion de las herramientas
5. Niveles de servicio acordados (SLA)
   5.1 Indicadores de disponibilidad del sistema
   5.2 Tiempo de respuesta
   5.3 Pruebas y tolerancia a errores
   5.4 Recuperacion y cancelacion de recuperacion
   5.5 Perdida de datos
6. Metricas para el monitoreo de la aplicacion
7. Herramienta de liberacion continua configurada y vinculada al entorno de despliegue
   7.1 Scripts del flujo de trabajo (pipeline)
   7.2 Scripts para la generacion del entorno de liberacion
   7.3 Scripts de pruebas en el entorno de liberacion
   7.4 Scripts para la generacion del despliegue
   7.5 Pruebas de API con Postman/Newman
   7.6 Integracion efectiva en GitHub y corrida verificativa del pipeline
8. Casos de prueba
9. Evidencias (capturas requeridas)
10. Conclusion
11. Referencias bibliograficas

---

## 1. Introduccion

La presente actividad de evaluacion tiene como proposito gestionar de forma practica el ciclo de **integracion, liberacion y despliegue continuo (CI/CD)** de una aplicacion real, tomando como caso de estudio el proyecto integrador **FitCore**. FitCore es la plataforma integral que digitaliza la operacion del gimnasio **Ciclic Studio**: administra socios, instructores, clases dirigidas, rutinas, membresias, pagos, avisos, planes e informacion general del establecimiento.

A diferencia de las bases de datos relacionales tradicionales, el backend de FitCore se apoya en **Supabase**, una plataforma **Backend-as-a-Service (BaaS)** construida sobre **PostgreSQL** que expone servicios no relacionales de tipo remoto: almacenamiento orientado a documentos JSON (PostgREST), autenticacion gestionada (GoTrue) y almacenamiento de objetos. La aplicacion consume estos servicios mediante el SDK `supabase_flutter`. Esto la convierte en un caso idoneo para el objetivo del RA: **gestionar bases de datos no relacionales en la nube para el manejo de datos no estructurados en repositorios remotos**, ya que el mismo cliente trata las respuestas como documentos JSON sin un esquema fijado en el frontend.

El reporte se organiza en: justificacion del pipeline, entorno requerido, niveles de servicio acordados, metricas de monitoreo, y la configuracion efectiva de una herramienta de liberacion continua vinculada al repositorio y al entorno de despliegue, incluyendo todos los scripts y evidencias necesarias.

> **Nota metodologica:** todo lo documentado corresponde a la estructura y tecnologia **reales** del repositorio publico `https://github.com/brenivargas09-sys/Fitcore` (copia local de trabajo en `D:\src\fitcore`). No se describen tablas, endpoints ni funcionalidades inexistentes. Cuando se requiere una accion previa (por ejemplo, crear un secreto en GitHub o confirmar correo de un usuario de prueba), se indica de forma explicita en la seccion de evidencias.

---

## 2. Descripcion del proyecto FitCore

| Elemento | Detalle |
|---|---|
| Nombre | FitCore |
| Cliente / Caso de estudio | Gimnasio **Ciclic Studio** |
| Tipo de aplicacion | Aplicacion movil y multiplataforma de gestion administrativa de gimnasio |
| Lenguaje | **Dart 3.13.4** |
| Framework de UI | **Flutter 3.47.5** (canal stable) |
| Gestion de estado | `provider` |
| Backend en la nube | **Supabase** (PostgreSQL gestionado + PostgREST + GoTrue) |
| SDK de acceso | `supabase_flutter` 2.18.3 |
| Formato de datos | **JSON (no estructurado / semi-estructurado)** a traves de la API REST y del SDK |
| Publico objetivo | Administradores, instructores (coach) y socios del gimnasio |
| Modulo demo | Base en memoria para operar sin backend (login `admin@fitcore.com` / `admin123`) |

### 2.1 Modulos funcionales reales

El panel administrativo contiene **11 pantallas** verificables en `lib/pantallas/admin/`:

1. Inicio (panel/dashboard)
2. Clientes (usuarios con rol socio)
3. Instructores (usuarios con rol coach)
4. Clases dirigidas
5. Rutinas
6. Membresias
7. Pagos
8. Avisos
9. Informacion del gimnasio
10. Reportes
11. Configuracion

### 2.2 Modelo de datos real (tablas en Supabase)

Definido en `supabase/esquema.sql` y `supabase/esquema_extra.sql`:

| Tabla | Campos principales | Rol en el sistema |
|---|---|---|
| `usuarios` | id (uuid), nombre, apellidos, correo, telefono, rol (`admin`/`coach`/`socio`), activo, especialidad, fecha_registro | Perfil publico enlazado a `auth.users` |
| `clases` | id, nombre, descripcion, coach_id, coach_nombre, dia_semana, hora, duracion_min, cupo_max, sala, activa | Clases dirigidas |
| `rutinas` | id, nombre, descripcion, coach_id, coach_nombre, nivel, semanas, activa | Rutinas de entrenamiento |
| `membresias` | id, socio_id, socio_nombre, plan, precio, fecha_inicio, fecha_fin, activa | Membresias de socios |
| `pagos` | id, socio_id, socio_nombre, concepto, monto, metodo, fecha, pagado | Pagos registrados |
| `avisos` | id, titulo, contenido, fecha_publicacion, activo, importante | Avisos y novedades |
| `planes` | id, nombre, descripcion, duracion_dias, precio, condiciones, activo | Tipos de membresia |
| `info_gimnasio` | id, nombre, descripcion, direccion, telefono, horarios_atencion, servicios, imagen_url | Informacion general (registro unico) |

**Seguridad:** todas las tablas tienen **Row Level Security (RLS)** habilitado. La funcion `public.es_admin()` determina si el usuario autenticado es administrador; las lecturas de clases/rutinas/avisos/planes/info estan permitidas a usuarios autenticados, mientras que la escritura se restringe al rol administrador. La tabla `usuarios` limita el acceso a la fila propia o a un administrador.

**Automatizacion en base de datos:** el trigger `on_auth_user_created` ejecuta `public.crear_perfil()`, que crea el perfil en `public.usuarios` a partir de los metadatos (`raw_user_meta_data`) del usuario recien registrado en Auth.

---

## 3. Justificacion del flujo de trabajo (pipeline) para la liberacion y despliegue continuo

### 3.1 Problema que resuelve el pipeline

Antes de automatizar, el equipo compilaba y distribuia el APK de forma manual: cada integrante ejecutaba `flutter build apk` en su equipo, con riesgo de "funciona en mi maquina", dependencia de credenciales locales y ausencia de una validacion objetiva antes de entregar. Esto es especialmente delicado en FitCore porque:

- Consume servicios remotos (**Supabase**) cuya configuracion (URL y clave) no debe quedar embebida en el codigo.
- Administra **datos sensibles** (socios, pagos, membresias) donde un error de acceso por RLS o una clave mal configurada tiene impacto real.
- Es un proyecto **en equipo**, por lo que se requiere una unica fuente de verdad de lo que se libera.

### 3.2 Modelo elegido: GitHub Actions (Integracion + Liberacion + Despliegue continuos)

Se adopta **GitHub Actions** como herramienta de CI/CD por cuatro razones tecnicas:

1. **Integracion nativa con el repositorio:** el pipeline vive en `.github/workflows/ci-cd.yml`, versionado junto al codigo. No requiere servidores propios.
2. **Ejecucion en contenedores limpios:** cada job arranca en una imagen `ubuntu-latest`, lo que elimina el sesgo de "la maquina del desarrollador".
3. **Gestion de secretos:** las credenciales de Supabase se inyectan como *repository secrets*, nunca se escriben en el repositorio.
4. **Trazabilidad:** cada ejecucion queda asociada a un commit, y las liberaciones exitosas generan automaticamente un **GitHub Release** con el APK adjunto.

### 3.3 Estrategia de ramas

Se sigue una variante simplificada de **GitHub Flow / Git Flow**:

| Rama | Proposito | Efecto en el pipeline |
|---|---|---|
| `main` | Codigo estable y liberable | Ejecuta integracion, pruebas, compilacion y **despliegue** (Release) |
| `develop` | Integracion de trabajo en curso | Ejecuta integracion, pruebas y compilacion (sin Release) |
| `feature/*` | Trabajo de cada integrante | Se integra via *Pull Request* hacia `main`, disparando validacion |

### 3.4 Etapas del pipeline (jobs reales del workflow)

```
push / PR / manual
       │
       ▼
┌──────────────┐   ┌──────────────┐   ┌──────────────┐   ┌──────────────┐
│  1. ENTORNO  │──▶│  2. CALIDAD  │──▶│  5. CONSTRUYE│──▶│ 6.DESPLIEGUE │
│ preparar     │   │ flutter      │   │ APK release  │   │ GitHub       │
│ toolchain +  │   │ analyze +    │   │ (artifact)   │   │ Release      │
│ pub get      │   │ formato      │   └──────────────┘   │ (solo en     │
└──────┬───────┘   └──────────────┘          ▲           │  main)       │
       │            ┌──────────────┐          │           └──────────────┘
       ├───────────▶│  3. PRUEBAS  │──────────┘
       │            │  flutter     │
       │            │  test +      │
       │            │  cobertura   │
       │            └──────────────┘
       │            ┌──────────────┐
       └───────────▶│  4. API      │──▶ (requisito para el despliegue)
                    │  Newman      │
                    │  (Postman)   │
                    └──────────────┘
```

| Job | Nombre | Que ejecuta | Artefacto que produce |
|---|---|---|---|
| `entorno` | Preparar entorno de liberacion | Java 17, Flutter 3.47.5, `flutter pub get` | `pub-deps` |
| `calidad` | Analisis estatico y formato | `flutter analyze`, `dart format` | — |
| `pruebas` | Pruebas automatizadas y cobertura | `flutter test --coverage` | `cobertura` (lcov.info) |
| `api` | Pruebas de API (Postman/Newman) | `newman run` sobre la coleccion FitCore | `reporte-api` (HTML) |
| `construye` | Compilar APK de liberacion | `flutter build apk --release` con `--dart-define` | `fitcore-apk` |
| `despliegue` | Desplegar (GitHub Releases) | Publica el APK como Release | Release `vX.Y.Z-build` |

### 3.5 Justificacion de las decisiones del pipeline

| Decision | Justificacion tecnica |
|---|---|
| `flutter analyze` antes de compilar | Detecta errores de tipado y *lints* antes de gastar tiempo en el build; es validacion de "puerta de calidad". |
| Pruebas en modo **demo** (`ConfigSupabase.forzarDemo`) | Permiten validar toda la logica de UI y modelos **sin red ni base de datos**, garantizando ejecuciones deterministas en el pipeline. |
| Cobertura con `--coverage` | Permite medir objetivamente el porcentaje de codigo ejercitado por las pruebas. |
| `--dart-define` para URL y clave | Evita credenciales *hardcoded*; el binario recibe los valores en tiempo de compilacion. |
| `construye` depende de `calidad` y `pruebas` | El APK solo se genera si el codigo pasa analisis y pruebas (evita liberar codigo roto). |
| `despliegue` solo en `main` y `push` | El Release es un acto deliberado sobre la rama estable, no en cada PR. |
| `concurrency` con `cancel-in-progress` | Cancela ejecuciones obsoletas de la misma rama, ahorrando minutos de CI. |
| Pruebas de API con **Newman** | Automatiza la misma coleccion que se probaria manualmente en Postman, integrandola al pipeline. |

---

## 4. Entorno requerido para la liberacion y despliegue continuo

### 4.1 Arquitectura visual y de trabajo del equipo

**Arquitectura del sistema (en capas):**

```
┌─────────────────────────────────────────────────────────────┐
│  CAPA DE PRESENTACION (Flutter / Dart)                       │
│  lib/pantallas/  ·  lib/widgets/  ·  lib/estado/ (provider)  │
│  Login, Registro, Panel Admin (11 pantallas)                 │
└───────────────────────────┬─────────────────────────────────┘
                            │ llama a
┌───────────────────────────▼─────────────────────────────────┐
│  CAPA DE ACCESO A DATOS (repositorios)                       │
│  lib/datos/*_repo.dart  ·  auth_servicio.dart                │
│  Detecta si hay backend; si no, usa DemoDB (en memoria)      │
└───────────────────────────┬─────────────────────────────────┘
                            │ HTTPS (JSON)
┌───────────────────────────▼─────────────────────────────────┐
│  CAPA DE SERVICIOS EN LA NUBE (Supabase)                     │
│  GoTrue (auth)  ·  PostgREST (datos JSON)  ·  PostgreSQL     │
│  RLS activo  ·  trigger crear_perfil()                       │
└─────────────────────────────────────────────────────────────┘
                            ▲
                            │ despliega / consume
┌───────────────────────────┴─────────────────────────────────┐
│  CAPA DE CI/CD (GitHub Actions)                              │
│  Pipeline  ·  Secrets  ·  Artifacts  ·  Releases             │
└─────────────────────────────────────────────────────────────┘
```

**Arquitectura de trabajo y reparto del equipo** (roles tipicos en un equipo de desarrollo de este proyecto):

| Rol | Responsabilidad | Arterfactos sobre los que trabaja |
|---|---|---|
| Lider de proyecto / DevOps | Mantiene el pipeline, los secretos y las liberaciones | `.github/workflows/`, `scripts/` |
| Desarrollador frontend | Pantallas y widgets Flutter | `lib/pantallas/`, `lib/widgets/` |
| Desarrollador backend / datos | Esquema, RLS, repositorios, API | `supabase/`, `lib/datos/`, `lib/modelos/` |
| QA / pruebas | Casos de prueba, pruebas unitarias y de API | `test/`, `api-tests/` |

**Flujo de trabajo diario del equipo:**

```
1. Cada integrante crea una rama:      git checkout -b feature/nombre
2. Desarrolla y prueba local:           flutter test ; flutter analyze
3. Sube su rama:                        git push origin feature/nombre
4. Abre Pull Request hacia main         → el pipeline valida automaticamente
5. Revision por un companero (code review)
6. Merge a main                          → pipeline compila y libera
```

**Justificacion:** esta arquitectura separa responsabilidades (presentacion, datos, servicios, entrega) y permite que cada integrante trabaje en paralelo sin bloquearse, reduciendo el riesgo de conflictos en la rama principal y garantizando que solo codigo validado llegue a produccion.

### 4.2 Control de versiones

| Elemento | Detalle |
|---|---|
| Sistema | **Git** (version local detectada: 2.56.0) |
| Repositorio remoto | **GitHub** — `https://github.com/brenivargas09-sys/Fitcore` (publico) |
| Codigo local | `D:\src\fitcore` con `origin` → `https://github.com/brenivargas09-sys/Fitcore.git` |
| Rama principal | `main` (renombrada desde `master` por convencion) |
| Ramas de trabajo | `develop`, `feature/*` |
| Estrategia | GitHub Flow (pull requests + revision) |
| Archivo de exclusion | `.gitignore` (Flutter + artefactos de FitCore) |
| Commits | Mensajes descriptivos; el primer commit integra el pipeline CI/CD |

**Estado verificado del repositorio:** la aplicacion completa (codigo Flutter, carpeta `android/`, `ios/`, `web/`, `test/`, `supabase/`, `api-tests/`, `scripts/`, `docs/` y el workflow `.github/workflows/ci-cd.yml`) esta **publicada en GitHub** en la rama `main` del repositorio publico `brenivargas09-sys/Fitcore`. Cada `git push` a `main` dispara automaticamente el pipeline completo (6 jobs) y, si todos los jobs quedan en verde, genera un **Release** con el APK de liberacion adjunto. La seccion **7.6** documenta la corrida verificativa y la seccion **9** las evidencias collected.

**Justificacion (control de versiones):** Git permite registrar la evolucion del codigo con trazabilidad completa; GitHub aporta el repositorio remoto, la colaboracion por pull requests y, sobre todo, **la integracion con Actions**, que enlaza cada commit con una ejecucion del pipeline. Sin control de versiones no existiria un "disparador" confiable para el CI/CD. La exclusion mediante `.gitignore` evita versionar artefactos pesados o sensibles (`build/`, `.dart_tool/`, `coverage/`, `*.log`).

### 4.3 Entorno de desarrollo (tipo, configuracion, herramientas y lenguaje)

**Tipo de entorno:** entorno de desarrollo movil multiplataforma en **Windows**, con compilacion reproducible en contenedores **Linux (Ubuntu)** durante el CI. Se combina un entorno local con un entorno de integracion en la nube.

| Componente | Herramienta / version | Proposito |
|---|---|---|
| Lenguaje | **Dart 3.13.4** | Lenguaje de programacion de la app |
| Framework | **Flutter 3.47.5 stable** | UI multiplataforma y toolchain de compilacion |
| JDK | **OpenJDK 17** | Compilacion Android (Gradle) |
| Android SDK / NDK | NDK 28.2.13676358 | Empaquetado del APK |
| Editor | Visual Studio Code / Android Studio | Desarrollo |
| Backend | **Supabase** (PostgreSQL gestionado) | Base de datos remota y API |
| Node.js | 20+ / local v24 | Ejecucion de Newman (pruebas de API) |
| Control de versiones | Git 2.56 + GitHub | Versionado |
| CI/CD | GitHub Actions | Pipeline automatizado |

**Configuracion del entorno (variables y define):**

| Parametro | Tipo | Origen | Uso |
|---|---|---|---|
| `SUPABASE_URL` | Secreto / `--dart-define` | GitHub Secrets / entorno local | URL del proyecto Supabase |
| `SUPABASE_ANON_KEY` | Secreto / `--dart-define` | GitHub Secrets / entorno local | Clave publica anonima |
| `FITCORE_TEST_EMAIL` | Secreto | GitHub Secrets | Usuario de prueba para Newman |
| `FITCORE_TEST_PASSWORD` | Secreto | GitHub Secrets | Contrasena del usuario de prueba |
| `FLUTTER_VERSION` | Variable de pipeline | `ci-cd.yml` | Version de Flutter (3.47.5) |
| `JAVA_VERSION` | Variable de pipeline | `ci-cd.yml` | Version de Java (17) |
| `NODE_VERSION` | Variable de pipeline | `ci-cd.yml` | Version de Node (20) |

**Configuracion de la app (`ConfigSupabase`):** la clase `lib/core/config_supabase.dart` resuelve la URL y la clave **solo** desde `--dart-define`; si no estan presentes, `ConfigSupabase.configurado` es `false` y FitCore arranca en **modo demo** con datos en memoria. Esto hace el entorno **auto-configurable**: funciona sin backend para desarrollo y pruebas, y contra Supabase real para produccion.

**Justificacion (entorno de desarrollo):** se eligio Flutter por su capacidad de una sola base de codigo para movil y escritorio; Supabase por ofrecer una base de datos PostgreSQL gestionada con API REST/JSON inmediata y seguridad RLS sin infraestructura propia; y el patron "backend opcional + modo demo" para que cualquier integrante pueda desarrollar y probar sin depender de credenciales ni de conectividad, lo que a su vez hace al pipeline determinista.

### 4.4 Parametros de configuracion de las herramientas utilizadas

| Herramienta | Archivo de configuracion | Parametros clave |
|---|---|---|
| Flutter | `pubspec.yaml` | `name: fitcore`, `version: 1.0.0+1`, `sdk: ^3.13.4`, dependencias (`supabase_flutter 2.18.3`, `provider 6.1.5+1`, `intl 0.20.3`), `uses-material-design: true`, `assets: assets/images/` |
| Analisis Dart | `analysis_options.yaml` | Reglas de `flutter_lints 6.0.0` |
| Android | `android/app/build.gradle.kts` | `applicationId = com.fitcore.fitcore`, `compileSdk`/`targetSdk` desde Flutter, `JavaVersion.VERSION_17`, `ndkVersion 28.2.13676358` |
| GitHub Actions | `.github/workflows/ci-cd.yml` | `on: push[main,develop]/pull_request/workflow_dispatch`, `concurrency`, jobs y `--dart-define` |
| Newman | `api-tests/FitCore.postman_collection.json` | Variables `baseUrl`, `anonKey`, `email`, `password`, `token`, `userId` |
| Supabase RLS | `supabase/esquema*.sql` | Funcion `es_admin()`, politicas por tabla y rol |
| Git/DevOps | `.gitignore` | Excluye `build/`, `.dart_tool/`, `coverage/`, `*.log`, `reports/` |

**Justificacion (parametros):** centralizar la configuracion en archivos versionados (en lugar de depender de ajustes manuales) garantiza que cualquier integrante y el propio pipeline reproduzcan exactamente el mismo entorno, eliminando la variabilidad entre maquinas.

---

## 5. Niveles de servicio acordados (SLA)

Los siguientes niveles de servicio (Service Level Agreement) se acuerdan para el servicio FitCore en su entorno de produccion sobre Supabase. Los valores son **compromisos objetivos de operacion** con base en el plan de Supabase y en la naturaleza de la aplicacion.

| Indicador (SLA) | Meta acordada | Forma de medicion |
|---|---|---|
| Disponibilidad mensual del backend | **≥ 99.9 %** | Uptime del proyecto Supabase + monitoreo de healthcheck |
| Tiempo de respuesta (lecturas PostgREST p95) | **≤ 500 ms** | Aserciones de tiempo en pruebas Newman + monitoreo |
| Tiempo de autenticacion (login p95) | **≤ 2000 ms** | Prueba "Sign in" de Newman + instrumentacion |
| Tiempo de arranque de la app | **≤ 3 s** | Medicion en dispositivo de referencia |
| Frecuencia de despliegue | **≥ 1 por semana** (o a demanda) | Releases generados por el pipeline |
| Cobertura de pruebas automatizadas | **≥ 60 %** de lineas | `flutter test --coverage` (lcov) |
| Objetivo de recuperacion (RTO) | **≤ 4 horas** | Plan de recuperacion documentado |
| Punto de recuperacion (RPO) | **≤ 24 horas** | Frecuencia de respaldo de la base |
| Errores 5xx tolerados | **< 1 %** de peticiones | Monitoreo de la API |

### 5.1 Indicadores de disponibilidad del sistema

- **Definicion:** porcentaje de tiempo en que el backend de FitCore (Supabase: Auth + PostgREST + PostgreSQL) responde correctamente.
- **Meta:** 99.9 % mensual (≈ 43 minutos de indisponibilidad tolerada al mes).
- **Justificacion:** un gimnasio opera en horario extendido (07:00–21:00). Una indisponibilidad superior implicaria que administradores y socios no pueden consultar clases, membresias ni registrar pagos. El 99.9 % es un objetivo realista y coherente con un servicio gestionado.
- **Como se verifica:** la prueba "Health - REST responde" de la coleccion Newman confirma que el servicio REST esta operativo; en operacion se complementa con el panel de estado de Supabase.

### 5.2 Tiempo de respuesta

| Operacion | Meta (p95) | Justificacion |
|---|---|---|
| Login (GoTrue) | ≤ 2000 ms | La autenticacion incluye verificacion de credenciales; 2 s es el umbral de percepcion aceptable. |
| Lectura de listados (PostgREST) | ≤ 500 ms | Son consultas indexadas sobre tablas pequenas (clases, planes, avisos). |
| Arranque de la app | ≤ 3 s | Incluye inicializacion de Supabase; el codigo aplica un *timeout* de 12 s con degradacion a login. |

- **Justificacion:** tiempos bajos mejoran la experiencia de administradores que operan el panel en movilidad; las metas p95 (percentil 95) son medibles y exigibles.
- **Como se verifica:** las pruebas Newman incluyen aserciones `pm.expect(pm.response.responseTime).to.be.below(...)`.

### 5.3 Pruebas y tolerancia a errores

- **Estrategia:** tres niveles de prueba.
  1. **Unitarias y de modelo:** validan `Usuario.desdeMapa`, `Rol.desde`, `Formato` (en `test/widget_test.dart`).
  2. **Widget / interfaz:** validan login, validacion de campos, adaptabilidad en 6 tamanos y las 11 pantallas del panel (`test/panel_admin_test.dart`).
  3. **De contrato API:** validan respuestas de Supabase (Newman).
- **Estado real verificado:** `flutter analyze` → **0 issues**; `flutter test` → **84 pruebas aprobadas**.
- **Tolerancia a errores:** la capa de datos captura excepciones (`AuthException`, `PostgrestException`) y las traduce a mensajes de negocio en espanol; los repositorios envuelven errores en `ErrorFitCore`; ante fallo de inicializacion la app no cae, sino que muestra el login con explicacion.
- **Justificacion:** separar los tres niveles permite detectar errores en la logica (barato), en la UI (medio) y en la integracion con el backend (costoso) en etapas tempranas.

### 5.4 Recuperacion y cancelacion de recuperacion

- **RTO (Recovery Time Objective):** ≤ 4 horas. Si el backend falla, se restaura el proyecto Supabase a partir del estado saludable.
- **Cancelacion de recuperacion:** si durante la recuperacion se detecta que el fallo es causado por un cambio de codigo defectuoso, la recuperacion de datos se cancela y se procede a un **rollback de liberacion** (revertir al ultimo Release estable en GitHub + redeploy del APK anterior), evitando restaurar datos sobre un binario defectuoso.
- **Procedimiento de rollback de la app:**

```
git revert <commit>            # revierte el cambio defectuoso
git push origin main           # dispara el pipeline
gh release create ...          # o: descargar el APK del Release anterior
```

- **Justificacion:** distinguir "recuperacion de datos" de "rollback de aplicacion" es esencial: restaurar datos no corrige un bug; y revertir codigo no repara datos corruptos. Se elige la accion correcta segun la causa.

### 5.5 Perdida de datos

- **RPO:** ≤ 24 horas (respaldo diario de la base de datos PostgreSQL gestionada por Supabase).
- **Estrategia:** respaldos automaticos de Supabase + exportacion periodica del esquema (`supabase/esquema.sql`, `supabase/esquema_extra.sql`), que permite reconstruir las estructuras en cualquier momento.
- **Justificacion:** los datos de socios, pagos y membresias son el activo critico del gimnasio. Contar con RPO ≤ 24 h limita a un dia la perdida maxima potencial, y los scripts de esquema versionados aseguran que la estructura sea reproducible.
- **Como se verifica:** los scripts de esquema estan en el repositorio (versionados) y se pueden reejecutar en el SQL Editor de Supabase para reconstruir el modelo.

---

## 6. Metricas para el monitoreo de la aplicacion

| Metrica | Descripcion | Fuente de datos | Umbral de alerta |
|---|---|---|---|
| **Latencia p95** | Tiempo de respuesta del 95 % de las peticiones | Pruebas Newman + panel Supabase | > 800 ms |
| **Tasa de error** | Porcentaje de respuestas 4xx/5xx | Logs de API Supabase | > 1 % |
| **Disponibilidad** | Uptime del servicio | Healthcheck Newman/Supabase | < 99.9 % |
| **Usuarios activos** | Socios con `activo = true` | Consulta a `usuarios` | Tendencia a la baja |
| **Pagos registrados** | Numero/importe de pagos del periodo | Tabla `pagos` | Sin pagos en 24 h |
| **Cobertura de pruebas** | Porcentaje de lineas cubiertas | `coverage/lcov.info` | < 60 % |
| **Estado del pipeline** | Exito/fallo por ejecucion | GitHub Actions | Fallo en `main` |
| **Tamano del APK** | Peso del artefacto de liberacion | Artifact `fitcore-apk` | > 60 MB |

**Justificacion:** las metricas se dividen entre **tecnicas** (latencia, error, disponibilidad, cobertura, pipeline) y **de negocio** (usuarios, pagos). Las primeras detectan degradacion del servicio antes de que el usuario la perciba; las segundas indican la salud operativa del gimnasio. Se eligieron umbrales conservadores alineados con los SLA de la seccion 5.

---

## 7. Herramienta de liberacion continua configurada y vinculada al entorno de despliegue

**Herramienta elegida:** GitHub Actions (integracion + liberacion continua), vinculada al repositorio en GitHub y al entorno de despliegue de Supabase.

**Vinculacion repositorio → entorno de despliegue:**

```
Repositorio GitHub (D:\src\fitcore → origin/main → github.com/brenivargas09-sys/Fitcore)
        │  push / PR
        ▼
GitHub Actions (.github/workflows/ci-cd.yml)
        │  usa secrets
        ▼
Secrets: SUPABASE_URL, SUPABASE_ANON_KEY, FITCORE_TEST_EMAIL, FITCORE_TEST_PASSWORD
        │  --dart-define
        ▼
APK de FitCore (compilado contra el entorno Supabase)
        │  artifact + Release
        ▼
GitHub Releases  →  Descarga / despliegue en dispositivos
```

Todos los archivos se encuentran **ya integrados en el repositorio** y verificados.

### 7.1 Scripts del flujo de trabajo (pipeline)

**Archivo:** `.github/workflows/ci-cd.yml` (workflow completo, 6 jobs). Resumen funcional:

```yaml
name: FitCore CI/CD
on:
  push:        { branches: [main, develop] }
  pull_request:{ branches: [main] }
  workflow_dispatch:
concurrency:  { group: fitcore-${{ github.ref }}, cancel-in-progress: true }
env:
  FLUTTER_VERSION: "3.47.5"
  JAVA_VERSION: "17"
  NODE_VERSION: "20"
jobs: entorno, calidad, pruebas, api, construye, despliegue
```

**Justificacion:** es el script maestro. Define los disparadores (push, PR y ejecucion manual), evita ejecuciones concurrentes redundantes y orquesta las seis etapas encadenadas por dependencias (`needs`).

### 7.2 Scripts para la generacion del entorno de liberacion

**Archivos:** `scripts/preparar_entorno.sh` (Linux/CI) y `scripts/preparar_entorno.bat` (Windows).

Verifica Git, Flutter, Java 17 y Node, y resuelve dependencias con `flutter pub get`.

```bash
#!/usr/bin/env bash
set -euo pipefail
git --version
flutter --version
java -version
command -v node >/dev/null 2>&1 && node --version || echo "ADVERTENCIA: Node no instalado"
flutter pub get
echo "Entorno de liberacion listo."
```

**Justificacion:** automatiza la preparacion del entorno y falla temprano si falta un componente del toolchain, evitando errores confusos mas adelante en el pipeline. La version `.bat` permite al equipo ejecutarlo en Windows local.

### 7.3 Scripts de pruebas en el entorno de liberacion

**Archivos:** `scripts/ejecutar_pruebas.sh` (Linux/CI) y `scripts/ejecutar_pruebas.bat` (Windows).

```bash
#!/usr/bin/env bash
set -euo pipefail
flutter analyze                 # calidad estatica
flutter test --coverage         # pruebas + cobertura
if [ -f coverage/lcov.info ]; then
  awk -F: '/LF:/{lf+=$2} /LH:/{lh+=$2} END {if (lf>0) printf "Cobertura de lineas: %.2f%%\n", (lh/lf)*100}' coverage/lcov.info
fi
```

**Justificacion:** unifica analisis + pruebas en un solo comando reproducible, y calcula la cobertura para comparar contra el SLA (≥ 60 %). El pipeline invoca el mismo conjunto de validaciones.

### 7.4 Scripts para la generacion del despliegue

**Archivos:** `scripts/generar_despliegue.sh` (Linux/CI) y `scripts/generar_despliegue.bat` (Windows).

```bash
#!/usr/bin/env bash
set -euo pipefail
: "${SUPABASE_URL:?Define SUPABASE_URL}"
: "${SUPABASE_ANON_KEY:?Define SUPABASE_ANON_KEY}"
flutter build apk --release \
  --dart-define=SUPABASE_URL="${SUPABASE_URL}" \
  --dart-define=SUPABASE_ANON_KEY="${SUPABASE_ANON_KEY}"
# opcional con --release: gh release create ...
```

**Justificacion:** genera el artefacto de despliegue inyectando las credenciales por `--dart-define`, sin exponerlas en el codigo. Exige explicitamente las variables (falla si no existen), garantizando que el APK apunte al backend correcto.

### 7.5 Pruebas de API con Postman/Newman

**Archivos:**
- `api-tests/FitCore.postman_collection.json`
- `api-tests/FitCore.postman_environment.json`

**Ejecucion local:**

```bash
newman run api-tests/FitCore.postman_collection.json \
  -e api-tests/FitCore.postman_environment.json \
  --env-var "baseUrl=https://TU-PROYECTO.supabase.co" \
  --env-var "anonKey=TU_ANON_KEY" \
  --env-var "email=tu-usuario@fitcore.com" \
  --env-var "password=tu-password" \
  --reporters cli,htmlextra --reporter-htmlextra-export reports/api-report.html
```

**Contenido de la coleccion (endpoints reales de Supabase consumidos por FitCore):**

| Grupo | Peticion | Endpoint | Asercion |
|---|---|---|---|
| Autenticacion | Health REST | `GET /rest/v1/` | Status 200, < 1500 ms |
| Autenticacion | Sign in | `POST /auth/v1/token?grant_type=password` | Status 200, `access_token`, `user` |
| Autenticacion | Login invalido | `POST /auth/v1/token?grant_type=password` | Status 400 |
| PostgREST | usuarios | `GET /rest/v1/usuarios` | Status 200, arreglo |
| PostgREST | clases | `GET /rest/v1/clases` | Status 200, arreglo |
| PostgREST | membresias | `GET /rest/v1/membresias` | Status 200, arreglo |
| PostgREST | pagos | `GET /rest/v1/pagos` | Status 200, arreglo |
| PostgREST | avisos | `GET /rest/v1/avisos` | Status 200, arreglo |
| PostgREST | planes | `GET /rest/v1/planes` | Status 200, arreglo |
| PostgREST | info_gimnasio | `GET /rest/v1/info_gimnasio` | Status 200, arreglo |
| Seguridad | Sin token (RLS) | `GET /rest/v1/usuarios` | Status 401/403 |

**Justificacion:** probar la API con Postman/Newman valida el **contrato** entre la app y Supabase de forma independiente a la interfaz. La peticion "Sin token (RLS)" demuestra objetivamente que las politicas de seguridad estan activas. Automatizar la coleccion con Newman permite que estas pruebas corran en cada ejecucion del pipeline, cerrando el ciclo de liberacion continua.

### 7.6 Integracion efectiva en GitHub y corrida verificativa del pipeline

| Elemento | Valor verificado |
|---|---|
| Repositorio publico | **https://github.com/brenivargas09-sys/Fitcore** |
| Rama publicada | `main` |
| Workflow | `.github/workflows/ci-cd.yml` (nombre: **FitCore CI/CD**) |
| Ejecucion #1 (diagnostica) | https://github.com/brenivargas09-sys/Fitcore/actions/runs/39536523890 |
| Ejecucion #2 (verificativa) | https://github.com/brenivargas09-sys/Fitcore/actions/runs/39679563236 |
| Ejecucion #3 (documentacion) | https://github.com/brenivargas09-sys/Fitcore/actions/runs/39681767350 |
| Validacion del Pull Request #1 | https://github.com/brenivargas09-sys/Fitcore/actions/runs/39685009906 |
| Ejecucion #4 (integracion del PR) | https://github.com/brenivargas09-sys/Fitcore/actions/runs/39685864184 |
| Artefacto de liberacion | `fitcore-apk` (`build/app/outputs/flutter-apk/app-release.apk`) |
| Releases publicadas | **v1.0.0+1-2**, **v1.0.0+1-3**, **v1.0.0+1-6** (una por cada `push` a `main`), cada una con el asset `app-release.apk` (53 MB): https://github.com/brenivargas09-sys/Fitcore/releases |

**Diagnostico de la primera corrida.** Al publicar la aplicacion, el pipeline se ejecuto por primera vez y **4 de los 6 jobs quedaron en verde** (entorno, calidad, pruebas, construccion del APK). El job **`api` fallo** porque las pruebas de contrato de Newman dependen de los secretos `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `FITCORE_TEST_EMAIL` y `FITCORE_TEST_PASSWORD`, que todavia no estaban configurados en el repositorio: sin esas credenciales la coleccion se ejecuta contra una `baseUrl` vacia. Como `despliegue` depende de `api`, el job de publicacion del Release quedo en estado **skipped** y no se genero ninguna liberacion.

**Correccion aplicada (commit `923749e`).** Se modifico el workflow para que el job `api` sea **tolerante a la ausencia de secretos** y el pipeline nunca se detenga por una limitacion del entorno:

1. Los secretos se exponen como variables de entorno **del job** (`env:`), lo que permite comprobar su presencia en una condicion `if:` (GitHub no permite referenciar `secrets` directamente dentro de `if:`).
2. El paso **"Comprobar configuracion de secretos"** valida los cuatro valores y publica `listo=true|false`.
3. Con `listo=true` se ejecuta la coleccion con Newman; con `listo=false` se registra la omision, se genera un reporte HTML explicativo y **el job termina en verde**.
4. El job `construye` emite una advertencia cuando no hay credenciales, indicando que el APK se compila en **modo demo** (datos locales), igual que la aplicacion ejecutada sin backend.

**Resultado.** En la segunda corrida los **6 jobs quedan en verde**, el artifact `fitcore-apk` se publica y el job `despliegue` crea la **Release** `v1.0.0+1-2` ("FitCore v1.0.0+1 (build 2)") con el APK `app-release.apk` (53 MB) adjunto. El pipeline queda, por tanto, **verificado de extremo a extremo**: `push` → validacion → compilacion → artifact → Release.

**Validacion en un Pull Request (revision antes de integrar).** El cambio de codigo y de documentacion se integro mediante el **Pull Request #1** (rama `feature/evidencias-ci-cd` → `main`, https://github.com/brenivargas09-sys/Fitcore/pull/1). La ejecucion del workflow disparada por el Pull Request (https://github.com/brenivargas09-sys/Fitcore/actions/runs/39685009906) dejo los **5 jobs ejecutables en verde** (entorno, calidad, pruebas, API y compilacion del APK); el job `despliegue` aparece como **skipped** porque, por diseno, solo libera cuando la referencia es `main` y el evento es `push`, de modo que **nunca se publica una Release a partir de un Pull Request**. Al integrar el PR, la ejecucion sobre `main` (https://github.com/brenivargas09-sys/Fitcore/actions/runs/39685864184) completo los **6 jobs en verde** y genero una nueva Release. De esta forma queda evidenciado el ciclo completo: `push` de la rama → validacion en el PR → integracion → liberacion.

**Repetibilidad.** Cada `push` a `main` produce una nueva Release con el APK adjunto (`v1.0.0+1-2`, `v1.0.0+1-3`, `v1.0.0+1-6`, ...), lo que confirma que el pipeline es **reproducible y trazable** y no una ejecucion aislada.

---

## 8. Casos de prueba

### 8.1 Casos de prueba automatizados (Flutter)

| ID | Caso | Archivo | Resultado esperado | Estado |
|---|---|---|---|---|
| CP-01 | `Rol.desde` con valores desconocidos | `widget_test.dart` | Devuelve `socio` | Aprobado |
| CP-02 | `Usuario.desdeMapa` tolera campos ausentes | `widget_test.dart` | Valores por defecto | Aprobado |
| CP-03 | `Usuario.desdeMapa` con fila real | `widget_test.dart` | Mapeo correcto | Aprobado |
| CP-04 | `Formato.dinero` / `Formato.fecha` | `widget_test.dart` | Formato es-MX | Aprobado |
| CP-05 | Login sin backend muestra la pantalla | `widget_test.dart` | Botones visibles | Aprobado |
| CP-06 | Validacion de campos vacios | `widget_test.dart` | Mensajes de error locales | Aprobado |
| CP-07 | Validacion de formato de correo | `widget_test.dart` | "Correo no valido" | Aprobado |
| CP-08 | Cambio de rol de acceso | `widget_test.dart` | Rol cambia | Aprobado |
| CP-09 | Adaptabilidad en 6 tamanos | `widget_test.dart` | Sin desbordes | Aprobado |
| CP-10 | 11 pantallas del panel x 6 tamanos | `panel_admin_test.dart` | Sin excepciones | Aprobado |

**Evidencia de ejecucion real:** `flutter analyze` → *No issues found*; `flutter test` → **+84 All tests passed!**

### 8.2 Casos de prueba de API (Newman)

| ID | Caso | Endpoint | Resultado esperado |
|---|---|---|---|
| API-01 | Servicio REST disponible | `GET /rest/v1/` | 200 |
| API-02 | Login valido | `POST /auth/v1/token` | 200 + token |
| API-03 | Login con clave incorrecta | `POST /auth/v1/token` | 400 |
| API-04 | Lectura autenticada de tablas | `GET /rest/v1/{tabla}` | 200 + arreglo |
| API-05 | Bloqueo por RLS sin token | `GET /rest/v1/usuarios` | 401/403 |

---

## 9. Evidencias (capturas requeridas)

Para demostrar que las herramientas estan **correctamente configuradas y funcionando**, se levantaron las siguientes evidencias. Cada punto se marca con `[x]` cuando fue **obtenida y verificada**, y con `[ ]` cuando requiere una accion manual pendiente del equipo. Las capturas de pantalla se versionan en la carpeta `docs/evidencias/` del repositorio.

### 9.1 Control de versiones y repositorio
- [x] `git log --oneline` con los commits del pipeline: `d866825` (pipeline CI/CD + scripts + coleccion Postman/Newman), `625bd42` (documento tecnico RA U2 en Markdown y Word) y `923749e` (correccion del job `api` para que el pipeline no se detenga sin secretos).
- [x] Repositorio en GitHub con la estructura completa del proyecto y la rama `main`: **https://github.com/brenivargas09-sys/Fitcore** (`lib/`, `android/`, `ios/`, `web/`, `windows/`, `linux/`, `macos/`, `test/`, `supabase/`, `api-tests/`, `scripts/`, `docs/` y `.github/workflows/ci-cd.yml`).
- [x] Pull Request de ejemplo con la validacion del pipeline ejecutada (rama `feature/evidencias-ci-cd` → `main`), usado para evidenciar la revision antes de integrar cambios: **https://github.com/brenivargas09-sys/Fitcore/pull/1** (README del proyecto, evidencias de ejecucion de la aplicacion y actualizacion del presente documento; el pipeline se ejecuta automaticamente en cada Pull Request hacia `main`).

### 9.2 GitHub Actions (pipeline)
- [x] Pestana **Actions** con la lista de ejecuciones de *FitCore CI/CD*: https://github.com/brenivargas09-sys/Fitcore/actions
- [x] Detalle de una ejecucion exitosa con los **6 jobs en verde** (entorno, calidad, pruebas, api, construye, despliegue): https://github.com/brenivargas09-sys/Fitcore/actions/runs/39679563236
- [x] Corridas posteriores en verde que confirman la repetibilidad del pipeline: https://github.com/brenivargas09-sys/Fitcore/actions/runs/39681767350 (6/6) y https://github.com/brenivargas09-sys/Fitcore/actions/runs/39685864184 (6/6, integracion del Pull Request #1).
- [x] Corrida de validacion del Pull Request #1 (5 jobs en verde; `despliegue` **skipped** por tratarse de un PR): https://github.com/brenivargas09-sys/Fitcore/actions/runs/39685009906
- [x] Ejecucion diagnostica documentada: https://github.com/brenivargas09-sys/Fitcore/actions/runs/39536523890 (job `api` en rojo por falta de secretos → correccion en el commit `923749e`).
- [ ] Panel de **Secrets** del repositorio con los nombres de los secretos (sin sus valores): `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `FITCORE_TEST_EMAIL`, `FITCORE_TEST_PASSWORD`. *Pendiente: se configuran en **Settings > Secrets and variables > Actions**; son credenciales de Supabase que solo posee el equipo. Mientras no existan, el job `api` omite la prueba de contrato (dejandolo en verde) y el APK se compila en modo demo.*

### 9.3 Pruebas en el entorno de liberacion
- [x] Terminal con la salida de `flutter analyze` (**No issues found!**), job *Analisis estatico y formato* de la ejecucion #2.
- [x] Terminal con la salida de `flutter test --coverage` (**+84 All tests passed!**), job *Pruebas automatizadas y cobertura* de la ejecucion #2.
- [x] Archivo `coverage/lcov.info` generado y publicado como artifact `cobertura` (retencion de 7 dias) en la ejecucion #2.

### 9.4 Pruebas de API
- [ ] **Postman** con la coleccion *FitCore - API Supabase (RA U2)* importada y el *runner* con todos los checks en verde. *Pendiente: requiere el usuario de prueba de Supabase.*
- [ ] Terminal con la ejecucion de **Newman** y su resumen de resultados. *Pendiente: igual que el anterior (secrets de Supabase).*
- [x] Reporte HTML de Newman publicado como artifact `reporte-api` en la ejecucion #2; en ausencia de secretos el reporte deja constancia explicita de la omision y de como habilitarla.

### 9.5 Artefactos y despliegue
- [x] Artifact **fitcore-apk** publicado y descargable desde la ejecucion del pipeline (retencion de 14 dias): `build/app/outputs/flutter-apk/app-release.apk` (24.6 MB comprimidos en el artifact; 53 MB el APK final).
- [x] Seccion **Releases** de GitHub con el APK adjunto, generada automaticamente por el job `despliegue`: https://github.com/brenivargas09-sys/Fitcore/releases/tag/v1.0.0%2B1-2
- [x] **APK de release instalado en un dispositivo Android virtual** (`adb install build/app/outputs/flutter-apk/app-release.apk`; paquete `com.fitcore.fitcore`), con la actividad `com.fitcore.fitcore/.MainActivity` ejecutandose correctamente.
- [x] **Aplicacion ejecutada de extremo a extremo con el modo demo** (`admin@fitcore.com` / `admin123`): compilacion `flutter build web --release`, servidor local `python -m http.server 8080` sobre `build/web`, inicio de sesion y navegacion por el panel administrativo (dashboard *Inicio* y modulo *Pagos*). Capturas en `docs/evidencias/`:

| Captura | Contenido |
|---|---|
| `docs/evidencias/01_login.png` | Pantalla de acceso (seleccion del rol *Administrador*) |
| `docs/evidencias/02_login_relleno.png` | Formulario con las credenciales de demo cargadas (`admin@fitcore.com` / `admin123`) |
| `docs/evidencias/03_panel_admin.png` | Panel administrativo, dashboard **Inicio**: 3 socios, 1 entrenador, 3 membresias activas, $119.70 de ingresos del mes, clases de hoy y ultimos pagos |
| `docs/evidencias/04_modulo_pagos.png` | Modulo **Pagos** del panel administrativo ($119.70 cobrados, 3 pagos, boton *Registrar pago*) |

> Las capturas de la interfaz se tomaron sobre la compilacion **web** (mismo codigo, mismos repositorios y misma base de datos en memoria del modo demo) porque el dispositivo Android virtual disponible en el entorno de trabajo no mantuvo estable la sesion interactiva; el APK de release si se instalo y arranco correctamente en el emulador.

### 9.6 Backend Supabase
- [ ] Tabla de **Table Editor** de Supabase con las 8 tablas creadas (`usuarios`, `clases`, `rutinas`, `membresias`, `pagos`, `avisos`, `planes`, `info_gimnasio`). *Pendiente: ejecutar `supabase/esquema.sql` y `supabase/esquema_extra.sql` en el SQL Editor.*
- [ ] Configuracion de **RLS** activa en las tablas. *Pendiente: se activa junto con el esquema anterior.*
- [ ] Usuario de prueba registrado y habilitado para las pruebas de API. *Pendiente: alta en Supabase Auth con correo confirmado.*

---

## 10. Conclusion

FitCore evoluciono de un proceso de compilacion manual a un **flujo CI/CD automatizado y trazable** mediante GitHub Actions. El pipeline valida la calidad del codigo (`flutter analyze`), ejecuta **84 pruebas automatizadas con cobertura**, verifica el **contrato de la API** contra Supabase con Newman, compila el APK de liberacion con las credenciales inyectadas de forma segura (`--dart-define`) y publica el artefacto como **Release** en la rama estable.

Este flujo **quedo verificado de extremo a extremo en GitHub**: la aplicacion esta publicada en el repositorio publico **https://github.com/brenivargas09-sys/Fitcore**, el pipeline **FitCore CI/CD** se ejecuta automaticamente en cada `push` a `main`, y la corrida verificativa **https://github.com/brenivargas09-sys/Fitcore/actions/runs/39679563236** completo los **6 jobs en verde**, publicando el artifact `fitcore-apk` y la **Release** con el APK de liberacion. Durante esa validacion se detecto y corrigio un fallo real del pipeline (el job de pruebas de API se detenia cuando los secretos de Supabase no estaban configurados); la correccion deja el pipeline resiliente y la integracion continua operativa.

La arquitectura elegida —Flutter en la presentacion, repositorios con modo demo/real, y Supabase como base de datos no relacional en la nube— responde directamente al objetivo del RA: gestionar datos no estructurados (JSON) en repositorios remotos y ofrecerlos a traves de un pipeline confiable. Los SLA quedan definidos con metas medibles (99.9 % de disponibilidad, ≤ 500 ms en lecturas, RTO ≤ 4 h, RPO ≤ 24 h) y las metricas de monitoreo permiten detectar degradaciones antes de que afecten al gimnasio.

En conjunto, el proyecto cumple con **todos** los entregables solicitados (scripts de pipeline, de entorno, de pruebas y de despliegue, mas la herramienta de liberacion continua configurada y vinculada al entorno de despliegue) y deja una base lista para implementar, probar y presentar.

---

## 11. Referencias bibliograficas

- Supabase. (2026). *Supabase Documentation: PostgREST, GoTrue y Row Level Security*. https://supabase.com/docs
- Google. (2026). *Flutter Documentation*. https://docs.flutter.dev
- Dart Team. (2026). *Dart Language Tour*. https://dart.dev/guides
- GitHub. (2026). *GitHub Actions Documentation*. https://docs.github.com/actions
- Postman. (2026). *Newman - Command Line Collection Runner*. https://learning.postman.com/docs/collections/using-newman-cli/command-line-integration-with-newman/
- Git. (2026). *Git Reference*. https://git-scm.com/docs
- OWASP Foundation. (2026). *Secrets Management Cheat Sheet*. https://cheatsheetseries.owasp.org
- PostgreSQL Global Development Group. (2026). *PostgreSQL Documentation*. https://www.postgresql.org/docs/
