# App Móvil FitCore - Versión 1.0

## ¿Qué es FitCore?

FitCore es una aplicación móvil multiplataforma desarrollada con Flutter, orientada a la gestión operativa de un gimnasio. 

Para esta primera versión (1.0), se implementó únicamente el módulo de autenticación y el Panel Administrativo para el control de las principales entidades del gimnasio.

## ¿Qué hace actualmente?

### 1. Inicio de Sesión
- **Autenticación**: Permite al administrador ingresar al sistema mediante sus credenciales.
- **Control de sesión**: Gestiona el acceso y cierre de sesión dentro de la aplicación.

### 2. Panel Administrativo
Cuenta con un menú lateral adaptativo que permite navegar entre los distintos módulos para gestionar el gimnasio. Cada módulo con gestión implementa operaciones **Crear, Consultar, Modificar y Eliminar (CRUD)**.

| Módulo | Objetivo | Funcionalidades |
| :-- | :-- | :-- |
| **Inicio** | Vista general del sistema | Muestra un resumen con la información más relevante del gimnasio para tener una visión rápida del estado actual. |
| **Clientes** | Gestión de socios/clientes | Alta, consulta, modificación y eliminación de los clientes registrados en el gimnasio. |
| **Instructores** | Gestión del cuerpo docente | Registro, consulta, actualización y baja de instructores, manteniendo su información actualizada. |
| **Clases y Horarios** | Gestión de clases grupales | Creación, consulta, modificación y eliminación de clases, asignación de instructor, definición de horarios y cupos disponibles. |
| **Rutinas** | Gestión de rutinas de entrenamiento | Creación, consulta, modificación y eliminación de rutinas de entrenamiento para organizar los ejercicios del gimnasio. |
| **Membresías** | Catálogo de planes | Administración de los distintos tipos de membresía (nombre, duración, precio y descripción), con sus respectivas operaciones CRUD. |
| **Pagos** | Control de pagos | Registro, consulta, modificación y eliminación de pagos realizados por los clientes, llevando el control de cobros del gimnasio. |
| **Avisos** | Comunicación con usuarios | Publicación, consulta, edición y eliminación de avisos y comunicados que serán visibles para los usuarios. |
| **Información del Gimnasio** | Datos institucionales | Consulta y actualización de la información general del gimnasio (datos de contacto, ubicación, entre otros). |
| **Reportes** | Generación de indicadores | Consulta de reportes con información estadística para apoyar la toma de decisiones administrativas. |
| **Configuración** | Ajustes del sistema | Configuración general del panel administrativo. |

## ¿Qué contiene?

- lib/ - Código fuente principal en Dart/Flutter (autenticación, panel administrativo, modelos, repositorios, widgets y estado).
- ndroid/ - Configuración y código nativo para Android.
- ios/ - Configuración y código nativo para iOS.
- web/ - Configuración para versión web.
- windows/ - Configuración para versión Windows.
- ssets/ - Recursos gráficos e imágenes.
- docs/ - Documentación del proyecto.

## Tecnologías

- Flutter 3.x
- Dart
- Material Design
- Provider (Gestión de estado)
