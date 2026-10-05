# 📅 RutinaApp

RutinaApp es una aplicación móvil desarrollada con **Flutter y Dart** cuyo objetivo es facilitar la organización y seguimiento de rutinas diarias mediante una interfaz visual, sencilla e intuitiva.

La aplicación está orientada especialmente a personas que pueden beneficiarse de una estructura visual para organizar sus actividades y seguir una rutina de manera más clara. El sistema contempla dos roles principales: **Cuidador** y **Paciente**.

> 🚧 **Estado del proyecto:** En desarrollo activo

---

## 📱 Capturas de pantalla

<p align="center">
  <img width="180" alt="RutinaApp" src="https://github.com/user-attachments/assets/3dbd59d5-8a7d-486e-8b6b-95154761f023" />
  <img width="180" alt="RutinaApp" src="https://github.com/user-attachments/assets/87ce9575-fba2-4f0b-85c9-59d6415b1df7" />
  <img width="180" alt="RutinaApp" src="https://github.com/user-attachments/assets/3ebcf435-7465-4b07-b976-042feab678d2" />
</p>

---

## ✨ Características

### 🔐 Usuarios y autenticación

* Registro e inicio de sesión mediante **Supabase Auth**.
* Gestión de perfiles de usuario.
* Roles de **Cuidador** y **Paciente**.
* Asociación de cuidadores con uno o varios pacientes.
* Selección del paciente activo por parte del cuidador.

### 📅 Rutinas y actividades

* Creación de actividades con nombre, descripción, imagen, hora y duración.
* Edición y eliminación de actividades.
* Organización de actividades dentro del horario del paciente.
* Detección de conflictos entre horarios.
* Marcado de actividades como completadas.
* Reinicio del estado de una actividad.
* Persistencia de actividades asociadas al paciente en Supabase.

### 📊 Seguimiento y progreso

* Registro del progreso de las actividades por fecha.
* Consulta del progreso diario del paciente.
* Cálculo del porcentaje de actividades completadas.
* Visualización del progreso dentro de la aplicación.

### 🖼️ Imágenes y almacenamiento

* Selección de imágenes desde la galería.
* Captura de imágenes mediante la cámara.
* Gestión de imágenes de actividades y perfiles.
* Uso de **Supabase Storage** para el almacenamiento remoto de imágenes.

### 🔔 Notificaciones

* Servicio de notificaciones integrado en la aplicación.
* Preparación de recordatorios asociados a las actividades y horarios.

### 📱 Navegación

La aplicación cuenta con una navegación principal organizada en:

```text
┌───────────────┐
│    Inicio     │
├───────────────┤
│  Calendario   │
├───────────────┤
│    Perfil     │
└───────────────┘
```

---

## 🛠️ Tecnologías

### Desarrollo

* **Flutter**
* **Dart**
* **Material Design**
* **Programación Orientada a Objetos**

### Backend y base de datos

* **Supabase**
* **Supabase Auth**
* **PostgreSQL / SQL**
* **Supabase Storage**

### Herramientas

* **Git**
* **GitHub**
* **Android Studio**
* **Visual Studio Code**

### Paquetes principales

* `supabase_flutter` — autenticación, base de datos y comunicación con Supabase.
* `image_picker` — selección de imágenes mediante cámara o galería.
* `uuid` — generación de identificadores únicos.
* `intl` — formato y manejo de fechas.
* `cupertino_icons` — iconos para la interfaz.

---

## 📂 Arquitectura del proyecto

El proyecto está organizado de forma modular para separar las responsabilidades entre modelos, servicios, interfaces y componentes reutilizables.

```text
lib/
│
├── models/
│   ├── usuario.dart
│   ├── cuidador.dart
│   ├── paciente.dart
│   ├── horario.dart
│   ├── BloqueHorario.dart
│   └── actividad.dart
│
├── services/
│   ├── auth_service.dart
│   ├── actividad_service.dart
│   ├── progreso_actividad_service.dart
│   ├── usuario_service.dart
│   ├── paciente_service.dart
│   ├── cuidador_service.dart
│   ├── Cuidador_Paciente.dart
│   ├── database_service.dart
│   ├── usuarioAuth.dart
│   └── notification_service.dart
│
├── screens/
│   ├── login_screen.dart
│   ├── register_screen.dart
│   ├── main_navigator_screen.dart
│   ├── home_screen.dart
│   ├── calendario_screen.dart
│   ├── perfil_screen.dart
│   ├── add_activity_screen.dart
│   └── detalle_actividad_screen.dart
│
├── widgets/
│   ├── actividadCard.dart
│   ├── actividadProgress.dart
│   ├── botonGrande.dart
│   └── progreso.dart
│
├── database/
│   ├── 01_usuarios.sql
│   ├── 02_pacientes.sql
│   ├── 03_cuidador.sql
│   ├── 04_cuidador_paciente.sql
│   ├── 05_actividades.sql
│   └── 06_progreso_actividad.sql
│
├── utils/
│   └── global.dart
│
└── main.dart
```

### Principales responsabilidades

**Models**

Contienen las entidades principales y su lógica asociada: usuarios, pacientes, cuidadores, horarios y actividades.

**Services**

Gestionan la lógica de negocio y la comunicación con Supabase, incluyendo autenticación, usuarios, relaciones cuidador-paciente, actividades, progreso y notificaciones.

**Screens**

Contienen las interfaces y flujos de navegación de la aplicación.

**Widgets**

Contienen componentes reutilizables de la interfaz.

**Database**

Contiene los scripts SQL utilizados para definir la estructura de la base de datos.

**Utils**

Contiene configuraciones y recursos compartidos entre diferentes partes de la aplicación.

---

## 🧩 Modelo del sistema

RutinaApp utiliza **Programación Orientada a Objetos** para representar las principales entidades y relaciones del sistema.

### Usuarios

La clase abstracta `Usuario` contiene información común como:

* ID
* Nombre
* Fecha de nacimiento
* Foto de perfil
* Cálculo de edad

A partir de esta clase se extienden:

### `Cuidador`

Permite administrar pacientes y gestionar actividades asociadas a ellos.

### `Paciente`

Cuenta con un horario propio y permite realizar el seguimiento de sus actividades.

### Relación cuidador-paciente

Un cuidador puede estar asociado a uno o varios pacientes. La aplicación permite cargar las relaciones existentes y seleccionar el paciente sobre el cual se desea trabajar.

---

## 📅 Organización de horarios

El sistema utiliza las clases `Horario` y `BloqueHorario` para organizar las actividades durante el día.

```text
Paciente
   │
   └── Horario
         │
         ├── BloqueHorario
         │      └── Actividad
         │
         ├── BloqueHorario
         │      └── Actividad
         │
         └── BloqueHorario
                └── Actividad
```

Cada `BloqueHorario` contiene:

* Hora de inicio.
* Hora de finalización.
* Actividad asociada.

El sistema puede:

* Ordenar actividades por hora.
* Detectar conflictos entre horarios.
* Mover actividades manteniendo su duración.
* Obtener la actividad correspondiente al momento actual.
* Generar bloques a partir de las actividades.
* Ajustar la distribución del horario.

---

## 📝 Actividades

Cada actividad contiene información como:

* Identificador único.
* Nombre.
* Descripción.
* Imagen.
* Hora.
* Duración.
* Estado de completado.
* Fecha de completado.
* Paciente asociado.

Las actividades pueden:

* Crear.
* Editar.
* Eliminar.
* Marcar como completadas.
* Reiniciar su estado.
* Organizarse dentro del horario.
* Consultarse y persistirse mediante Supabase.

---

## 🔐 Autenticación y roles

La autenticación se realiza mediante **Supabase Auth**.

Durante el registro, el usuario puede seleccionar uno de los siguientes roles:

```text
Usuario
├── Cuidador
└── Paciente
```

El proceso de autenticación permite identificar el tipo de usuario y cargar la información asociada.

En el caso de un cuidador, la aplicación además carga sus pacientes asociados y permite seleccionar cuál de ellos se encuentra activo para consultar y gestionar sus actividades.

---

## 🗄️ Base de datos

El proyecto incluye scripts SQL para estructurar la base de datos en Supabase.

### Tablas principales

```text
usuarios
   │
   ├── pacientes
   │
   └── cuidadores
          │
          └── cuidador_paciente

pacientes
   │
   └── actividades
          │
          └── progreso_actividad
```

### `usuarios`

Almacena la información general de los usuarios.

### `pacientes`

Relaciona un paciente con su usuario correspondiente.

### `cuidadores`

Almacena información adicional de los cuidadores.

### `cuidador_paciente`

Establece la relación entre cuidadores y pacientes.

### `actividades`

Almacena las actividades asociadas a un paciente, incluyendo nombre, descripción, imagen, hora y duración.

### `progreso_actividad`

Permite registrar el estado de una actividad en una fecha determinada y almacenar información relacionada con su cumplimiento.

---

## 🔄 Persistencia

La aplicación utiliza **Supabase como backend principal** para mantener la información de usuarios, relaciones y actividades.

Actualmente se cuenta con persistencia para:

* Registro e inicio de sesión.
* Información de usuarios.
* Pacientes y cuidadores.
* Relaciones cuidador-paciente.
* Actividades asociadas a pacientes.
* Estado y progreso de las actividades.
* Información relacionada con imágenes mediante almacenamiento remoto.

El flujo de trabajo está diseñado para que el cuidador pueda seleccionar un paciente y que las pantallas de inicio, calendario y gestión de actividades trabajen sobre ese paciente seleccionado.

---

## 📱 Interfaz y navegación

### Inicio

Permite visualizar las actividades del día y acceder a la creación y edición de actividades. Para los cuidadores, el flujo contempla la selección del paciente que se desea gestionar.

### Calendario

Muestra las actividades organizadas dentro de un horario diario y permite trabajar con diferentes fechas.

También detecta conflictos cuando dos actividades ocupan intervalos de tiempo que se superponen.

### Perfil

Permite visualizar información del usuario autenticado, correo electrónico, estadísticas y opciones relacionadas con la foto de perfil y cierre de sesión.

---

## 🖼️ Gestión de imágenes

La aplicación utiliza `image_picker` para permitir al usuario:

* Seleccionar una imagen desde la galería.
* Tomar una fotografía mediante la cámara.
* Visualizar la imagen seleccionada dentro de actividades o perfiles.

Las imágenes pueden gestionarse mediante **Supabase Storage**, permitiendo complementar la información almacenada en la base de datos con recursos multimedia.

---

## 📊 Progreso

El sistema registra el progreso de las actividades por fecha mediante `ProgresoActividadService`.

El porcentaje de progreso se basa en la relación entre actividades completadas y actividades totales:

```text
Progreso = (actividades completadas / actividades totales) × 100
```

El progreso puede consultarse para un día determinado y actualizarse cuando el usuario marca una actividad como completada.

---

## 🔔 Notificaciones

El proyecto incluye `NotificationService` como servicio dedicado al manejo de notificaciones.

Esta funcionalidad forma parte de la arquitectura actual de la aplicación y continúa evolucionando junto con el sistema de recordatorios.

---

## 🧪 Pruebas

El proyecto se encuentra en proceso de pruebas funcionales para validar los principales flujos de usuario, incluyendo:

* Registro e inicio de sesión.
* Diferenciación de roles.
* Asociación y selección de pacientes.
* Creación, edición y eliminación de actividades.
* Organización de horarios y detección de conflictos.
* Marcado y persistencia del progreso.
* Gestión de imágenes.

### Tester

**Juan Esteban Primera** — Tester

Participa en la validación funcional de la aplicación y en la identificación de errores durante el desarrollo.

---

## 🚧 Estado actual

RutinaApp se encuentra actualmente en **desarrollo activo**.

### Implementado

* [x] Configuración inicial del proyecto Flutter.
* [x] Estructura modular del proyecto.
* [x] Modelado de usuarios, cuidadores y pacientes.
* [x] Modelado de horarios y bloques horarios.
* [x] Modelado de actividades.
* [x] Registro de usuarios.
* [x] Inicio de sesión mediante Supabase Auth.
* [x] Roles de cuidador y paciente.
* [x] Gestión de usuarios mediante Supabase.
* [x] Gestión de cuidadores y pacientes mediante Supabase.
* [x] Relación entre cuidadores y pacientes.
* [x] Selección de paciente activo para cuidadores.
* [x] Creación, edición y eliminación de actividades.
* [x] Persistencia de actividades mediante Supabase.
* [x] Selección de imágenes mediante cámara o galería.
* [x] Gestión de imágenes mediante Supabase Storage.
* [x] Marcado y seguimiento del progreso de actividades.
* [x] Calendario y organización de horarios.
* [x] Detección de conflictos entre horarios.
* [x] Servicio de notificaciones.
* [x] Scripts SQL para la estructura de la base de datos.
* [x] Configuración de Supabase.

### En desarrollo

* [ ] Ampliar y automatizar el sistema de notificaciones y recordatorios.
* [ ] Mejorar la experiencia de usuario y accesibilidad.
* [ ] Ampliar las pruebas funcionales y de integración.
* [ ] Optimizar la gestión y carga de imágenes.
* [ ] Preparar una primera versión distribuible de la aplicación.

---

## 🎯 Objetivo del proyecto

RutinaApp busca facilitar la organización de actividades diarias mediante **rutinas visuales, horarios y seguimiento del progreso**, ofreciendo una interfaz sencilla y estructurada.

Además de su objetivo funcional, el proyecto permite aplicar y fortalecer conocimientos de:

* Programación Orientada a Objetos.
* Desarrollo de aplicaciones móviles.
* Arquitectura y separación de responsabilidades.
* Diseño de bases de datos.
* SQL.
* Integración de servicios backend.
* Autenticación de usuarios.
* Desarrollo de interfaces gráficas.
* Persistencia de datos.
* Control de versiones con Git.

---

## 📚 Aprendizajes

Durante el desarrollo de RutinaApp se han aplicado conceptos relacionados con:

* Diseño y modelado de clases.
* Herencia y encapsulamiento.
* Separación de lógica de negocio e interfaz.
* Manejo de estado en Flutter.
* Navegación entre pantallas.
* Consumo de servicios backend.
* Autenticación mediante Supabase.
* Operaciones CRUD.
* Modelado de relaciones entre entidades.
* Diseño de bases de datos relacionales.
* Manejo de fechas, horas y duración de actividades.
* Persistencia de información.
* Control de versiones mediante Git.

---

## 👨‍💻 Equipo

### Autor / Desarrollador

**Alejandro Herrera Ballestas**

Estudiante de Ingeniería de Sistemas.

### Tester

**Juan Esteban Primera**

Responsable de apoyar las pruebas funcionales, validación de flujos y detección de errores de la aplicación.

---

## 📌 Tecnologías principales

```text
Flutter • Dart • Supabase • PostgreSQL • SQL • Git • GitHub
```
