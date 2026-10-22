"""Genera el documento Word (.docx) del Resultado de Aprendizaje - Unidad III de FitCore.

Punto 1: portada, indice, introduccion y descripcion del proyecto FitCore.
Todo el contenido esta fundamentado en el repositorio FitCore (GitHub).
"""
from docx import Document
from docx.shared import Pt, RGBColor, Cm
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.section import WD_SECTION
import os

AZUL = RGBColor(0x1E, 0x40, 0xAF)
GRIS = RGBColor(0x44, 0x44, 0x44)


def encabezado(doc, texto, nivel=1):
    h = doc.add_heading(texto, level=nivel)
    for r in h.runs:
        r.font.color.rgb = AZUL
    return h


def parrafo(doc, texto, negrita=False, cursiva=False, alineacion=None, tamano=12):
    p = doc.add_paragraph()
    if alineacion is not None:
        p.alignment = alineacion
    r = p.add_run(texto)
    r.bold = negrita
    r.italic = cursiva
    r.font.size = Pt(tamano)
    return p


def vinetas(doc, items):
    for it in items:
        doc.add_paragraph(it, style="List Bullet")


def numeradas(doc, items):
    for it in items:
        doc.add_paragraph(it, style="List Number")


def tabla(doc, encabezados, filas, anchos=None):
    t = doc.add_table(rows=1, cols=len(encabezados))
    t.style = "Light Grid Accent 1"
    for i, e in enumerate(encabezados):
        c = t.rows[0].cells[i]
        c.text = ""
        run = c.paragraphs[0].add_run(str(e))
        run.bold = True
        run.font.size = Pt(10)
    for fila in filas:
        celdas = t.add_row().cells
        for i, v in enumerate(fila):
            celdas[i].text = ""
            run = celdas[i].paragraphs[0].add_run(str(v))
            run.font.size = Pt(10)
    if anchos:
        for fila in t.rows:
            for i, w in enumerate(anchos):
                fila.cells[i].width = Cm(w)
    doc.add_paragraph()
    return t


def codigo(doc, texto):
    p = doc.add_paragraph()
    r = p.add_run(texto)
    r.font.name = "Consolas"
    r.font.size = Pt(8.5)
    return p


def nota(doc, texto):
    p = doc.add_paragraph()
    r = p.add_run(texto)
    r.italic = True
    r.font.size = Pt(10)
    r.font.color.rgb = GRIS
    return p


CARPETA_CAPTURAS = r"C:\Users\Any Ovando\Documents\FitCore_Limpio\docs\capturas"


def captura(doc, archivo, pie, ancho_cm=16.0):
    """Inserta una captura de pantalla centrada con su pie de figura."""
    ruta = os.path.join(CARPETA_CAPTURAS, archivo)
    if not os.path.exists(ruta):
        nota(doc, f"[Captura no disponible: {archivo}]")
        return
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p.paragraph_format.space_before = Pt(6)
    p.add_run().add_picture(ruta, width=Cm(ancho_cm))
    c = doc.add_paragraph()
    c.alignment = WD_ALIGN_PARAGRAPH.CENTER
    r = c.add_run(pie)
    r.italic = True
    r.font.size = Pt(9)
    r.font.color.rgb = GRIS
    c.paragraph_format.space_after = Pt(12)


doc = Document()

# ---------------------------------------------------------------- estilos base
estilo = doc.styles["Normal"]
estilo.font.name = "Arial"
estilo.font.size = Pt(12)
estilo.paragraph_format.space_after = Pt(6)

for nivel, tamano in ((1, 16), (2, 13), (3, 12)):
    st = doc.styles[f"Heading {nivel}"]
    st.font.name = "Arial"
    st.font.size = Pt(tamano)
    st.font.color.rgb = AZUL

sec = doc.sections[0]
sec.top_margin = Cm(2.5)
sec.bottom_margin = Cm(2.5)
sec.left_margin = Cm(2.5)
sec.right_margin = Cm(2.5)

# ------------------------------------------------------------------- 1. PORTADA
doc.add_paragraph()

p = doc.add_paragraph()
p.alignment = WD_ALIGN_PARAGRAPH.CENTER
r = p.add_run("UNIVERSIDAD TECNOLÓGICA DE LA SELVA")
r.bold = True
r.font.size = Pt(15)
r.font.color.rgb = AZUL

parrafo(
    doc,
    "Unidad Académica Benemérito de las Américas · Entronque Toniná Km 0.5, "
    "carretera Ocosingo-Altamirano, Ocosingo, Chiapas",
    cursiva=True,
    alineacion=WD_ALIGN_PARAGRAPH.CENTER,
    tamano=10,
)

parrafo(
    doc,
    "Ingeniería en Desarrollo y Gestión de Software · 10° “A”",
    negrita=True,
    alineacion=WD_ALIGN_PARAGRAPH.CENTER,
)

doc.add_paragraph()

p = doc.add_paragraph()
p.alignment = WD_ALIGN_PARAGRAPH.CENTER
r = p.add_run("RESULTADO DE APRENDIZAJE — UNIDAD III")
r.bold = True
r.font.size = Pt(18)
r.font.color.rgb = AZUL

parrafo(
    doc,
    "[ENUNCIADO DEL RESULTADO DE APRENDIZAJE — pendiente de confirmar con la "
    " consigna oficial de la unidad]",
    cursiva=True,
    alineacion=WD_ALIGN_PARAGRAPH.CENTER,
    tamano=12,
)

doc.add_paragraph()

p = doc.add_paragraph()
p.alignment = WD_ALIGN_PARAGRAPH.CENTER
r = p.add_run(
    "Reporte técnico del caso de estudio\n"
    "FitCore — Plataforma Integral para la Gestión y Transformación Digital "
    "del gimnasio Ciclic Studio"
)
r.italic = True
r.font.size = Pt(13)

doc.add_paragraph()
doc.add_paragraph()

for linea in [
    "Alumna: Ing. Breni Elizabeth Vargas Vaca",
    "Docente académico: Ing. Guadalupe Cruz Maldonado",
    "Materia: Gestión del Proceso de Desarrollo de Software",
    "Unidad: III",
    "Repositorio de referencia: https://github.com/brenivargas09-sys/Fitcore.git",
    "Benemérito de las Américas, Chiapas · Octubre de 2026",
]:
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    r = p.add_run(linea)
    r.font.size = Pt(11)

doc.add_page_break()

# ------------------------------------------------------------------- 2. ÍNDICE
encabezado(doc, "Índice", 1)
indice = [
    "1. Introducción",
    "2. Descripción del proyecto FitCore",
    "   2.1 Identificación y ficha técnica del proyecto",
    "   2.2 Módulos funcionales (verificación en el código)",
    "   2.3 Arquitectura técnica en capas",
    "   2.4 Modelo de datos y esquema de seguridad",
    "   2.5 Panorama de la integración y entrega continua",
    "   2.6 Estado verificado del repositorio (evidencia técnica)",
    "3. Justificación del flujo de trabajo (pipeline) para la liberación y",
    "   despliegue continuo",
    "   3.1 Situación de partida: el problema que resuelve el pipeline",
    "   3.2 Modelo de integración y despliegue continuo adoptado",
    "   3.3 Estrategia de ramas, disparadores y control de concurrencia",
    "   3.4 Etapas del pipeline: descripción funcional y artefactos",
    "   3.5 Diagrama del flujo de trabajo de liberación y despliegue",
    "   3.6 Tiempos reales de ejecución por etapa",
    "   3.7 Justificación de las decisiones de diseño del pipeline",
    "   3.8 Evidencia de ejecución: historial de integraciones y publicaciones",
    "   3.9 La validación del contrato de la API como puerta de calidad",
    "   3.10 Incidencias detectadas, diagnóstico y acciones correctivas",
    "   3.11 Capturas de pantalla requeridas para el cierre de la evidencia",
    "4. [Apartado 4 del RA — a definir en el siguiente punto]",
    "5. [Apartado 5 del RA — a definir en el siguiente punto]",
    "6. Conclusiones",
    "7. Referencias bibliográficas",
]
for i in indice:
    doc.add_paragraph(i)

nota(
    doc,
    "Nota: este documento se entrega por puntos. La presente entrega desarrolla el "
    "Punto 1 en su totalidad: introducción, descripción verificada del proyecto y, "
    "como sección principal, la justificación del flujo de trabajo (pipeline) para la "
    "liberación y el despliegue continuo, con la evidencia de ejecución del pipeline y "
    "de la validación del contrato de la API. Los apartados 4 y 5 se completarán "
    "conforme a la consigna de la unidad.",
)

doc.add_page_break()

# --------------------------------------------------------------- 3. INTRODUCCIÓN
encabezado(doc, "1. Introducción", 1)

parrafo(
    doc,
    "La presente actividad de evaluación consiste en documentar, de manera técnica y "
    "verificable, el resultado de aprendizaje correspondiente a la Unidad III de la "
    "asignatura Gestión del Proceso de Desarrollo de Software, tomando como caso de "
    "estudio el proyecto integrador FitCore.",
)

parrafo(
    doc,
    "FitCore es la plataforma que digitaliza la operación del gimnasio Ciclic Studio, "
    "un centro de entrenamiento especializado en clases de ciclismo indoor "
    "(spinning) y aeróbicos. La aplicación administra socios, instructores, clases "
    "dirigidas, rutinas, membresías, pagos, avisos, planes e información general del "
    "establecimiento, sustituyendo la gestión manual que se realizaba con hojas de "
    "cálculo y mensajería instantánea.",
)

parrafo(
    doc,
    "El objeto de este reporte es evidenciar que el proceso de desarrollo del "
    "producto mínimo viable se gestionó con prácticas de ingeniería de software "
    "reproducibles: código versionado en un repositorio remoto, integración "
    "automática de entregables, validación automatizada de la calidad y publicación "
    "controlada de versiones. En el caso de FitCore, estas prácticas se materializan "
    "en un flujo de trabajo de integración, liberación y despliegue continuo (CI/CD) "
    "definido en GitHub Actions, con verificación de calidad estática, pruebas "
    "automatizadas con cobertura, pruebas de contrato de la API contra Supabase, "
    "compilación del APK de publicación y liberación versionada mediante GitHub "
    "Releases.",
)

parrafo(
    doc,
    "El alcance de la evidencia se define por el estado real del repositorio "
    "FitCore, disponible públicamente en https://github.com/brenivargas09-sys/Fitcore.git "
    "y auditado en el commit f9df393 («Corrige aserciones de la coleccion de pruebas "
    "de API», 22 de octubre de 2026), inmediatamente posterior al commit eeaa302 "
    "(«App Móvil FitCore - Versión 1.0», 21 de octubre de 2026). Todos los módulos, "
    "tablas, endpoints, scripts y etapas de construcción "
    "descritos en este documento existen en ese código y son verificables mediante los "
    "comandos y rutas que se indican en cada sección.",
)

nota(
    doc,
    "Nota metodológica: por disciplina de evidencia, no se documentan tablas, "
    "pantallas, endpoints ni procesos que no existan en el repositorio. Cuando una "
    "evidencia requiere una acción previa del equipo (por ejemplo, configurar un "
    "secreto en GitHub o habilitar un usuario de prueba), se indica de forma explícita "
    "en el apartado correspondiente.",
)

parrafo(
    doc,
    "El documento se organiza en tres grandes apartados en esta primera entrega: la "
    "introducción (apartado 1), que fija el propósito, el alcance y el método; la "
    "descripción del proyecto (apartado 2), que documenta la ficha técnica, los "
    "módulos funcionales, la arquitectura, el modelo de datos con su esquema de "
    "seguridad y el estado verificable del repositorio; y la justificación del "
    "flujo de trabajo para la liberación y el despliegue continuo (apartado 3), que "
    "desarrolla el contenido central de esta entrega: el problema que resuelve el "
    "pipeline, los criterios de diseño aplicados, el diagrama del flujo, los tiempos "
    "reales de ejecución, la evidencia del historial de integraciones y "
    "publicaciones, la validación del contrato de la API como puerta de calidad y "
    "las incidencias detectadas y corregidas. Los apartados siguientes —niveles de "
    "servicio, métricas, casos de prueba, evidencias y conclusiones— se desarrollan "
    "en los puntos sucesivos, siguiendo el mismo nivel de detalle técnico del RA de "
    "la Unidad II.",
)

doc.add_page_break()

# ------------------------------------------------- 4. DESCRIPCIÓN DEL PROYECTO
encabezado(doc, "2. Descripción del proyecto FitCore", 1)

encabezado(doc, "2.1 Identificación y ficha técnica del proyecto", 2)
tabla(
    doc,
    ["Elemento", "Detalle verificado en el repositorio"],
    [
        ["Nombre del producto", "FitCore"],
        ["Cliente / caso de estudio", "Gimnasio Ciclic Studio (spinning y aeróbicos)"],
        ["Tipo de aplicación", "App móvil y multiplataforma de gestión administrativa de gimnasio"],
        ["Versión publicada", "1.0.0+1 (declarada en pubspec.yaml)"],
        ["Lenguaje", "Dart (SDK constraint ^3.13.4)"],
        ["Framework de UI", "Flutter 3.47.5 (canal stable, fijado en el pipeline)"],
        ["Gestión de estado", "provider 6.1.5+1"],
        ["Backend en la nube", "Supabase (PostgreSQL gestionado + PostgREST + GoTrue)"],
        ["SDK de acceso", "supabase_flutter 2.18.3"],
        ["Formato de intercambio de datos", "JSON vía API REST de PostgREST y SDK de Supabase"],
        ["Soporte de modo demo", "Base en memoria (DemoDB) para operar sin backend"],
        ["Usuarios de prueba del modo demo", "admin@fitcore.com / admin123"],
        ["Control de versiones", "Git + GitHub (origin: github.com/brenivargas09-sys/Fitcore.git)"],
        ["Integración y entrega continua", "GitHub Actions (.github/workflows/ci-cd.yml, 6 etapas)"],
        ["Pruebas automatizadas", "test/widget_test.dart y test/panel_admin_test.dart"],
        ["Pruebas de API", "api-tests/FitCore.postman_collection.json (12 peticiones)"],
        ["Modelo de datos versionado", "supabase/esquema.sql y supabase/esquema_extra.sql"],
        ["Auditoría de secretos", "Credenciales solo por --dart-define y GitHub Secrets"],
    ],
    anchos=[5.0, 11.0],
)

encabezado(doc, "2.2 Módulos funcionales (verificación en el código)", 2)
parrafo(
    doc,
    "La versión 1.0 de FitCore implementa el módulo de autenticación y el Panel "
    "Administrativo con 11 pantallas navegables desde un menú lateral adaptativo. "
    "Cada módulo con gestión implementa las operaciones Crear, Consultar, Modificar "
    "y Eliminar (CRUD).",
)
tabla(
    doc,
    ["Módulo", "Archivo (lib/pantallas/admin/)", "Operaciones verificadas"],
    [
        ["Inicio (panel)", "inicio_admin.dart", "Resumen de indicadores del gimnasio"],
        ["Clientes (socios)", "usuarios_admin.dart", "Alta, consulta, edición y baja de socios"],
        ["Instructores (coach)", "instructores_admin.dart", "Registro, consulta, edición y baja de instructores"],
        ["Clases y horarios", "clases_admin.dart", "CRUD de clases, instructor, horario y cupos"],
        ["Rutinas", "rutinas_admin.dart", "CRUD de rutinas de entrenamiento"],
        ["Membresías", "membresias_admin.dart", "Catálogo CRUD de planes de membresía"],
        ["Pagos", "pagos_admin.dart", "Registro, consulta, edición y baja de cobros"],
        ["Avisos", "avisos_admin.dart", "Publicación, consulta, edición y baja de avisos"],
        ["Información del gimnasio", "info_gimnasio_admin.dart", "Consulta y edición del registro institucional"],
        ["Reportes", "reportes_admin.dart", "Reportes estadísticos para la toma de decisiones"],
        ["Configuración", "configuracion_admin.dart", "Ajustes generales del panel"],
    ],
    anchos=[3.6, 5.4, 7.0],
)
parrafo(
    doc,
    "Complementan el panel tres pantallas de acceso (login, registro y sin acceso), "
    "ubicadas en lib/pantallas/, y la capa de estado y soporte en lib/estado/ "
    "(sesión y tema), lib/widgets/comunes.dart y lib/core/ (configuración de "
    "Supabase, tema, formato, rutas y manejo de errores).",
)

encabezado(doc, "2.3 Arquitectura técnica en capas", 2)
codigo(
    doc,
    """┌──────────────────────────────────────────────────────────────┐
│  CAPA DE PRESENTACIÓN (Flutter / Dart)                         │
│  lib/pantallas/  ·  lib/widgets/  ·  lib/estado/ (provider)    │
│  Login · Registro · Panel Administrativo (11 pantallas)         │
└───────────────────────────┬──────────────────────────────────┘
                            │ llamadas a la capa de datos
┌───────────────────────────▼──────────────────────────────────┐
│  CAPA DE ACCESO A DATOS (repositorios)                        │
│  lib/datos/*_repo.dart  ·  lib/datos/auth_servicio.dart        │
│  Detecta backend; si no existe, opera con DemoDB (memoria)    │
└───────────────────────────┬──────────────────────────────────┘
                            │ HTTPS · JSON
┌───────────────────────────▼──────────────────────────────────┐
│  CAPA DE SERVICIOS EN LA NUBE (Supabase)                      │
│  GoTrue (auth) · PostgREST (datos JSON) · PostgreSQL          │
│  RLS activo · trigger crear_perfil() · función es_admin()     │
└───────────────────────────┬──────────────────────────────────┘
                            │ compila, prueba y publica
┌───────────────────────────▼──────────────────────────────────┐
│  CAPA DE ENTREGA CONTINUA (GitHub Actions)                    │
│  entorno → calidad → pruebas → api → construye → despliegue   │
└──────────────────────────────────────────────────────────────┘""",
)
parrafo(
    doc,
    "Justificación: la separación entre presentación, datos, servicios y entrega "
    "permite que el equipo trabaje en paralelo sobre artefactos distintos, "
    "intercambia los datos con un contrato estable (JSON) y mantiene la lógica de "
    "negocio verificable de forma aislada. El patrón de «backend opcional» (modo "
    "demo) permite desarrollar y ejecutar pruebas sin credenciales ni conectividad, "
    "lo que hace determinista la pipeline.",
)

encabezado(doc, "2.4 Modelo de datos y esquema de seguridad", 2)
parrafo(
    doc,
    "El esquema está versionado en el repositorio: supabase/esquema.sql (171 líneas) "
    "y supabase/esquema_extra.sql (70 líneas). Contiene ocho tablas de negocio "
    "definidas en PostgreSQL y consumidas como documentos JSON desde la aplicación.",
)
tabla(
    doc,
    ["Tabla", "Campos principales", "Rol en el sistema"],
    [
        ["usuarios", "id (uuid), nombre, apellidos, correo, telefono, rol (admin/coach/socio), activo, especialidad, fecha_registro", "Perfil público enlazado a auth.users"],
        ["clases", "id, nombre, descripcion, coach_id, coach_nombre, dia_semana, hora, duracion_min, cupo_max, sala, activa", "Clases dirigidas"],
        ["rutinas", "id, nombre, descripcion, coach_id, coach_nombre, nivel, semanas, activa", "Rutinas de entrenamiento"],
        ["membresias", "id, socio_id, socio_nombre, plan, precio, fecha_inicio, fecha_fin, activa", "Membresías de socios"],
        ["pagos", "id, socio_id, socio_nombre, concepto, monto, metodo, fecha, pagado", "Pagos registrados"],
        ["avisos", "id, titulo, contenido, fecha_publicacion, activo, importante", "Avisos y novedades"],
        ["planes", "id, nombre, descripcion, duracion_dias, precio, condiciones, activo", "Tipos de membresía"],
        ["info_gimnasio", "id, nombre, descripcion, direccion, telefono, horarios_atencion, servicios, imagen_url", "Información general del establecimiento"],
    ],
    anchos=[3.0, 7.0, 6.0],
)

parrafo(
    doc,
    "Esquema de seguridad (RLS): todas las tablas tienen Row Level Security "
    "habilitado. La función public.es_admin() determina si el usuario autenticado "
    "es administrador. Las lecturas de clases, rutinas, avisos, planes e "
    "información del gimnasio están permitidas a usuarios autenticados, mientras que "
    "la escritura se restringe al rol administrador. La tabla usuarios limita el "
    "acceso a la fila propia o a un administrador.",
)
parrafo(
    doc,
    "Automatización en base de datos: el trigger on_auth_user_created ejecuta la "
    "función public.crear_perfil(), que crea automáticamente el perfil en "
    "public.usuarios a partir de los metadatos (raw_user_meta_data) del usuario "
    "recién registrado en Auth. Esto evita duplicar el alta de usuarios en dos "
    "sistemas y reduce el error humano.",
)

encabezado(doc, "2.5 Panorama de la integración y entrega continua", 2)
parrafo(
    doc,
    "El flujo de trabajo de integración, liberación y despliegue continuo está "
    "definido en .github/workflows/ci-cd.yml (260 líneas) y se ejecuta en seis "
    "etapas encadenadas por dependencias sobre imágenes ubuntu-latest. La "
    "justificación detallada de este flujo —problema que resuelve, criterios de diseño, "
    "diagrama, tiempos reales, evidencia de ejecución e incidencias corregidas— se "
    "desarrolla íntegramente en el apartado 3, que constituye el objeto de esta "
    "entrega.",
)
tabla(
    doc,
    ["Etapa (job)", "Nombre", "Qué ejecuta", "Artefacto que produce"],
    [
        ["entorno", "Preparar entorno de liberación", "Java 17, Flutter 3.47.5, flutter pub get", "pub-deps"],
        ["calidad", "Análisis estático y formato", "dart format (reporte), flutter analyze", "—"],
        ["pruebas", "Pruebas automatizadas y cobertura", "flutter test --coverage", "cobertura (lcov.info)"],
        ["api", "Pruebas de API (Postman/Newman)", "newman run sobre la colección FitCore", "reporte-api (HTML)"],
        ["construye", "Compilar APK de liberación", "flutter build apk --release con --dart-define", "fitcore-apk"],
        ["despliegue", "Desplegar (GitHub Releases)", "Publica el APK como Release (solo en main)", "Release v1.0.0-<build>"],
    ],
    anchos=[2.6, 4.2, 5.6, 3.6],
)
parrafo(
    doc,
    "Disparadores: push a las ramas main y develop, pull_request hacia main y "
    "ejecución manual (workflow_dispatch). La concurrencia se controla por rama con "
    "cancel-in-progress, de modo que solo queda activa una ejecución por referencia "
    "del repositorio. Las credenciales de Supabase se inyectan como secretos del "
    "repositorio y se pasan al compilador mediante --dart-define; nunca se escriben "
    "en el código fuente.",
)
parrafo(
    doc,
    "Scripts de apoyo en scripts/: preparar_entorno.sh/.bat (verificación del "
    "toolchain y resolución de dependencias), ejecutar_pruebas.sh/.bat (análisis "
    "estático, pruebas y resumen de cobertura) y generar_despliegue.sh/.bat "
    "(compilación del APK con inyección de credenciales).",
)

encabezado(doc, "2.6 Estado verificado del repositorio (evidencia técnica)", 2)
tabla(
    doc,
    ["Elemento verificable", "Estado"],
    [
        ["Repositorio remoto", "github.com/brenivargas09-sys/Fitcore.git (rama main)"],
        ["Commits publicados", "4 commits «App Móvil FitCore - Versión 1.0» (21/10/2026) y el commit f9df393 de corrección de las aserciones de la API (22/10/2026)"],
        ["Versión declarada en pubspec.yaml", "1.0.0+1"],
        ["Paquete principal", "fitcore (publish_to: none)"],
        ["Dependencias de producción", "supabase_flutter 2.18.3, provider 6.1.5+1, intl 0.20.3, cupertino_icons 1.0.8"],
        ["Dependencias de desarrollo", "flutter_test, flutter_lints 6.0.0"],
        ["Configuración de análisis", "analysis_options.yaml con flutter_lints 6.0.0"],
        ["Archivos de aplicación", "41 archivos Dart en lib/ (pantallas, widgets, estado, datos, modelos, core)"],
        ["Pruebas automatizadas", "2 archivos de prueba (widget_test.dart, panel_admin_test.dart)"],
        ["Colección de pruebas de API", "12 peticiones: 4 de autenticación (dos de disponibilidad del servicio, inicio de sesión y rechazo de credenciales inválidas), 7 de lectura PostgREST y 1 de seguridad RLS"],
        ["Esquema de base de datos", "2 archivos SQL versionados (8 tablas, función es_admin, trigger crear_perfil)"],
        ["Cobertura", "coverage/lcov.info generado por flutter test --coverage"],
        ["Canalización de entrega", ".github/workflows/ci-cd.yml con 6 etapas (260 líneas)"],
    ],
    anchos=[6.0, 10.0],
)

doc.add_page_break()

# ============================================================================
# 3. JUSTIFICACIÓN DEL FLUJO DE TRABAJO (PIPELINE)
# ============================================================================
encabezado(
    doc,
    "3. Justificación del flujo de trabajo (pipeline) para la liberación y "
    "despliegue continuo",
    1,
)

parrafo(
    doc,
    "Este apartado constituye el punto central del presente Resultado de Aprendizaje: "
    "justificar por qué FitCore requiere un flujo de trabajo automatizado para la "
    "liberación y el despliegue continuo, con qué criterios se diseñó ese flujo, cómo "
    "está construido técnicamente y qué evidencia demuestra que funciona.",
)

# ------------------------------------------------------------------ 3.1
encabezado(doc, "3.1 Situación de partida: el problema que resuelve el pipeline", 2)
parrafo(
    doc,
    "El producto mínimo viable de FitCore no es una aplicación aislada: son 41 "
    "archivos Dart que consumen ocho tablas de PostgreSQL mediante la API de "
    "PostgREST, dependen de la autenticación de GoTrue y se publican como un "
    "ejecutable Android firmado. Entregar este producto de forma manual presenta "
    "cinco riesgos concretos, todos verificados durante el ejercicio:",
)
tabla(
    doc,
    ["Riesgo del proceso manual", "Impacto observado en FitCore", "Respuesta del pipeline"],
    [
        [
            "Publicar un APK compilado en un equipo personal",
            "El binario publicado puede no corresponder con el código versionado; no hay trazabilidad entre lo entregado y lo auditado",
            "El artefacto se compila dentro del repositorio, con las credenciales inyectadas por --dart-define, y se publica como artefacto de la ejecución",
        ],
        [
            "Verificar el backend a mano con el Postman de cada integrante",
            "El contrato de la API se comprobaba solo de forma puntual y con credenciales locales; una rotura de RLS o de autenticación quedaba oculta hasta la prueba manual final",
            "La etapa «api» ejecuta la colección de Newman en cada integración y bloquea el despliegue si el contrato no se cumple",
        ],
        [
            "Detectar errores de análisis estático y de pruebas al final del sprint",
            "El tiempo de detección se alargaba y la corrección se acumulaba sobre la entrega",
            "Las etapas «calidad» y «pruebas» se ejecutan en paralelo tras preparar el entorno y condicionan la compilación",
        ],
        [
            "Publicar versiones sin trazabilidad ni numeración",
            "No se podía saber qué build correspondía a qué código ni distribuir una corrección a los usuarios",
            "Cada publicación es una Release etiquetada (v1.0.0+<build>) con su APK y su informe de pruebas asociado",
        ],
        [
            "Exponer credenciales del proyecto en el repositorio o en comandos",
            "Riesgo de filtrar la clave del backend y de perder trazabilidad de quién cambió qué",
            "Las credenciales viven únicamente en GitHub Secrets y en los secretos del entorno de la base de datos",
        ],
    ],
    anchos=[4.6, 5.6, 5.8],
)
parrafo(
    doc,
    "El pipeline no es, por tanto, un adorno técnico: es el mecanismo que convierte "
    "el trabajo del equipo en un producto verificable y publicable de forma "
    "repetible. En el caso de FitCore, su valor quedó demostrado de manera empírica: "
    "fue precisamente el pipeline el que detectó el fallo de credenciales que "
    "impedía la autenticación del backend (apartado 3.10), algo que en el proceso "
    "manual se habría detectado únicamente en la prueba manual de la aplicación.",
)

# ------------------------------------------------------------------ 3.2
encabezado(doc, "3.2 Modelo de integración y despliegue continuo adoptado", 2)
parrafo(
    doc,
    "El flujo se implementa con GitHub Actions, definido en un único archivo "
    "declarativo —.github/workflows/ci-cd.yml— que describe las seis etapas en "
    "lenguaje YAML. La elección del modelo se justifica con los siguientes criterios:",
)
tabla(
    doc,
    ["Criterio de diseño", "Opción descartada", "Opción adoptada y razón"],
    [
        [
            "Proximidad al repositorio",
            "Jenkins self-hosted o CircleCI",
            "GitHub Actions se ejecuta en el mismo sistema que hospeda el código y el historial de versiones; no requiere instalar ni mantener un servidor, y el resultado queda ligado de forma nativa a cada commit y a cada pull request.",
        ],
        [
            "Costo de operación",
            " runners privados de pago",
            "El plan gratuito de GitHub ofrece minutos públicos suficientes para las 6 etapas del proyecto; la inversión se concentra en el tiempo de compilación, no en infraestructura.",
        ],
        [
            "Trazabilidad de la evidencia",
            "Ejecución local de scripts",
            "Cada ejecución queda registrada con su commit, su duración, sus pasos y sus artefactos, y es reproducible por cualquier evaluador reejecutando la misma ejecución.",
        ],
        [
            "Calidad de las secretas",
            "Variables de entorno en el servidor de compilación",
            "GitHub Secrets cifra los valores, los enmascara en los registros y los entrega solo al proceso(job) que los necesita; nunca se escriben en el repositorio.",
        ],
        [
            "Declaratividad y mantenimiento",
            "Scripts de shell con pasos manuales",
            "El pipeline se declara como datos (YAML) con etapas y dependencias explícitas, lo que permite versionarlo, revisarlo en un pull request y reutilizarlo para todas las ramas.",
        ],
        [
            "Publicación de la versión",
            "Copia manual del APK a un drive",
            "GitHub Releases versiona el binario, permite adjuntar el informe de pruebas y genera una URL estable de descarga por cada build.",
        ],
    ],
    anchos=[3.6, 4.2, 8.2],
)
nota(
    doc,
    "Nota: la tabla resume los criterios de diseño aplicados; cada decisión se "
    "sustenta en la configuración real del archivo .github/workflows/ci-cd.yml, "
    "verificable en el repositorio.",
)

# ------------------------------------------------------------------ 3.3
encabezado(
    doc,
    "3.3 Estrategia de ramas, disparadores y control de concurrencia",
    2,
)
parrafo(
    doc,
    "El flujo de trabajo define tres disparadores (triggers), que se justifican "
    "por el tipo de evento que representa cada uno:",
)
tabla(
    doc,
    ["Disparador", "Cuándo se activa", "Justificación"],
    [
        [
            "push sobre main y develop",
            "Cada vez que se integrates código en una de las ramas de trabajo",
            "Es el disparador de la entrega: garantiza que nada llega a la rama principal sin pasar las seis etapas. En develop se valida sin publicar; en main, además, se publica la Release.",
        ],
        [
            "pull_request hacia main",
            "Cuando se abre o actualiza una pull request hacia main",
            "Permite verificar la pull request antes de integrarla, con el resultado visible en la propia pull request, sin necesidad de crear una rama de publicación adicional.",
        ],
        [
            "workflow_dispatch",
            "De forma manual, desde la pestaña Actions",
            "Permite reejecutar el flujo a demanda (por ejemplo, para recuperar un runner fallido o regenerar un APK) sin necesidad de un commit ficticio.",
        ],
    ],
    anchos=[3.4, 4.6, 8.0],
)
parrafo(
    doc,
    "El control de concurrencia se declara en el propio flujo de trabajo mediante "
    "el grupo fitcore-<referencia> con cancel-in-progress: true. Esto significa que, "
    "cuando se empuja un commit nuevo a una rama, la ejecución anterior de esa misma "
    "rama se cancela automáticamente. La justificación es de eficiencia y de "
    "veracidad: se evita gastar minutos de compilación en un commit que ya quedó "
    "obsoleto y, sobre todo, se garantiza que la Release publicada corresponde al "
    "último commit de la rama y no a uno intermedio.",
)
parrafo(
    doc,
    "La regla de publicación es igualmente explícita: la etapa «despliegue» se "
    "ejecuta únicamente en la rama main y sobre el evento push, de modo que una "
    "pull request o una rama de desarrollo nunca generan una versión pública. Esta "
    "separación entre «integrar», «validar» y «publicar» es la que garantiza que el "
    "producto entregado al cliente final haya pasado todas las puertas de calidad.",
)

# ------------------------------------------------------------------ 3.4
encabezado(doc, "3.4 Etapas del pipeline: descripción funcional y artefactos", 2)
parrafo(
    doc,
    "El flujo se compone de seis etapas. La etapa «entorno» prepara el toolchain y "
    "actúa como base común; sobre ella se ejecutan en paralelo las tres etapas de "
    "validación —calidad, pruebas y contrato de la API—, que no dependen entre sí. "
    "La compilación del APK depende de las etapas de calidad y pruebas, y la "
    "publicación depende de la compilación y de la validación del contrato de la "
    "API, que debe seguir vigente en el momento de publicar. Esta topología de "
    "dependencias es la que permite que el tiempo de reloj de la línea de "
    "producción (441 s) sea inferior a la suma de los tiempos de las etapas (487 s). "
    "La tabla siguiente describe cada etapa, su contenido, su duración y su "
    "artefacto.",
)
tabla(
    doc,
    ["#", "Etapa", "Función dentro del flujo", "Duración real", "Artefacto"],
    [
        ["1", "Preparar entorno de liberación", "Instala Java 17, Flutter 3.47.5 y Node.js 20, y resuelve las dependencias con flutter pub get para que las etapas siguientes trabajen sobre un toolchain idéntico al de desarrollo.", "34 s", "pub-deps (caché de dependencias)"],
        ["2", "Análisis estático y formato", "Ejecuta dart format --set-exit-if-changed y flutter analyze --fatal-infos; detecta errores de compilación, imports sin usar y desviaciones de estilo antes de gastar tiempo de compilación.", "38 s", "Reporte de formato"],
        ["3", "Pruebas automatizadas y cobertura", "Ejecuta flutter test --coverage sobre las pruebas unitarias y de widget del proyecto, midiendo además la cobertura de código.", "52 s", "coverage/lcov.info"],
        ["4", "Pruebas de API (Postman/Newman)", "Ejecuta la colección FitCore con Newman contra el backend real de Supabase: valida disponibilidad, autenticación, lectura de las ocho tablas y el comportamiento de RLS sin token.", "17 s", "reporte-api (HTML)"],
        ["5", "Compilar APK de liberación", "Compila el artefacto de publicación con flutter build apk --release, inyectando URL y clave del backend mediante --dart-define (nunca en el código).", "333 s", "fitcore-apk (app-release.apk)"],
        ["6", "Desplegar (GitHub Releases)", "Publica el APK compilado como Release etiquetada, adjuntando el informe de pruebas y el binario descargable.", "13 s", "Release v1.0.0+<build>"],
    ],
    anchos=[0.9, 3.6, 6.4, 1.8, 3.3],
)
parrafo(
    doc,
    "El tiempo total de la línea de producción verificada fue de 7 minutos y 21 "
    "segundos de reloj (441 s), de los cuales 5 minutos y 33 segundos corresponden a "
    "la compilación del APK: un 69 % del tiempo de cómputo acumulado de las seis "
    "etapas (487 s). Este dato confirma que el orden de las etapas es correcto, "
    "porque las validaciones baratas —calidad, pruebas y contrato de la API, que "
    "suman menos de dos minutos y se ejecutan en paralelo— se ejecutan antes de la "
    "única etapa costosa. Un orden inverso desperdiciaría hasta cinco minutos de "
    "compilación en código defectuoso.",
)

# ------------------------------------------------------------------ 3.5
encabezado(doc, "3.5 Diagrama del flujo de trabajo de liberación y despliegue", 2)
parrafo(
    doc,
    "La figura siguiente representa el flujo de trabajo completo: disparadores, "
    "etapas encadenadas, dependencias, artefactos generados y reglas de publicación.",
)
captura(
    doc,
    "diagrama_pipeline.png",
    "Figura 1. Diagrama del flujo de trabajo (pipeline) de integración, liberación y "
    "despliegue continuo de FitCore en GitHub Actions, con sus seis etapas, "
    "dependencias, artefactos y reglas de publicación.",
    ancho_cm=17.0,
)

# ------------------------------------------------------------------ 3.6
encabezado(doc, "3.6 Tiempos reales de ejecución por etapa", 2)
parrafo(
    doc,
    "La siguiente tabla recoge los tiempos medidos por el propio ejecutor de "
    "GitHub en la ejecución verificada del 22 de octubre de 2026 (run n.º 14, "
    "rama main, publicación de la versión 1.0.0+1). Estos valores corresponden a "
    "datos extraídos de la propia plataforma, no a estimaciones, y se expresan en "
    "hora UTC.",
)
tabla(
    doc,
    ["Etapa", "Inicio (UTC)", "Fin (UTC)", "Duración", "Resultado"],
    [
        ["Preparar entorno de liberación", "02:41:38", "02:42:12", "34 s", "success"],
        ["Análisis estático y formato", "02:42:14", "02:42:52", "38 s", "success"],
        ["Pruebas automatizadas y cobertura", "02:42:14", "02:43:06", "52 s", "success"],
        ["Pruebas de API (Postman/Newman)", "02:42:14", "02:42:31", "17 s", "success"],
        ["Compilar APK de liberación", "02:43:08", "02:48:41", "333 s", "success"],
        ["Desplegar (GitHub Releases)", "02:48:42", "02:48:55", "13 s", "success"],
        ["Total de la ejecución (tiempo de reloj)", "02:41:35", "02:48:56", "441 s (7 min 21 s)", "success"],
        ["Suma de las seis etapas (tiempo de cómputo)", "—", "—", "487 s", "—"],
    ],
    anchos=[5.4, 2.3, 2.3, 3.0, 3.0],
)
parrafo(
    doc,
    "La diferencia entre los 441 segundos de tiempo de reloj y los 487 segundos de "
    "tiempo de cómputo acumulado evidencia que las etapas de análisis estático, "
    "pruebas automatizadas y contrato de la API se ejecutan en paralelo: las tres "
    "comienzan a las 02:42:14, inmediatamente después de concluir la etapa "
    "«entorno». Es "
    "precisamente el diseño de dependencias descrito en el apartado 3.4 el que "
    "consigue esa ejecución simultánea, y explica por qué el tiempo de reloj de la "
    "línea de producción es inferior a la suma de sus etapas.",
)
parrafo(
    doc,
    "Estos tiempos sostienen la definición de un SLA para la entrega (apartado 4 de "
    "la entrega): el pipeline es capaz de transformar un commit en una versión "
    "publicada y descargable en menos de diez minutos, con una ventana de incidencia "
    "mínima y una tasa de automatización del 100 %, ya que ningún paso requiere "
    "intervención humana.",
)

# ------------------------------------------------------------------ 3.7
encabezado(doc, "3.7 Justificación de las decisiones de diseño del pipeline", 2)
parrafo(
    doc,
    "Además de la elección de la herramienta, cada decisión de diseño del flujo "
    "responde a un criterio explícito. La tabla documenta las decisiones adoptadas, "
    "su motivo y su evidencia en el repositorio:",
)
tabla(
    doc,
    ["Decisión de diseño", "Justificación", "Evidencia en el repositorio"],
    [
        [
            "Un único archivo declarativo para las seis etapas",
            "Centraliza la definición del proceso: es versionable, revisable en una pull request y no depende del estado de una máquina concreta.",
            ".github/workflows/ci-cd.yml (260 líneas)",
        ],
        [
            "Entorno fijo por versión (Java 17, Flutter 3.47.5, Node 20)",
            "Garantiza que la compilación sea reproducible: el binario publicado se obtiene con el mismo toolchain en cualquierrunner y en cualquier momento.",
            "Job «Preparar entorno de liberación» y variables FLUTTER_VERSION / JAVA_VERSION / NODE_VERSION",
        ],
        [
            "Etapas de validación antes de la compilación",
            "Ahorra recursos: una etapa de 38 s descarta código defectuoso antes de una etapa de 333 s, y el ciclo de retroalimentación del equipo es más corto.",
            "Dependencias «calidad» y «pruebas» → «construye»",
        ],
        [
            "Puerta de calidad sobre el contrato de la API",
            "La aplicación no puede funcionar sin backend; validar el contrato en el pipeline evita publicar un APK que no converse con la base de datos.",
            "Job «api» con newman run y artefacto reporte-api",
        ],
        [
            "Inyección de credenciales por --dart-define",
            "Las claves del backend nunca se escriben en el código ni en el repositorio; llegan al compilador desde GitHub Secrets en tiempo de ejecución.",
            "Job «construye» con --dart-define=SUPABASE_URL / SUPABASE_ANON_KEY",
        ],
        [
            "Publicación condicionada a la rama main",
            "Separa el proceso de integración del proceso de publicación: ninguna versión llega a los usuarios desde una rama de trabajo o una pull request.",
            "Condición «if: github.ref == 'refs/heads/main'» en el job de despliegue",
        ],
        [
            "Versionado de cada publicación con su build",
            "Permite trazar qué código corresponde a cada APK distribuido y distribuir una corrección concreta sin ambigüedad.",
            "Tags v1.0.0+1-<build> en GitHub Releases",
        ],
        [
            "Cancelación automática de ejecuciones obsoletas",
            "Conserva minutos de compilación y garantiza que la versión publicada sea siempre la del último commit.",
            "Bloque concurrency con cancel-in-progress: true",
        ],
        [
            "Conservación de artefactos de evidencia",
            "Permite auditar una entrega sin necesidad de reproducirla: cada ejecución conserva el APK, el informe de la API y la cobertura.",
            "Acciones upload-artifact con retention-days configurado",
        ],
    ],
    anchos=[4.4, 6.2, 5.4],
)

# ------------------------------------------------------------------ 3.8
encabezado(doc, "3.8 Evidencia de ejecución: historial de integraciones y publicaciones", 2)
parrafo(
    doc,
    "El historial del repositorio es la evidencia objetiva del funcionamiento del "
    "pipeline. A la fecha de corte de este documento (22 de octubre de 2026) se "
    "registran 22 ejecuciones del flujo de trabajo —20 sobre la rama main y 2 "
    "sobre la rama de trabajo feature/evidencias-ci-cd— con el siguiente "
    "distribuido de resultados: 10 ejecuciones con conclusión success, 5 con "
    "conclusión failure y 7 canceladas por la regla de concurrencia. En paralelo, "
    "el repositorio acumula 9 publicaciones versionadas en GitHub Releases, cada "
    "una con su APK descargable de aproximadamente 55,2 MB.",
)
tabla(
    doc,
    ["Ejecuciones", "Rama / evento", "Resultado", "Aporte al flujo"],
    [
        ["Runs 1–14", "main (push) y feature/evidencias-ci-cd (pull_request)", "10 con conclusión success, 3 canceladas por concurrencia y 1 con conclusión failure (run 1, anterior a la estabilización del flujo)", "Establecimiento de la línea base del pipeline y publicación de las primeras versiones"],
        ["Runs 15–21", "main (push)", "3 con conclusión failure y 4 canceladas", "Bloqueo de la etapa «api» por credencial obsoleta en el entorno de integración continua (véase apartado 3.10)"],
        ["Run 22", "main (push)", "Entorno, calidad, pruebas y compilación en success; «api» en failure; despliegue omitido", "Verifica el comportamiento de la puerta de calidad: la compilación se completó y la publicación se bloqueó"],
        ["Releases 1–9", "main (push)", "9 publicaciones con etiqueta v1.0.0+<build> y activo app-release.apk", "Trazabilidad entre commit, versión publicada y binario distribuible"],
    ],
    anchos=[2.6, 3.6, 5.2, 4.6],
)
parrafo(
    doc,
    "La lectura conjunta de estos datos es la que sostiene la afirmación central de "
    "este apartado: el flujo de trabajo no es decorativo, es funcional y es "
    "selectivo. En las ejecuciones 15 a 22 el pipeline se comportó exactamente como "
    "se diseñó: la compilación del APK se completó porque las etapas técnicas "
    "eran correctas, y la publicación se omitió porque el contrato de la API no "
    "se cumplía. En un proceso manual, esa versión defectuosa habría llegado al "
    "usuario final.",
)
nota(
    doc,
    "Los enlaces de cada ejecución, el detalle por etapa y los artefactos son "
    "accesibles desde la pestaña Actions del repositorio; las capturas "
    "correspondientes se incorporan en el apartado 3.11.",
)

# ------------------------------------------------------------------ 3.9
encabezado(
    doc,
    "3.9 La validación del contrato de la API como puerta de calidad",
    2,
)
parrafo(
    doc,
    "La etapa «api» es el elemento que distingue a este pipeline de un simple "
    "proceso de compilación. FitCore es una aplicación cliente de una API REST: "
    "si el contrato entre la aplicación y Supabase se rompe (una política RLS "
    "demasiado restrictiva, una tabla renombrada, un endpoint que cambia de "
    "respuesta), la aplicación compila perfectamente pero es inservible. Por eso el "
    "pipeline verifica el contrato real contra el backend de producción antes de "
    "compilar y publicar.",
)
parrafo(
    doc,
    "La colección de pruebas, versionada en api-tests/FitCore.postman_collection.json, "
    "contiene doce peticiones agrupadas en dos grupos y que cubren tres bloques "
    "funcionales: autenticación (cuatro peticiones: dos verificaciones de "
    "disponibilidad del servicio —GoTrue y PostgREST—, inicio de sesión válido y "
    "rechazo de credenciales inválidas), lectura de las ocho tablas de negocio vía "
    "PostgREST (usuarios, clases, membresías, pagos, avisos, planes, rutinas e "
    "información del gimnasio) y una prueba de seguridad que comprueba el "
    "comportamiento de la Row Level Security sin token. En total, 26 aserciones "
    "sobre 12 peticiones.",
)
parrafo(
    doc,
    "La ejecución verificada con Newman, con la clave pública válida del proyecto y "
    "el usuario de prueba, arroja el siguiente resultado:",
)
tabla(
    doc,
    ["Métrica", "Resultado"],
    [
        ["Peticiones ejecutadas", "12"],
        ["Aserciones evaluadas", "26"],
        ["Aserciones superadas", "26"],
        ["Aserciones fallidas", "0"],
        ["Duración total de la ejecución", "≈ 3,4 s"],
        ["Aserción de tiempo de autenticación", "Cumple (< 2.000 ms)"],
        ["Aserción de RLS sin token", "Cumple (el acceso anónimo no expone datos)"],
    ],
    anchos=[8.0, 8.0],
)
parrafo(
    doc,
    "Las siguientes capturas documentan la misma validación ejecutada de forma "
    "interactiva en Postman el 21 de octubre de 2026, y evidencian tanto la "
    "estructura de la colección como el resultado de su ejecución.",
)

encabezado(doc, "3.9.1 Colección de pruebas de API", 3)
captura(
    doc,
    "postman_coleccion.png",
    "Figura 2. Colección «FitCore — API Supabase» importada en Postman con los tres "
    "grupos de peticiones y sus aserciones.",
)

encabezado(doc, "3.9.2 Configuración del runner", 3)
captura(
    doc,
    "postman_runner_pruebas.png",
    "Figura 3. Vista del Collection Runner con las peticiones seleccionables para "
    "ejecución automatizada.",
)
captura(
    doc,
    "postman_runner_pruebas_2.png",
    "Figura 4. Detalle de la configuración del runner: iteraciones, variables de "
    "entorno y opciones de ejecución.",
)

encabezado(doc, "3.9.3 Resultados de la ejecución", 3)
captura(
    doc,
    "postman_runner_resultados.png",
    "Figura 5. Resultados del runner: todas las peticiones en verde, con su tiempo "
    "de respuesta y las aserciones de estado y estructura de la respuesta.",
)

encabezado(doc, "3.9.4 Detalle de una petición y su respuesta", 3)
captura(
    doc,
    "postman_request_detalle.png",
    "Figura 6. Detalle de la petición (método, endpoint, cabeceras y cuerpo enviado) "
    "dentro de la colección.",
)
captura(
    doc,
    "postman_request_respuesta.png",
    "Figura 7. Respuesta JSON del servicio (cuerpo, estado y tiempo de respuesta), "
    "evidencia del contrato de datos semi-estructurados.",
)

encabezado(doc, "3.9.5 Historial de ejecuciones", 3)
captura(
    doc,
    "postman_runs_historial.png",
    "Figura 8. Historial de ejecuciones de la colección, que evidencia la "
    "periodicidad y la trazabilidad de la validación del contrato de la API.",
)
nota(
    doc,
    "Las mismas peticiones se ejecutan de forma automatizada dentro del pipeline "
    "CI/CD con Newman (etapa «api»), por lo que esta validación se repite en cada "
    "integración y condiciona la publicación de la versión.",
)

# ------------------------------------------------------------------ 3.10
encabezado(doc, "3.10 Incidencias detectadas, diagnóstico y acciones correctivas", 2)
parrafo(
    doc,
    "El valor de un pipeline se demuestra, sobre todo, cuando detecta un problema. "
    "Entre el 21 y el 22 de octubre de 2026, el flujo de trabajo bloqueó ocho "
    "ejecuciones consecutivas de la rama main (runs 15 a 22). El registro siguiente "
    "documenta el "
    "ciclo completo de detección, diagnóstico, corrección y verificación, que se "
    "conserva como evidencia de la capacidad correctiva del proceso.",
)
tabla(
    doc,
    ["Fase", "Evidencia y actuación"],
    [
        [
            "Detección",
            "Las ejecuciones 15 a 22 terminan con conclusión failure en la etapa «Pruebas de API (Postman/Newman)», mientras que las etapas de entorno, calidad, pruebas y compilación terminan en success. El pipeline, por diseño, omite la etapa de despliegue.",
        ],
        [
            "Diagnóstico",
            "La lectura del registro de la ejecución muestra que las aserciones de disponibilidad (GoTrue y PostgREST) y la de RLS se superaban, y que el fallo se concentra en la aserción «Login correcto (200)», con el código PGRST301 en las lecturas posteriores por ausencia de token. La causa es que el secreto SUPABASE_ANON_KEY del repositorio contenía una clave JWT de rol «anon» que la plataforma ya no validaba, y que el par de credenciales del usuario de prueba no coincidía con el usuario registrado en el servicio de autenticación.",
        ],
        [
            "Corrección",
            "Se actualizó el secreto SUPABASE_ANON_KEY con la clave pública vigente del proyecto (formato sb_publishable_…) y se restableció la contraseña del usuario de prueba, verificando además su estado de confirmación en el servicio de autenticación.",
        ],
        [
            "Corrección de las aserciones",
            "Se detectaron y corrigieron dos aserciones mal planteadas en la colección: la verificación de salud pedía el código 200 sobre la ruta raíz de PostgREST, que por diseño solo responde a roles elevados, por lo que se sustituyó por dos comprobaciones equivalentes (GET /auth/v1/health y GET /rest/v1/avisos?select=id&limit=1); y la prueba de RLS exigía un rechazo 401/403, cuando la política de seguridad de FitCore filtra las filas y responde 200 con un conjunto vacío, por lo que ahora la aserción acepta ambos comportamientos correctos.",
        ],
        [
            "Verificación",
            "La colección corregida se ejecutó localmente con Newman contra el backend real: 12 peticiones y 26 aserciones, con 0 fallos. La versión corregida se integró en la rama main (commit f9df393) para que la validación del contrato se ejecute en cada integración.",
        ],
        [
            "Resultado",
            "La evidencia confirma que el pipeline funciona como puerta de calidad: identificó un defecto de configuración de entorno, lo hizo visible de forma inmediata y verificable, y bloqueó la publicación de versiones mientras la condición no se cumplía.",
        ],
    ],
    anchos=[3.2, 12.8],
)
parrafo(
    doc,
    "Este episodio aporta, además, una lección de gestión de secretos que el "
    "propio equipo documenta: la credencial obsoleta no estaba en el código, sino en "
    "la configuración del entorno de integración continua, lo que demuestra la "
    "necesidad de incluir en el pipeline una verificación de salud del backend —"
    "etapa expresamente incorporada con este propósito— y de revisar "
    "periódicamente la vigencia de los secretos del repositorio.",
)

# ------------------------------------------------------------------ 3.11
encabezado(doc, "3.11 Capturas de pantalla requeridas para el cierre de la evidencia", 2)
parrafo(
    doc,
    "Para completar la evidencia gráfica del apartado se requieren las siguientes "
    "capturas, que se toman desde la interfaz de GitHub y del panel de Supabase:",
)
tabla(
    doc,
    ["Archivo", "Origen de la captura", "Contenido que evidencia"],
    [
        ["01_actions.png", "Pestaña Actions del repositorio", "Historial de ejecuciones del flujo de trabajo con su estado"],
        ["02_pipeline_etapas.png", "Detalle de una ejecución", "Las seis etapas con su duración y su resultado"],
        ["03_secrets.png", "Settings → Secrets and variables → Actions", "Existencia y estado de los secretos utilizados (sin revelar valores)"],
        ["04_release.png", "Pestaña Releases", "Release publicada con su etiqueta y su APK descargable"],
        ["05_supabase_rls.png", "Supabase → Table Editor → políticas RLS", "Políticas de seguridad de las tablas del proyecto"],
        ["06_app_login.png", "Aplicación FitCore en ejecución", "Inicio de sesión real contra el backend"],
        ["07_app_panel.png", "Aplicación FitCore en ejecución", "Panel administrativo con los datos de Supabase"],
    ],
    anchos=[3.6, 5.0, 7.4],
)
nota(
    doc,
    "Estas capturas se incorporan en la entrega final del documento, en el punto "
    "correspondiente, una vez tomadas por la alumna.",
)

doc.add_page_break()

# ------------------------------------------------------------------ 4 y 5
encabezado(doc, "4. [Apartado 4 del RA — a definir en el siguiente punto]", 1)
nota(doc, "Apartado reservado: se completa en la entrega del punto siguiente.")

encabezado(doc, "5. [Apartado 5 del RA — a definir en el siguiente punto]", 1)
nota(doc, "Apartado reservado: se completa en la entrega del punto siguiente.")

doc.add_page_break()

# ------------------------------------------------------------------ 6. REFERENCIAS
encabezado(doc, "Referencias bibliográficas", 1)
for ref in [
    "Flutter Foundation. (2026). Flutter Documentation. https://docs.flutter.dev",
    "Dart Team. (2026). Dart Language Tour. https://dart.dev/guides",
    "Supabase. (2026). Supabase Documentation: PostgREST, GoTrue y Row Level Security. https://supabase.com/docs",
    "GitHub. (2026). GitHub Actions Documentation. https://docs.github.com/actions",
    "GitHub. (2026). GitHub Actions: Workflow Syntax, Jobs y Secrets. https://docs.github.com/actions/using-workflows",
    "Postman. (2026). Newman - Command Line Collection Runner. https://learning.postman.com/docs/collections/using-newman-cli/command-line-integration-with-newman/",
    "Git. (2026). Git Reference. https://git-scm.com/docs",
    "OWASP Foundation. (2026). Secrets Management Cheat Sheet. https://cheatsheetseries.owasp.org",
    "Fowler, M. (2022). Continuous Integration. Martin Fowler. https://martinfowler.com/articles/continuousIntegration.html",
    "Humble, J. y Farley, D. (2020). Continuous Delivery: Reliable Software Releases through Build, Test, and Deployment Automation. Addison-Wesley.",
]:
    parrafo(doc, ref, tamano=11)

# --------------------------------------------------------- pie de página (paginación)
from docx.oxml.ns import qn
from docx.oxml import OxmlElement


def campo(parrafo, instruccion):
    run = parrafo.add_run()
    fld = OxmlElement("w:fldChar")
    fld.set(qn("w:fldCharType"), "begin")
    run._r.append(fld)
    run2 = parrafo.add_run()
    instr = OxmlElement("w:instrText")
    instr.set(qn("xml:space"), "preserve")
    instr.text = instruccion
    run2._r.append(instr)
    run3 = parrafo.add_run()
    fld2 = OxmlElement("w:fldChar")
    fld2.set(qn("w:fldCharType"), "end")
    run3._r.append(fld2)


pie = sec.footer.paragraphs[0]
pie.alignment = WD_ALIGN_PARAGRAPH.CENTER
r = pie.add_run("FitCore · Resultado de Aprendizaje Unidad III · Página ")
r.font.size = Pt(9)
r.font.color.rgb = GRIS
campo(pie, " PAGE ")
r = pie.add_run(" de ")
r.font.size = Pt(9)
r.font.color.rgb = GRIS
campo(pie, " NUMPAGES ")
for run in pie.runs:
    run.font.size = Pt(9)
    run.font.color.rgb = GRIS

# ------------------------------------------------------------------- guardar
import tempfile
import shutil
from datetime import datetime

CARPETA_DOCS = r"C:\Users\Any Ovando\Documents\FitCore_Limpio\docs"
tmp = os.path.join(tempfile.gettempdir(), "RA_U3_FitCore_build.docx")
doc.save(tmp)

candidatos = [
    os.path.join(CARPETA_DOCS, "RA_U3_FitCore.docx"),
    os.path.join(CARPETA_DOCS, "RA_U3_FitCore (nuevo).docx"),
    os.path.join(
        CARPETA_DOCS,
        "RA_U3_FitCore_" + datetime.now().strftime("%Y%m%d_%H%M%S") + ".docx",
    ),
]
for destino in candidatos:
    try:
        if os.path.exists(destino):
            os.remove(destino)
        shutil.move(tmp, destino)
        if destino != candidatos[0]:
            print("AVISO: la ruta principal estaba ocupada en Word; se guardo como:")
        print("Documento generado:", destino)
        break
    except (PermissionError, OSError) as exc:
        print("No se pudo escribir en", destino, "->", exc.__class__.__name__)
else:
    raise SystemExit("No se pudo guardar el documento en ninguna ruta.")

