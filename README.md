# 📅 RutinaApp

RutinaApp es una aplicación móvil desarrollada con **Flutter** cuyo objetivo es ayudar a personas con Trastorno del Espectro Autista (TEA) a seguir sus rutinas diarias mediante una interfaz simple, intuitiva y visual.

---

## ✨ Características

- 🔐 Registro e inicio de sesión de usuarios.
- 📆 Organización de rutinas diarias por horario.
- ➕ Creación de actividades con nombre, descripción y hora.
- 📷 Selección de imagen para cada actividad (cámara o galería).
- ✅ Seguimiento de actividades completadas y su progreso.
- 👨‍👦 Modelo de administración de pacientes por parte de un cuidador.
- 🎨 Interfaz sencilla y amigable para personas con TEA.
- 📱 Aplicación multiplataforma gracias a Flutter.

---

## 🛠️ Tecnologías

- Flutter (channel stable)
- Dart
- Material Design 3
- Android Studio
- Git / GitHub

### Paquetes utilizados

- [`uuid`](https://pub.dev/packages/uuid) — generación de identificadores únicos.
- [`intl`](https://pub.dev/packages/intl) — formateo de fechas en español (`es_ES`).
- [`image_picker`](https://pub.dev/packages/image_picker) — selección de imágenes desde cámara o galería.
- [`cupertino_icons`](https://pub.dev/packages/cupertino_icons) — íconos estilo iOS.

---

## 📂 Arquitectura del proyecto

```
lib/
│
├── models/
│   ├── usuario.dart          # Clase abstracta base (Cuidador y Paciente extienden de aquí)
│   ├── cuidador.dart          # Gestiona pacientes y asignación/edición de actividades
│   ├── paciente.dart          # Tiene un Horario y su propio progreso
│   ├── horario.dart           # Lista de BloqueHorario, evita solapamientos
│   ├── BloqueHorario.dart      # Relaciona una franja de tiempo con una Actividad
│   ├── actividad.dart          # Nombre, descripción, imagen, pasos y estado de completado
│   └── paso.dart               # Paso individual dentro de una actividad
│
├── services/
│   ├── actividad_service.dart     # CRUD completo de actividades en memoria
│   ├── auth_service.dart          # Registro / inicio de sesión en memoria
│   ├── usuarioAuth.dart           # Modelo interno de credenciales
│   ├── database_service.dart      # Interfaz preparada para persistencia (aún sin implementar)
│   └── notification_service.dart  # Reservado para notificaciones (pendiente)
│
├── screens/
│   ├── login_screen.dart          # Inicio de sesión
│   ├── register_screen.dart       # Registro de nuevo usuario
│   ├── home_screen.dart           # Lista de actividades del día
│   └── add_activity_screen.dart   # Formulario para crear una actividad
│
├── widgets/
│   ├── actividadCard.dart          # Tarjeta de actividad usada en el Home
│   ├── actividadProgress.dart      # (pendiente de implementar)
│   ├── botonGrande.dart            # (pendiente de implementar)
│   └── progreso.dart               # (pendiente de implementar)
│
├── utils/
│   └── global.dart      # Instancias globales de ActividadService y AuthService
│
└── main.dart            # Punto de entrada; inicializa formato de fecha es_ES y abre LoginScreen
```

---

## 🧩 Modelo del sistema

El sistema está basado en Programación Orientada a Objetos.

### Usuarios

- `Usuario` (abstracto): id, nombre, fecha de nacimiento, foto de perfil, cálculo de edad.
  - `Cuidador`: administra una lista de `Paciente`, puede asignar y editar actividades.
  - `Paciente`: tiene un `Horario` propio y calcula su porcentaje de progreso diario.

### Organización

```
Paciente
 └── Horario
      └── BloqueHorario (franja de tiempo)
           └── Actividad
                └── Paso (opcional, paso a paso)
```

`Horario` valida que los bloques no se solapen entre sí antes de agregarlos, y permite reordenar u obtener la actividad correspondiente al momento actual.

### Autenticación y persistencia de actividades

Por ahora, tanto `AuthService` como `ActividadService` guardan la información **en memoria** (listas internas), por lo que los datos se pierden al cerrar la app. `DatabaseService` ya tiene la interfaz definida (guardar/actualizar/eliminar/obtener para pacientes, actividades y horarios) pero sus métodos aún no están implementados — es el siguiente paso natural para dar persistencia real.

---

## 🚀 Estado del proyecto

Actualmente el proyecto se encuentra en desarrollo activo.

### Roadmap

- [x] Crear el proyecto Flutter
- [x] Configurar Git y GitHub
- [x] Diseñar el modelo UML
- [x] Implementar las clases del modelo (`Usuario`, `Cuidador`, `Paciente`, `Horario`, `BloqueHorario`, `Actividad`, `Paso`)
- [x] Crear la pantalla principal (Home) con listado de actividades
- [x] Crear pantallas de inicio de sesión y registro (autenticación en memoria)
- [x] Crear formulario para agregar actividades, con selector de hora (`TimePicker`) e imagen (cámara/galería)
- [ ] Crear la pantalla de calendario
- [ ] Crear el sistema visual de progreso (widgets `progreso`, `actividadProgress`, `botonGrande`)
- [ ] Implementar persistencia real en `DatabaseService` (actualmente son métodos vacíos)
- [ ] Conectar `AuthService` a un backend o base de datos local
- [ ] Implementar `notification_service.dart` (recordatorios y notificaciones)
- [ ] Publicar primera versión

---

## 🎯 Objetivo

Más que una aplicación, RutinaApp busca ser una herramienta que facilite la autonomía de personas con TEA mediante el uso de rutinas visuales y organizadas.

---

## 👨‍💻 Autor

**Alejandro Herrera Ballestas**

---
