# 📅 RutinaApp

RutinaApp es una aplicación móvil desarrollada con **Flutter** cuyo objetivo es ayudar a personas con Trastorno del Espectro Autista (TEA) a seguir sus rutinas diarias mediante una interfaz simple, intuitiva y visual.

---

## ✨ Características

- 📆 Organización de rutinas diarias.
- ✅ Seguimiento de actividades completadas.
- 📝 Actividades con instrucciones paso a paso.
- 🔔 Recordatorios y notificaciones.
- 👨‍👦 Administración de pacientes por parte de un cuidador.
- 📊 Seguimiento del progreso diario.
- 🎨 Interfaz sencilla y amigable para personas con TEA.
- 📱 Aplicación multiplataforma gracias a Flutter.

---

## 🛠️ Tecnologías

- Flutter
- Dart
- Material Design 3
- Android Studio
- Git
- GitHub

---

## 📂 Arquitectura del proyecto

```
lib/
│
├── models/
│   ├── usuario.dart
│   ├── cuidador.dart
│   ├── paciente.dart
│   ├── horario.dart
│   ├── rutina.dart
│   ├── actividad.dart
│   ├── paso.dart
│   ├── progreso.dart
│   └── configuracion.dart
│
├──services/
│   ├── auth_service.dart
│   ├── database_service.dart
│   ├── notification_service.dart
│
├── screens/
│
├── utils/
│
└── main.dart
```

---

## 🧩 Modelo del sistema

El sistema está basado en Programación Orientada a Objetos.

### Usuarios

- Usuario (abstracto)
  - Cuidador
  - Paciente

### Organización

Paciente
→ Horario
→ Rutinas
→ Actividades
→ Pasos

---

## 🚀 Estado del proyecto

Actualmente el proyecto se encuentra en desarrollo.

### Roadmap

- [x] Crear el proyecto Flutter
- [x] Configurar Git y GitHub
- [x] Diseñar el modelo UML
- [x] Implementar las clases del modelo
- [ ] Crear la pantalla principal
- [ ] Crear la pantalla de calendario
- [ ] Crear el sistema de progreso
- [ ] Implementar base de datos local
- [ ] Implementar autenticación
- [ ] Agregar notificaciones
- [ ] Publicar primera versión

---

## 🎯 Objetivo

Más que una aplicación, RutinaApp busca ser una herramienta que facilite la autonomía de personas con TEA mediante el uso de rutinas visuales y organizadas.

---

## 👨‍💻 Autor

**Alejandro Herrera Ballestas**

---
