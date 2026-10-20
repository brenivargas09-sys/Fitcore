"""Genera el documento Word (.docx) del RA U2 de FitCore."""
from docx import Document
from docx.shared import Pt, RGBColor, Inches
from docx.enum.text import WD_ALIGN_PARAGRAPH

AZUL = RGBColor(0x1E, 0x40, 0xAF)


def encabezado(doc, texto, nivel=1):
    h = doc.add_heading(texto, level=nivel)
    for r in h.runs:
        r.font.color.rgb = AZUL
    return h


def parrafo(doc, texto, negrita=False, cursiva=False):
    p = doc.add_paragraph()
    r = p.add_run(texto)
    r.bold = negrita
    r.italic = cursiva
    return p


def vinetas(doc, items):
    for it in items:
        doc.add_paragraph(it, style="List Bullet")


def tabla(doc, encabezados, filas):
    t = doc.add_table(rows=1, cols=len(encabezados))
    t.style = "Light Grid Accent 1"
    for i, e in enumerate(encabezados):
        c = t.rows[0].cells[i]
        c.text = ""
        run = c.paragraphs[0].add_run(e)
        run.bold = True
    for fila in filas:
        celdas = t.add_row().cells
        for i, v in enumerate(fila):
            celdas[i].text = str(v)
    doc.add_paragraph()


def codigo(doc, texto):
    p = doc.add_paragraph()
    r = p.add_run(texto)
    r.font.name = "Consolas"
    r.font.size = Pt(9)
    return p


doc = Document()
estilo = doc.styles["Normal"]
estilo.font.name = "Arial"
estilo.font.size = Pt(12)

# Portada
doc.add_paragraph()
t = doc.add_paragraph()
t.alignment = WD_ALIGN_PARAGRAPH.CENTER
r = t.add_run("Universidad Tecnologica de la Selva (UTSELVA)")
r.bold = True
r.font.size = Pt(14)

p = doc.add_paragraph()
p.alignment = WD_ALIGN_PARAGRAPH.CENTER
p.add_run("Ingenieria en Desarrollo y Gestion de Software\n").bold = True

doc.add_paragraph()
t = doc.add_paragraph()
t.alignment = WD_ALIGN_PARAGRAPH.CENTER
r = t.add_run(
    "Resultado de Aprendizaje - Unidad II\n"
    "Gestion de bases de datos no relacionales en la nube para el manejo de "
    "datos no estructurados en repositorios remotos"
)
r.bold = True
r.font.size = Pt(16)

doc.add_paragraph()
t = doc.add_paragraph()
t.alignment = WD_ALIGN_PARAGRAPH.CENTER
t.add_run(
    "Reporte tecnico del caso de estudio\n"
    "FitCore - Plataforma Integral para la Gestion y Transformacion Digital "
    "del gimnasio Ciclic Studio"
).italic = True

doc.add_paragraph()
for linea in [
    "Equipo: ________________________________________",
    "Docente: ________________________________________",
    "Materia: Administracion de Proyectos / Gestion del Proceso de Desarrollo de Software",
    "Fecha: Octubre 2026",
]:
    pp = doc.add_paragraph()
    pp.alignment = WD_ALIGN_PARAGRAPH.CENTER
    pp.add_run(linea)

doc.add_page_break()

# Indice
encabezado(doc, "Indice", 1)
indice = [
    "1. Introduccion",
    "2. Descripcion del proyecto FitCore",
    "3. Justificacion del flujo de trabajo (pipeline) para la liberacion y despliegue continuo",
    "4. Entorno requerido para la liberacion y despliegue continuo",
    "5. Niveles de servicio acordados (SLA)",
    "6. Metricas para el monitoreo de la aplicacion",
    "7. Herramienta de liberacion continua configurada y vinculada al entorno de despliegue",
    "8. Casos de prueba",
    "9. Evidencias (capturas requeridas)",
    "10. Conclusion",
    "11. Referencias bibliograficas",
]
for i in indice:
    doc.add_paragraph(i)
doc.add_page_break()

# 1. Introduccion
encabezado(doc, "1. Introduccion", 1)
parrafo(doc, (
    "La presente actividad de evaluacion tiene como proposito gestionar de forma "
    "practica el ciclo de integracion, liberacion y despliegue continuo (CI/CD) de "
    "una aplicacion real, tomando como caso de estudio el proyecto integrador "
    "FitCore. FitCore es la plataforma integral que digitaliza la operacion del "
    "gimnasio Ciclic Studio: administra socios, instructores, clases dirigidas, "
    "rutinas, membresias, pagos, avisos, planes e informacion general del "
    "establecimiento."
))
parrafo(doc, (
    "A diferencia de las bases de datos relacionales tradicionales, el backend de "
    "FitCore se apoya en Supabase, una plataforma Backend-as-a-Service (BaaS) "
    "construida sobre PostgreSQL que expone servicios no relacionales de tipo "
    "remoto: almacenamiento orientado a documentos JSON (PostgREST), autenticacion "
    "gestionada (GoTrue) y almacenamiento de objetos. La aplicacion consume estos "
    "servicios mediante el SDK supabase_flutter. Esto la convierte en un caso "
    "idoneo para el objetivo del RA: gestionar bases de datos no relacionales en la "
    "nube para el manejo de datos no estructurados en repositorios remotos."
))
parrafo(doc, (
    "Nota metodologica: todo lo documentado corresponde a la estructura y "
    "tecnologia reales del repositorio fitcore. No se describen tablas, endpoints "
    "ni funcionalidades inexistentes."
))

# 2. Descripcion
encabezado(doc, "2. Descripcion del proyecto FitCore", 1)
tabla(doc, ["Elemento", "Detalle"], [
    ["Nombre", "FitCore"],
    ["Cliente / Caso de estudio", "Gimnasio Ciclic Studio"],
    ["Tipo de aplicacion", "App movil y multiplataforma de gestion administrativa de gimnasio"],
    ["Lenguaje", "Dart 3.13.4"],
    ["Framework de UI", "Flutter 3.47.5 (canal stable)"],
    ["Gestion de estado", "provider"],
    ["Backend en la nube", "Supabase (PostgreSQL gestionado + PostgREST + GoTrue)"],
    ["SDK de acceso", "supabase_flutter 2.18.3"],
    ["Formato de datos", "JSON (no estructurado / semi-estructurado)"],
    ["Publico objetivo", "Administradores, instructores (coach) y socios"],
    ["Modulo demo", "Base en memoria (login admin@fitcore.com / admin123)"],
])

encabezado(doc, "2.1 Modulos funcionales reales", 2)
parrafo(doc, "El panel administrativo contiene 11 pantallas verificables en lib/pantallas/admin/:")
vinetas(doc, [
    "Inicio (panel/dashboard)", "Clientes (socios)", "Instructores (coach)",
    "Clases dirigidas", "Rutinas", "Membresias", "Pagos", "Avisos",
    "Informacion del gimnasio", "Reportes", "Configuracion",
])

encabezado(doc, "2.2 Modelo de datos real (tablas en Supabase)", 2)
parrafo(doc, "Definido en supabase/esquema.sql y supabase/esquema_extra.sql:")
tabla(doc, ["Tabla", "Campos principales", "Rol en el sistema"], [
    ["usuarios", "id, nombre, apellidos, correo, telefono, rol (admin/coach/socio), activo, especialidad, fecha_registro", "Perfil publico enlazado a auth.users"],
    ["clases", "id, nombre, descripcion, coach_id, coach_nombre, dia_semana, hora, duracion_min, cupo_max, sala, activa", "Clases dirigidas"],
    ["rutinas", "id, nombre, descripcion, coach_id, coach_nombre, nivel, semanas, activa", "Rutinas de entrenamiento"],
    ["membresias", "id, socio_id, socio_nombre, plan, precio, fecha_inicio, fecha_fin, activa", "Membresias de socios"],
    ["pagos", "id, socio_id, socio_nombre, concepto, monto, metodo, fecha, pagado", "Pagos registrados"],
    ["avisos", "id, titulo, contenido, fecha_publicacion, activo, importante", "Avisos y novedades"],
    ["planes", "id, nombre, descripcion, duracion_dias, precio, condiciones, activo", "Tipos de membresia"],
    ["info_gimnasio", "id, nombre, descripcion, direccion, telefono, horarios_atencion, servicios, imagen_url", "Informacion general"],
])
parrafo(doc, (
    "Seguridad: todas las tablas tienen Row Level Security (RLS) habilitado. La "
    "funcion public.es_admin() determina si el usuario autenticado es "
    "administrador. El trigger on_auth_user_created ejecuta public.crear_perfil(), "
    "que crea el perfil en public.usuarios a partir de los metadatos del usuario "
    "recien registrado en Auth."
))

# 3. Justificacion del pipeline
encabezado(doc, "3. Justificacion del flujo de trabajo (pipeline) para la liberacion y despliegue continuo", 1)
encabezado(doc, "3.1 Problema que resuelve", 2)
parrafo(doc, (
    "Antes de automatizar, el equipo compilaba y distribuia el APK de forma "
    "manual, con riesgo de 'funciona en mi maquina', dependencia de credenciales "
    "locales y ausencia de validacion objetiva. FitCore consume servicios remotos "
    "(Supabase) cuya configuracion no debe quedar embebida, administra datos "
    "sensibles (socios, pagos, membresias) y es un proyecto en equipo, por lo que "
    "se requiere una unica fuente de verdad de lo que se libera."
))
encabezado(doc, "3.2 Modelo elegido: GitHub Actions", 2)
parrafo(doc, "Se adopta GitHub Actions por cuatro razones tecnicas:")
vinetas(doc, [
    "Integracion nativa con el repositorio: el pipeline vive en .github/workflows/ci-cd.yml, versionado junto al codigo.",
    "Ejecucion en contenedores limpios: cada job arranca en ubuntu-latest, eliminando el sesgo de la maquina del desarrollador.",
    "Gestion de secretos: las credenciales de Supabase se inyectan como repository secrets, nunca se escriben en el repositorio.",
    "Trazabilidad: cada ejecucion queda asociada a un commit y genera un GitHub Release con el APK adjunto.",
])
encabezado(doc, "3.3 Estrategia de ramas", 2)
tabla(doc, ["Rama", "Proposito", "Efecto en el pipeline"], [
    ["main", "Codigo estable y liberable", "Integracion, pruebas, compilacion y despliegue (Release)"],
    ["develop", "Integracion de trabajo en curso", "Integracion, pruebas y compilacion (sin Release)"],
    ["feature/*", "Trabajo de cada integrante", "Pull Request hacia main con validacion"],
])
encabezado(doc, "3.4 Etapas del pipeline (jobs reales)", 2)
tabla(doc, ["Job", "Nombre", "Que ejecuta", "Artefacto"], [
    ["entorno", "Preparar entorno de liberacion", "Java 17, Flutter 3.47.5, flutter pub get", "pub-deps"],
    ["calidad", "Analisis estatico y formato", "flutter analyze, dart format", "-"],
    ["pruebas", "Pruebas automatizadas y cobertura", "flutter test --coverage", "cobertura"],
    ["api", "Pruebas de API (Postman/Newman)", "newman run sobre la coleccion FitCore", "reporte-api"],
    ["construye", "Compilar APK de liberacion", "flutter build apk --release con --dart-define", "fitcore-apk"],
    ["despliegue", "Desplegar (GitHub Releases)", "Publica el APK como Release", "Release"],
])
encabezado(doc, "3.5 Justificacion de las decisiones", 2)
tabla(doc, ["Decision", "Justificacion tecnica"], [
    ["flutter analyze antes de compilar", "Detecta errores de tipado y lints antes del build (puerta de calidad)."],
    ["Pruebas en modo demo", "Validan UI y modelos sin red ni base de datos (ejecuciones deterministas)."],
    ["Cobertura con --coverage", "Mide objetivamente el codigo ejercitado por las pruebas."],
    ["--dart-define para URL y clave", "Evita credenciales hardcoded; el binario recibe valores al compilar."],
    ["construye depende de calidad y pruebas", "El APK solo se genera si el codigo pasa analisis y pruebas."],
    ["despliegue solo en main y push", "El Release es un acto deliberado sobre la rama estable."],
    ["concurrency con cancel-in-progress", "Cancela ejecuciones obsoletas de la misma rama."],
    ["Pruebas de API con Newman", "Automatiza la coleccion de Postman dentro del pipeline."],
])

# 4. Entorno
encabezado(doc, "4. Entorno requerido para la liberacion y despliegue continuo", 1)
encabezado(doc, "4.1 Arquitectura visual y de trabajo del equipo", 2)
parrafo(doc, "Arquitectura del sistema en capas:")
codigo(doc, (
    "[PRESENTACION]  Flutter/Dart - lib/pantallas, lib/widgets, lib/estado (provider)\n"
    "      |\n"
    "[DATOS]         lib/datos/*_repo.dart, auth_servicio.dart (modo demo/real)\n"
    "      |  HTTPS (JSON)\n"
    "[NUBE]          Supabase: GoTrue + PostgREST + PostgreSQL (RLS, trigger)\n"
    "      ^\n"
    "[CI/CD]         GitHub Actions: pipeline, secrets, artifacts, releases"
))
parrafo(doc, "Reparto del equipo:")
tabla(doc, ["Rol", "Responsabilidad", "Artefactos"], [
    ["Lider de proyecto / DevOps", "Mantiene pipeline, secretos y liberaciones", ".github/workflows/, scripts/"],
    ["Desarrollador frontend", "Pantallas y widgets Flutter", "lib/pantallas/, lib/widgets/"],
    ["Desarrollador backend / datos", "Esquema, RLS, repositorios, API", "supabase/, lib/datos/, lib/modelos/"],
    ["QA / pruebas", "Casos de prueba, pruebas unitarias y de API", "test/, api-tests/"],
])
parrafo(doc, "Flujo de trabajo diario:")
codigo(doc, (
    "1. git checkout -b feature/nombre\n"
    "2. Desarrolla y prueba: flutter test ; flutter analyze\n"
    "3. git push origin feature/nombre\n"
    "4. Abre Pull Request hacia main -> el pipeline valida automaticamente\n"
    "5. Revision por un companero (code review)\n"
    "6. Merge a main -> pipeline compila y libera"
))
parrafo(doc, (
    "Justificacion: la arquitectura separa responsabilidades y permite trabajo "
    "paralelo sin conflictos en la rama principal, garantizando que solo codigo "
    "validado llegue a produccion."
))

encabezado(doc, "4.2 Control de versiones", 2)
tabla(doc, ["Elemento", "Detalle"], [
    ["Sistema", "Git 2.56.0"],
    ["Repositorio remoto", "GitHub"],
    ["Rama principal", "main"],
    ["Ramas de trabajo", "develop, feature/*"],
    ["Estrategia", "GitHub Flow (pull requests + revision)"],
    ["Archivo de exclusion", ".gitignore (Flutter + artefactos de FitCore)"],
])
parrafo(doc, (
    "Justificacion: Git registra la evolucion del codigo con trazabilidad; GitHub "
    "aporta el repositorio remoto y la integracion con Actions, que enlaza cada "
    "commit con una ejecucion del pipeline. El .gitignore evita versionar "
    "artefactos pesados o sensibles."
))

encabezado(doc, "4.3 Entorno de desarrollo (tipo, configuracion, herramientas y lenguaje)", 2)
parrafo(doc, (
    "Tipo: entorno de desarrollo movil multiplataforma en Windows, con compilacion "
    "reproducible en contenedores Linux (Ubuntu) durante el CI."
))
tabla(doc, ["Componente", "Herramienta / version", "Proposito"], [
    ["Lenguaje", "Dart 3.13.4", "Programacion de la app"],
    ["Framework", "Flutter 3.47.5 stable", "UI multiplataforma y toolchain"],
    ["JDK", "OpenJDK 17", "Compilacion Android (Gradle)"],
    ["Android SDK / NDK", "NDK 28.2.13676358", "Empaquetado del APK"],
    ["Editor", "VS Code / Android Studio", "Desarrollo"],
    ["Backend", "Supabase (PostgreSQL gestionado)", "Base de datos remota y API"],
    ["Node.js", "20+ / local v24", "Ejecucion de Newman"],
    ["Control de versiones", "Git 2.56 + GitHub", "Versionado"],
    ["CI/CD", "GitHub Actions", "Pipeline automatizado"],
])
parrafo(doc, "Configuracion (variables y define):")
tabla(doc, ["Parametro", "Tipo", "Origen", "Uso"], [
    ["SUPABASE_URL", "Secreto / --dart-define", "GitHub Secrets / entorno", "URL del proyecto Supabase"],
    ["SUPABASE_ANON_KEY", "Secreto / --dart-define", "GitHub Secrets / entorno", "Clave publica anonima"],
    ["FITCORE_TEST_EMAIL", "Secreto", "GitHub Secrets", "Usuario de prueba para Newman"],
    ["FITCORE_TEST_PASSWORD", "Secreto", "GitHub Secrets", "Contrasena del usuario de prueba"],
    ["FLUTTER_VERSION", "Variable de pipeline", "ci-cd.yml", "Version de Flutter (3.47.5)"],
    ["JAVA_VERSION", "Variable de pipeline", "ci-cd.yml", "Version de Java (17)"],
    ["NODE_VERSION", "Variable de pipeline", "ci-cd.yml", "Version de Node (20)"],
])
parrafo(doc, (
    "Configuracion de la app: lib/core/config_supabase.dart resuelve URL y clave "
    "solo desde --dart-define; si faltan, FitCore arranca en modo demo con datos "
    "en memoria. El entorno funciona sin backend para desarrollo y pruebas, y "
    "contra Supabase real para produccion."
))
parrafo(doc, (
    "Justificacion: se eligio Flutter por su base de codigo unica; Supabase por "
    "ofrecer PostgreSQL gestionado con API JSON y RLS sin infraestructura propia; "
    "y el patron 'backend opcional + modo demo' para desarrollar sin credenciales "
    "ni conectividad, haciendo el pipeline determinista."
))

encabezado(doc, "4.4 Parametros de configuracion de las herramientas", 2)
tabla(doc, ["Herramienta", "Archivo", "Parametros clave"], [
    ["Flutter", "pubspec.yaml", "name: fitcore, version 1.0.0+1, sdk ^3.13.4, supabase_flutter 2.18.3, provider 6.1.5+1, intl 0.20.3, assets images/"],
    ["Analisis Dart", "analysis_options.yaml", "Reglas de flutter_lints 6.0.0"],
    ["Android", "android/app/build.gradle.kts", "applicationId com.fitcore.fitcore, Java 17, ndkVersion 28.2.13676358"],
    ["GitHub Actions", ".github/workflows/ci-cd.yml", "on push/PR/workflow_dispatch, concurrency, 6 jobs, --dart-define"],
    ["Newman", "api-tests/FitCore.postman_collection.json", "Variables baseUrl, anonKey, email, password, token, userId"],
    ["Supabase RLS", "supabase/esquema*.sql", "Funcion es_admin(), politicas por tabla y rol"],
    ["Git/DevOps", ".gitignore", "Excluye build/, .dart_tool/, coverage/, *.log, reports/"],
])
parrafo(doc, (
    "Justificacion: centralizar la configuracion en archivos versionados garantiza "
    "que cualquier integrante y el pipeline reproduzcan el mismo entorno."
))

# 5. SLA
encabezado(doc, "5. Niveles de servicio acordados (SLA)", 1)
tabla(doc, ["Indicador (SLA)", "Meta acordada", "Forma de medicion"], [
    ["Disponibilidad mensual del backend", ">= 99.9 %", "Uptime Supabase + healthcheck"],
    ["Tiempo de respuesta lecturas (p95)", "<= 500 ms", "Aserciones Newman + monitoreo"],
    ["Tiempo de autenticacion (p95)", "<= 2000 ms", "Prueba Sign in + instrumentacion"],
    ["Tiempo de arranque de la app", "<= 3 s", "Medicion en dispositivo de referencia"],
    ["Frecuencia de despliegue", ">= 1 por semana", "Releases del pipeline"],
    ["Cobertura de pruebas", ">= 60 %", "flutter test --coverage (lcov)"],
    ["RTO (recuperacion)", "<= 4 horas", "Plan de recuperacion documentado"],
    ["RPO (punto de recuperacion)", "<= 24 horas", "Respaldo diario de la base"],
    ["Errores 5xx tolerados", "< 1 %", "Monitoreo de la API"],
])

encabezado(doc, "5.1 Indicadores de disponibilidad del sistema", 2)
parrafo(doc, (
    "Meta: 99.9 % mensual (~43 min de indisponibilidad tolerada). Justificacion: "
    "el gimnasio opera 07:00-21:00; una indisponibilidad mayor impediria consultar "
    "clases, membresias y registrar pagos. Se verifica con la prueba 'Health - "
    "REST responde' de Newman y el panel de estado de Supabase."
))

encabezado(doc, "5.2 Tiempo de respuesta", 2)
tabla(doc, ["Operacion", "Meta (p95)", "Justificacion"], [
    ["Login (GoTrue)", "<= 2000 ms", "Umbral de percepcion aceptable en autenticacion"],
    ["Lecturas (PostgREST)", "<= 500 ms", "Consultas indexadas sobre tablas pequenas"],
    ["Arranque de app", "<= 3 s", "Incluye init de Supabase; timeout de 12 s con degradacion"],
])
parrafo(doc, "Se verifican con aserciones pm.response.responseTime en Newman.")

encabezado(doc, "5.3 Pruebas y tolerancia a errores", 2)
vinetas(doc, [
    "Unitarias y de modelo: Usuario.desdeMapa, Rol.desde, Formato (widget_test.dart).",
    "Widget/interfaz: login, validacion, adaptabilidad en 6 tamanos, 11 pantallas (panel_admin_test.dart).",
    "De contrato API: respuestas de Supabase (Newman).",
    "Estado real verificado: flutter analyze -> 0 issues; flutter test -> 84 pruebas aprobadas.",
    "Tolerancia: la capa de datos traduce AuthException/PostgrestException a mensajes de negocio; ante fallo de init la app no cae.",
])

encabezado(doc, "5.4 Recuperacion y cancelacion de recuperacion", 2)
parrafo(doc, (
    "RTO <= 4 horas. Cancelacion de recuperacion: si el fallo se debe a un cambio "
    "de codigo defectuoso, se cancela la restauracion de datos y se hace rollback "
    "de liberacion (revertir al ultimo Release estable). Justificacion: restaurar "
    "datos no corrige un bug y revertir codigo no repara datos corruptos."
))

encabezado(doc, "5.5 Perdida de datos", 2)
parrafo(doc, (
    "RPO <= 24 horas (respaldo diario de PostgreSQL gestionado por Supabase) + "
    "exportacion periodica del esquema (supabase/esquema.sql). Justificacion: los "
    "datos de socios, pagos y membresias son el activo critico; los scripts de "
    "esquema versionados permiten reconstruir la estructura."
))

# 6. Metricas
encabezado(doc, "6. Metricas para el monitoreo de la aplicacion", 1)
tabla(doc, ["Metrica", "Descripcion", "Fuente", "Umbral"], [
    ["Latencia p95", "Tiempo de respuesta del 95 % de peticiones", "Newman + Supabase", "> 800 ms"],
    ["Tasa de error", "Porcentaje de respuestas 4xx/5xx", "Logs de API", "> 1 %"],
    ["Disponibilidad", "Uptime del servicio", "Healthcheck", "< 99.9 %"],
    ["Usuarios activos", "Socios con activo = true", "Tabla usuarios", "Tendencia a la baja"],
    ["Pagos registrados", "Numero/importe de pagos", "Tabla pagos", "Sin pagos en 24 h"],
    ["Cobertura de pruebas", "Lineas cubiertas", "coverage/lcov.info", "< 60 %"],
    ["Estado del pipeline", "Exito/fallo por ejecucion", "GitHub Actions", "Fallo en main"],
    ["Tamano del APK", "Peso del artefacto", "Artifact fitcore-apk", "> 60 MB"],
])
parrafo(doc, (
    "Justificacion: las metricas tecnicas detectan degradacion antes de que el "
    "usuario la perciba; las de negocio indican la salud operativa del gimnasio."
))

# 7. Herramienta
encabezado(doc, "7. Herramienta de liberacion continua configurada y vinculada al entorno de despliegue", 1)
parrafo(doc, (
    "Herramienta: GitHub Actions, vinculada al repositorio en GitHub y al entorno "
    "de despliegue de Supabase. Todos los archivos estan integrados en el "
    "repositorio y verificados."
))
codigo(doc, (
    "Repositorio GitHub (D:\\src\\fitcore -> origin/main)\n"
    "   | push / PR\n"
    "GitHub Actions (.github/workflows/ci-cd.yml)\n"
    "   | usa secrets\n"
    "Secrets: SUPABASE_URL, SUPABASE_ANON_KEY, FITCORE_TEST_EMAIL, FITCORE_TEST_PASSWORD\n"
    "   | --dart-define\n"
    "APK de FitCore\n"
    "   | artifact + Release\n"
    "GitHub Releases -> Descarga / despliegue"
))

encabezado(doc, "7.1 Scripts del flujo de trabajo (pipeline)", 2)
parrafo(doc, "Archivo: .github/workflows/ci-cd.yml (6 jobs). Resumen:")
codigo(doc, (
    "name: FitCore CI/CD\n"
    "on:\n"
    "  push:        { branches: [main, develop] }\n"
    "  pull_request:{ branches: [main] }\n"
    "  workflow_dispatch:\n"
    "concurrency:  { group: fitcore-${{ github.ref }}, cancel-in-progress: true }\n"
    "env: { FLUTTER_VERSION: '3.47.5', JAVA_VERSION: '17', NODE_VERSION: '20' }\n"
    "jobs: entorno, calidad, pruebas, api, construye, despliegue"
))
parrafo(doc, "Justificacion: script maestro que define disparadores, evita ejecuciones concurrentes y orquesta las seis etapas por dependencias (needs).")

encabezado(doc, "7.2 Scripts para la generacion del entorno de liberacion", 2)
parrafo(doc, "Archivos: scripts/preparar_entorno.sh y scripts/preparar_entorno.bat")
codigo(doc, (
    "#!/usr/bin/env bash\n"
    "set -euo pipefail\n"
    "git --version\n"
    "flutter --version\n"
    "java -version\n"
    "command -v node >/dev/null 2>&1 && node --version || echo 'ADVERTENCIA: Node no instalado'\n"
    "flutter pub get\n"
    "echo 'Entorno de liberacion listo.'"
))
parrafo(doc, "Justificacion: automatiza la preparacion y falla temprano si falta un componente del toolchain.")

encabezado(doc, "7.3 Scripts de pruebas en el entorno de liberacion", 2)
parrafo(doc, "Archivos: scripts/ejecutar_pruebas.sh y scripts/ejecutar_pruebas.bat")
codigo(doc, (
    "#!/usr/bin/env bash\n"
    "set -euo pipefail\n"
    "flutter analyze\n"
    "flutter test --coverage\n"
    "if [ -f coverage/lcov.info ]; then\n"
    "  awk -F: '/LF:/{lf+=$2} /LH:/{lh+=$2} END {if (lf>0) printf \"Cobertura: %.2f%%\\n\", (lh/lf)*100}' coverage/lcov.info\n"
    "fi"
))
parrafo(doc, "Justificacion: unifica analisis + pruebas en un comando reproducible y calcula cobertura para comparar contra el SLA (>= 60 %).")

encabezado(doc, "7.4 Scripts para la generacion del despliegue", 2)
parrafo(doc, "Archivos: scripts/generar_despliegue.sh y scripts/generar_despliegue.bat")
codigo(doc, (
    "#!/usr/bin/env bash\n"
    "set -euo pipefail\n"
    ": \"${SUPABASE_URL:?Define SUPABASE_URL}\"\n"
    ": \"${SUPABASE_ANON_KEY:?Define SUPABASE_ANON_KEY}\"\n"
    "flutter build apk --release \\\n"
    "  --dart-define=SUPABASE_URL=\"${SUPABASE_URL}\" \\\n"
    "  --dart-define=SUPABASE_ANON_KEY=\"${SUPABASE_ANON_KEY}\""
))
parrafo(doc, "Justificacion: genera el artefacto inyectando credenciales por --dart-define y falla si faltan, garantizando el backend correcto.")

encabezado(doc, "7.5 Pruebas de API con Postman/Newman", 2)
parrafo(doc, "Archivos: api-tests/FitCore.postman_collection.json y api-tests/FitCore.postman_environment.json")
parrafo(doc, "Ejecucion local:")
codigo(doc, (
    "newman run api-tests/FitCore.postman_collection.json \\\n"
    "  -e api-tests/FitCore.postman_environment.json \\\n"
    "  --env-var \"baseUrl=https://TU-PROYECTO.supabase.co\" \\\n"
    "  --env-var \"anonKey=TU_ANON_KEY\" \\\n"
    "  --env-var \"email=tu-usuario@fitcore.com\" \\\n"
    "  --env-var \"password=tu-password\" \\\n"
    "  --reporters cli,htmlextra --reporter-htmlextra-export reports/api-report.html"
))
tabla(doc, ["Grupo", "Peticion", "Endpoint", "Asercion"], [
    ["Autenticacion", "Health REST", "GET /rest/v1/", "200, < 1500 ms"],
    ["Autenticacion", "Sign in", "POST /auth/v1/token?grant_type=password", "200, access_token, user"],
    ["Autenticacion", "Login invalido", "POST /auth/v1/token", "400"],
    ["PostgREST", "usuarios", "GET /rest/v1/usuarios", "200, arreglo"],
    ["PostgREST", "clases", "GET /rest/v1/clases", "200, arreglo"],
    ["PostgREST", "membresias", "GET /rest/v1/membresias", "200, arreglo"],
    ["PostgREST", "pagos", "GET /rest/v1/pagos", "200, arreglo"],
    ["PostgREST", "avisos", "GET /rest/v1/avisos", "200, arreglo"],
    ["PostgREST", "planes", "GET /rest/v1/planes", "200, arreglo"],
    ["PostgREST", "info_gimnasio", "GET /rest/v1/info_gimnasio", "200, arreglo"],
    ["Seguridad", "Sin token (RLS)", "GET /rest/v1/usuarios", "401/403"],
])
parrafo(doc, "Justificacion: valida el contrato app<->Supabase de forma independiente a la UI y demuestra que RLS esta activo.")

# 8. Casos de prueba
encabezado(doc, "8. Casos de prueba", 1)
encabezado(doc, "8.1 Casos automatizados (Flutter)", 2)
tabla(doc, ["ID", "Caso", "Resultado esperado", "Estado"], [
    ["CP-01", "Rol.desde con valores desconocidos", "Devuelve socio", "Aprobado"],
    ["CP-02", "Usuario.desdeMapa tolera campos ausentes", "Valores por defecto", "Aprobado"],
    ["CP-03", "Usuario.desdeMapa con fila real", "Mapeo correcto", "Aprobado"],
    ["CP-04", "Formato.dinero / Formato.fecha", "Formato es-MX", "Aprobado"],
    ["CP-05", "Login sin backend muestra la pantalla", "Botones visibles", "Aprobado"],
    ["CP-06", "Validacion de campos vacios", "Mensajes locales", "Aprobado"],
    ["CP-07", "Validacion de formato de correo", "Correo no valido", "Aprobado"],
    ["CP-08", "Cambio de rol de acceso", "Rol cambia", "Aprobado"],
    ["CP-09", "Adaptabilidad en 6 tamanos", "Sin desbordes", "Aprobado"],
    ["CP-10", "11 pantallas x 6 tamanos", "Sin excepciones", "Aprobado"],
])
parrafo(doc, "Evidencia de ejecucion real: flutter analyze -> No issues found; flutter test -> +84 All tests passed!")
encabezado(doc, "8.2 Casos de prueba de API (Newman)", 2)
tabla(doc, ["ID", "Caso", "Endpoint", "Resultado esperado"], [
    ["API-01", "Servicio REST disponible", "GET /rest/v1/", "200"],
    ["API-02", "Login valido", "POST /auth/v1/token", "200 + token"],
    ["API-03", "Login con clave incorrecta", "POST /auth/v1/token", "400"],
    ["API-04", "Lectura autenticada de tablas", "GET /rest/v1/{tabla}", "200 + arreglo"],
    ["API-05", "Bloqueo por RLS sin token", "GET /rest/v1/usuarios", "401/403"],
])

# 9. Evidencias
encabezado(doc, "9. Evidencias (capturas requeridas)", 1)
parrafo(doc, "Capturas para demostrar configuracion y funcionamiento:")
encabezado(doc, "9.1 Control de versiones y repositorio", 2)
vinetas(doc, ["git log --oneline con el commit del pipeline.",
              "Repositorio en GitHub con la estructura del proyecto y la rama main.",
              "Pull Request de ejemplo con la validacion del pipeline."])
encabezado(doc, "9.2 GitHub Actions (pipeline)", 2)
vinetas(doc, ["Pestana Actions con la lista de ejecuciones de FitCore CI/CD.",
              "Detalle de una ejecucion exitosa con los 6 jobs en verde.",
              "Panel de Secrets mostrando los nombres (sin valores): SUPABASE_URL, SUPABASE_ANON_KEY, FITCORE_TEST_EMAIL, FITCORE_TEST_PASSWORD."])
encabezado(doc, "9.3 Pruebas en el entorno de liberacion", 2)
vinetas(doc, ["Terminal con flutter analyze (No issues found).",
              "Terminal con flutter test --coverage (+84 All tests passed!).",
              "Archivo coverage/lcov.info generado."])
encabezado(doc, "9.4 Pruebas de API", 2)
vinetas(doc, ["Postman con la coleccion importada y el runner en verde.",
              "Terminal con la ejecucion de Newman y su resumen.",
              "Reporte HTML de Newman abierto en el navegador."])
encabezado(doc, "9.5 Artefactos y despliegue", 2)
vinetas(doc, ["Artifact fitcore-apk descargado del pipeline.",
              "Seccion Releases de GitHub con el APK adjunto.",
              "App FitCore instalada y funcionando."])
encabezado(doc, "9.6 Backend Supabase", 2)
vinetas(doc, ["Table Editor de Supabase con las 8 tablas creadas.",
              "RLS activa en las tablas.",
              "Usuario de prueba registrado y habilitado para las pruebas de API."])

# 10. Conclusion
encabezado(doc, "10. Conclusion", 1)
parrafo(doc, (
    "FitCore evoluciono de un proceso de compilacion manual a un flujo CI/CD "
    "automatizado y trazable mediante GitHub Actions. El pipeline valida la "
    "calidad (flutter analyze), ejecuta 84 pruebas automatizadas con cobertura, "
    "verifica el contrato de la API contra Supabase con Newman, compila el APK con "
    "las credenciales inyectadas de forma segura (--dart-define) y publica el "
    "artefacto como Release en la rama estable."
))
parrafo(doc, (
    "La arquitectura (Flutter + repositorios con modo demo/real + Supabase como "
    "base de datos no relacional en la nube) responde al objetivo del RA: gestionar "
    "datos no estructurados (JSON) en repositorios remotos dentro de un pipeline "
    "confiable. Los SLA quedan con metas medibles y las metricas permiten detectar "
    "degradaciones a tiempo."
))
parrafo(doc, (
    "En conjunto, el proyecto cumple con todos los entregables solicitados (scripts "
    "de pipeline, entorno, pruebas y despliegue, mas la herramienta de liberacion "
    "continua configurada y vinculada al entorno) y queda listo para implementar, "
    "probar y presentar."
))

# 11. Referencias
encabezado(doc, "11. Referencias bibliograficas", 1)
vinetas(doc, [
    "Supabase. (2026). Supabase Documentation: PostgREST, GoTrue y Row Level Security. https://supabase.com/docs",
    "Google. (2026). Flutter Documentation. https://docs.flutter.dev",
    "Dart Team. (2026). Dart Language Tour. https://dart.dev/guides",
    "GitHub. (2026). GitHub Actions Documentation. https://docs.github.com/actions",
    "Postman. (2026). Newman - Command Line Collection Runner. https://learning.postman.com/docs/collections/using-newman-cli/",
    "Git. (2026). Git Reference. https://git-scm.com/docs",
    "OWASP Foundation. (2026). Secrets Management Cheat Sheet. https://cheatsheetseries.owasp.org",
    "PostgreSQL Global Development Group. (2026). PostgreSQL Documentation. https://www.postgresql.org/docs/",
])

salida = r"D:\src\fitcore\docs\RA_U2_FitCore.docx"
doc.save(salida)
print("Documento generado:", salida)
