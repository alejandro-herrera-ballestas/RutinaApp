# 📅 RutinaApp

RutinaApp es una aplicación móvil desarrollada con **Flutter y Dart** cuyo objetivo es facilitar la organización y seguimiento de rutinas diarias mediante una interfaz visual, sencilla e intuitiva.

El proyecto está especialmente orientado a personas que pueden beneficiarse de una estructura visual para organizar sus actividades y seguir una rutina de manera más clara.

> 🚧 **Estado del proyecto:** En desarrollo

---

## 📱 Capturas de pantalla

<p align="center">
  <img width="220" alt="RutinaApp" src="https://github.com/user-attachments/assets/3dbd59d5-8a7d-486e-8b6b-95154761f023" />
  <img width="220" alt="RutinaApp" src="https://github.com/user-attachments/assets/87ce9575-fba2-4f0b-85c9-59d6415b1df7" />
  <img width="220" alt="RutinaApp" src="https://github.com/user-attachments/assets/3ebcf435-7465-4b07-b976-042feab678d2" />
  <img width="220" alt="RutinaApp" src="https://github.com/user-attachments/assets/abebc786-593b-4f7c-aa5e-49dfb3b0fce7" />
</p>



## ✨ Características

* 🔐 Registro e inicio de sesión mediante **Supabase Auth**.
* 👤 Gestión de perfiles de usuario.
* 👨‍👦 Modelo de usuarios con roles de **Cuidador** y **Paciente**.
* 📅 Organización de actividades mediante horarios.
* ➕ Creación de actividades con nombre, descripción, hora y duración.
* ✏️ Edición de actividades.
* 🗑️ Eliminación de actividades.
* 📷 Selección de imágenes mediante cámara o galería.
* ✅ Marcado de actividades como completadas.
* 📊 Cálculo del progreso de las actividades.
* 📆 Vista de calendario con organización de actividades por horario.
* ⚠️ Detección de conflictos entre horarios.
* 👥 Relación entre cuidadores y pacientes.
* 📱 Aplicación desarrollada con Flutter para Android e iOS.

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

### Herramientas

* **Git**
* **GitHub**
* **Android Studio**
* **Visual Studio Code**

### Paquetes principales

* `supabase_flutter` — autenticación y comunicación con Supabase.
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

Contienen las entidades principales de la aplicación y la lógica relacionada con usuarios, pacientes, cuidadores, horarios y actividades.

**Services**

Gestionan la lógica de negocio y la comunicación con Supabase, incluyendo autenticación, usuarios, pacientes, cuidadores y actividades.

**Screens**

Contienen las diferentes interfaces y flujos de navegación de la aplicación.

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

* Hora de inicio
* Hora de finalización
* Actividad asociada

El sistema puede:

* Ordenar las actividades por hora.
* Detectar conflictos entre horarios.
* Mover actividades manteniendo su duración.
* Obtener la actividad correspondiente al momento actual.
* Generar bloques automáticamente a partir de las actividades.
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

Las actividades pueden:

* Crear.
* Editar.
* Eliminar.
* Marcar como completadas.
* Reiniciar su estado.
* Organizar dentro del horario.
* Consultarse desde Supabase.

---

## 🔐 Autenticación

La autenticación se realiza mediante **Supabase Auth**.

Durante el registro, el usuario puede seleccionar uno de los siguientes roles:

```text
Usuario
├── Cuidador
└── Paciente
```

El proceso de registro crea la cuenta en Supabase Auth y posteriormente registra la información correspondiente en las tablas de usuarios, cuidadores o pacientes.

Durante el inicio de sesión, la aplicación:

1. Autentica las credenciales mediante Supabase Auth.
2. Obtiene el usuario autenticado.
3. Comprueba si corresponde a un cuidador o paciente.
4. Carga la información asociada.
5. Mantiene el usuario actual disponible para el resto de la aplicación.

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

Almacena información adicional de los cuidadores, como su teléfono.

### `cuidador_paciente`

Establece la relación entre cuidadores y pacientes.

### `actividades`

Almacena las actividades asociadas a un paciente, incluyendo nombre, descripción, imagen, hora y duración.

### `progreso_actividad`

Permite registrar el estado de una actividad en una fecha determinada y almacenar la hora en la que fue completada.

---

## 🔄 Persistencia

Actualmente el proyecto cuenta con **integración funcional con Supabase** para:

* Registro de usuarios.
* Inicio de sesión.
* Gestión de usuarios.
* Gestión de pacientes.
* Gestión de cuidadores.
* Relaciones entre cuidadores y pacientes.
* Operaciones CRUD de actividades a nivel de servicio.

La interfaz actual de gestión de actividades todavía utiliza una lista local en `ActividadService` para determinadas operaciones, mientras se completa la transición hacia una gestión totalmente persistente mediante Supabase.

El proyecto también mantiene `DatabaseService` como una estructura preparada para futuras mejoras de persistencia local.

---

## 📱 Interfaz y navegación

La aplicación cuenta con una navegación principal dividida en tres secciones:

```text
┌───────────────┐
│    Inicio     │
├───────────────┤
│  Calendario   │
├───────────────┤
│    Perfil     │
└───────────────┘
```

### Inicio

Permite visualizar las actividades del día y acceder a la creación y edición de actividades.

### Calendario

Muestra las actividades organizadas dentro de un horario diario y permite seleccionar diferentes fechas.

También detecta conflictos cuando dos actividades ocupan intervalos de tiempo que se superponen.

### Perfil

Permite visualizar información del usuario autenticado, correo electrónico, estadísticas y opciones relacionadas con la foto de perfil y cierre de sesión.

---

## 🖼️ Gestión de imágenes

La aplicación utiliza `image_picker` para permitir al usuario:

* Seleccionar una imagen desde la galería.
* Tomar una fotografía mediante la cámara.
* Visualizar la imagen seleccionada dentro de la actividad o perfil.

---

## 📊 Progreso

El modelo `Paciente` incluye lógica para calcular el progreso de las actividades de su horario.

El porcentaje se obtiene a partir de la relación entre actividades completadas y actividades totales:

```text
Progreso = (actividades completadas / actividades totales) × 100
```

La estructura de widgets relacionada con la visualización del progreso se encuentra actualmente en desarrollo.

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
* [x] Creación de actividades.
* [x] Edición de actividades.
* [x] Eliminación de actividades.
* [x] Selección de imágenes mediante cámara o galería.
* [x] Marcado de actividades como completadas.
* [x] Cálculo del progreso.
* [x] Calendario diario.
* [x] Detección de conflictos entre horarios.
* [x] Scripts SQL para la estructura de la base de datos.
* [x] Configuración de Supabase.

### En desarrollo

* [ ] Completar la transición de la gestión local de actividades hacia persistencia completa mediante Supabase.
* [ ] Completar el sistema visual de progreso.
* [ ] Implementar notificaciones y recordatorios.
* [ ] Mejorar la gestión de imágenes y almacenamiento remoto.
* [ ] Mejorar la experiencia de usuario y accesibilidad.
* [ ] Realizar pruebas más completas.
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
* Control de versiones mediante Git.

---

## 👨‍💻 Autor

**Alejandro Herrera Ballestas**

Estudiante de Ingeniería de Sistemas.

---

## 📌 Tecnologías principales

```text
Flutter • Dart • Supabase • PostgreSQL • SQL • Git • GitHub
```

