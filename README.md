# alerta_temprana

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

📱 Sistema de Alerta Temprana

Bienvenido al repositorio del proyecto Alerta Temprana, una aplicación desarrollada con Flutter y Dart diseñada para la gestión, notificación y seguimiento de ausencias e incidencias académicas en tiempo real.

Este documento sirve como guía oficial para el equipo de desarrollo. Aquí encontrarás las instrucciones paso a paso para clonar el repositorio, configurar tu entorno local, ejecutar la aplicación y seguir el flujo de trabajo colaborativo mediante Git y GitHub.

📋 Tabla de Contenidos

Requisitos Previos

Instalación y Configuración Inicial

Comandos Esenciales de Flutter

Flujo de Trabajo Colaborativo con Git

Estructura del Proyecto

Resolución de Conflictos y Problemas Comunes

🛠️ Requisitos Previos

Antes de comenzar a trabajar en el proyecto, cada colaborador debe asegurarse de contar con las siguientes herramientas instaladas y configuradas:

Flutter SDK: Versión estable (Stable Channel).

Git: Instalado y configurado con tu usuario global:

git config --global user.name "Tu Nombre"
git config --global user.email "tu_correo@ejemplo.com"


Editor de Código: Recomendado Visual Studio Code con las extensiones oficiales:

Flutter (de Dart Code)

Dart (de Dart Code)

GitLens (opcional, muy recomendado para control de versiones)

Entorno de Ejecución:

Google Chrome (para pruebas rápidas en web).

Android Studio con al menos un emulador (AVD) configurado, o un dispositivo físico Android con Depuración por USB activada.

Xcode (únicamente si desarrollas desde macOS para iOS).

Verificación del entorno

Para comprobar que no existan componentes faltantes o advertencias bloqueantes, ejecuta en la terminal:

flutter doctor


Asegúrate de que Flutter, el Android toolchain y tu editor figuren con tildes verdes.

🚀 Instalación y Configuración Inicial

Sigue estos pasos la primera vez que descargues el proyecto en tu máquina:

1. Clonar el repositorio

Abre tu terminal en la carpeta donde guardas tus proyectos y clona el repositorio:

git clone <URL_DEL_REPOSITORIO>


(Reemplaza <URL_DEL_REPOSITORIO> por el enlace HTTPS o SSH provisto en GitHub).

2. Entrar al directorio

cd alerta_temprana


3. Descargar dependencias

Instala todas las librerías declaradas en el archivo pubspec.yaml:

flutter pub get


⚡ Comandos Esenciales de Flutter

A continuación se detallan los comandos más utilizados durante el ciclo de vida del desarrollo.

Detección y ejecución

Listar dispositivos disponibles:

Muestra todos los emuladores, teléfonos conectados o navegadores web listos para correr la app:

flutter devices


Ejecutar en el dispositivo por defecto:

Inicia la aplicación en el dispositivo activo o prioritario:

flutter run


Ejecutar en un entorno específico:

Si deseas correr la app directamente en Chrome o en un dispositivo puntual:

flutter run -d chrome
flutter run -d <ID_DEL_DISPOSITIVO>


Atajos de teclado en la terminal (mientras la app corre)

r: Hot Reload — Aplica cambios en la interfaz gráfica de forma casi instantánea sin perder el estado actual de las pantallas.

R: Hot Restart — Reinicia la aplicación por completo, reseteando variables y estados en memoria.

h: Help — Muestra la lista de atajos disponibles en la consola de Flutter.

q: Quit — Detiene la ejecución de la aplicación y cierra el proceso.

Mantenimiento y diagnóstico

Limpieza de caché y compilaciones previas:

Útil si experimentas errores de compilación extraños o residuos de builds anteriores:

flutter clean
flutter pub get


Análisis estático de código:

Examina el código Dart en busca de advertencias, malas prácticas o errores de sintaxis definidos en analysis_options.yaml:

flutter analyze


🌿 Flujo de Trabajo Colaborativo con Git

Para mantener la rama main siempre estable, limpia y funcional, queda estrictamente prohibido realizar commits directos sobre main. Todo trabajo debe realizarse mediante ramas secundarias y Pull Requests.

       (feature/nueva-pantalla)  [commit] -> [commit] 
      /                                               \
main --------------------------------------------------* (Merge PR) --->


1. Sincronizar la rama principal

Antes de comenzar a programar una nueva tarea o corrección, asegúrate de tener la última versión del proyecto:

git checkout main
git pull origin main


2. Crear una rama de trabajo

Crea una rama con un nombre claro y descriptivo utilizando el prefijo correspondiente (feature/ para nuevas funciones, fix/ para correcciones de bugs, refactor/ para mejoras de código):

git checkout -b feature/nombre-de-la-tarea


Ejemplos:

feature/pantalla-notificaciones

feature/servicio-fcm

fix/error-historial-docente

3. Guardar avances en commits atómicos

Haz commits frecuentes y con mensajes descriptivos en tiempo presente:

# Verificar qué archivos fueron modificados
git status

# Agregar archivos al área de preparación (staging)
git add .

# Confirmar los cambios con un mensaje claro
git commit -m "feat: implementar interfaz de envío de alertas para docentes"


4. Publicar la rama en GitHub

La primera vez que subas tu nueva rama al servidor remoto:

git push -u origin feature/nombre-de-la-tarea


(Para los commits siguientes dentro de la misma rama, solo hará falta escribir git push).

5. Abrir un Pull Request (PR)

Ingresa al repositorio en GitHub.

Verás un cartel amarillo con el botón "Compare & pull request" de tu rama recién subida. Haz clic en él.

Escribe un título conciso y describe en la caja de texto qué cambios implementaste y cómo probarlos.

Asigna a uno o más compañeros como Reviewers si corresponde.

Haz clic en Create pull request.

Una vez revisado y aprobado, se realiza el Merge a la rama main.

🔄 Cómo Mantener tu Rama Actualizada

Si otro miembro del equipo mergeó cambios a main mientras tú estabas trabajando en tu rama, debes sincronizar tu rama local para evitar conflictos al momento del PR:

# 1. Asegúrate de tener todos tus cambios guardados en un commit
git status

# 2. Descarga e integra los últimos cambios de main en tu rama actual
git pull origin main

# 3. Si no hay conflictos, Git creará un merge automático. Súbelo a tu rama remota:
git push


📁 Estructura del Proyecto

El código fuente dentro de lib/ está organizado de la siguiente manera:

lib/
├── main.dart                 # Punto de entrada de la aplicación
├── modelos/                  # Clases de datos y modelos de negocio
│   └── notificacion_ausencia.dart
├── pantallas/                # Vistas y componentes de interfaz (UI)
│   ├── contenedor_screen.dart
│   ├── docente_emision_screen.dart
│   ├── docente_historial_screen.dart
│   └── estudiante_screen.dart
└── servicios/                # Lógica de comunicación externa y Firebase
    └── fcm_service.dart


⚠️ Resolución de Conflictos y Buenas Prácticas

Nunca modifiques archivos autogenerados manualmente: Las carpetas android/, ios/, linux/, macos/, web/ y windows/ contienen código nativo generado por Flutter. Solo modifícalos si es indispensable para configurar permisos o plugins.

Conflicto en pubspec.lock: Si al hacer pull surge un conflicto en pubspec.lock, generalmente se soluciona ejecutando flutter pub get nuevamente.

Manejo de variables de entorno y credenciales: Archivos sensibles como credenciales de Firebase (google-services.json, GoogleService-Info.plist) o tokens privados deben verificarse en el .gitignore y compartirse por canales internos seguros, nunca subirse a repositorios públicos.
