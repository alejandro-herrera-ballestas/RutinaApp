import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:rutina_app/models/actividad.dart';
import 'package:rutina_app/models/cuidador.dart';
import 'package:rutina_app/models/paciente.dart';
import 'package:rutina_app/models/usuario.dart';
import 'package:rutina_app/screens/login_screen.dart';
import 'package:rutina_app/screens/vincular_paciente_screen.dart';
import 'package:rutina_app/services/storage_service.dart';
import 'package:rutina_app/services/usuario_service.dart';
import 'package:rutina_app/utils/global.dart';
import 'package:rutina_app/widgets/imagen_storage.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {

  final ImagePicker _picker = ImagePicker();
  final UsuarioService _usuarioService = UsuarioService();
  final usuario = authService.usuarioActual;
  final String correo = supabase.auth.currentUser?.email ?? "";
  final String rol = authService.cuidadorActual != null ? "Cuidador" : "Paciente";

  late Future<List<Usuario>> _vinculadosFuture;
  late Future<List<Actividad>> _actividadesHoyFuture;

  bool _subiendoFoto = false;
  int _versionFoto = 0; // sube cada vez que cambia la foto para volver a pedirla

  @override
  void initState() {
    super.initState();
    _vinculadosFuture = _obtenerVinculados();
    _actividadesHoyFuture = _obtenerActividadesHoy();
  }

  void _mostrarMensaje(String texto, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto), backgroundColor: color),
    );
  }

  // Cuidador -> sus pacientes. Paciente -> sus cuidadores.
  Future<List<Usuario>> _obtenerVinculados() async {
    final List<Usuario> vinculados = [];

    if (authService.cuidadorActual != null) {
      // authService.pacientesDelCuidador ya está cargado (con el id
      // correcto, cuidadorId) desde que se inició sesión o se recargó
      // tras vincular un paciente nuevo — no hace falta volver a pedirlo.
      for (final paciente in authService.pacientesDelCuidador) {
        vinculados.add(paciente);
      }
    } else if (authService.pacienteActual != null) {
      final cuidadores = await authService.cuidadorPacienteService
          .obtenerCuidadoresDePaciente(authService.pacienteActual!.pacienteId);
      for (final cuidador in cuidadores) {
        vinculados.add(cuidador);
      }
    }

    return vinculados;
  }

  // Actividades de HOY del paciente seleccionado, con su progreso.
  // Antes las estadísticas leían una lista local en memoria, por eso
  // siempre salían en 0.
  Future<List<Actividad>> _obtenerActividadesHoy() async {
    final pacienteId = authService.pacienteSeleccionado?.pacienteId;
    if (pacienteId == null) return [];

    return await actividadService.obtenerActividadesConProgreso(
      pacienteId,
      DateTime.now(),
    );
  }

  // ============================ Foto de perfil ============================

  // Abre cámara o galería y SUBE la foto a Supabase Storage (bucket
  // 'avatars', carpeta = id del usuario). La ruta queda guardada en
  // usuarios.foto_perfil, así la foto sigue ahí al volver a abrir la app
  // y también la puede ver el cuidador/paciente vinculado.
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 800,
      maxHeight: 800,
    );
    if (pickedFile == null) return;

    final perfil = usuario;
    if (perfil == null) return;

    final String uid = supabase.auth.currentUser?.id ?? perfil.id;

    setState(() {
      _subiendoFoto = true;
    });

    try {
      final String? anterior = perfil.fotoPerfil;

      final String ruta = await storageService.subirImagen(
        bucket: StorageService.bucketAvatares,
        carpeta: uid,
        nombreBase: 'avatar',
        archivo: File(pickedFile.path),
      );

      await _usuarioService.actualizarFotoPerfil(uid, ruta);

      // Si la foto anterior tenía otra extensión (ej: .png), es otro
      // archivo: se borra para no dejarlo huérfano.
      if (anterior != null && anterior.isNotEmpty && anterior != ruta) {
        await storageService.borrar(StorageService.bucketAvatares, anterior);
      }

      ImagenStorage.invalidar(StorageService.bucketAvatares, ruta);
      perfil.fotoPerfil = ruta;

      if (!mounted) return;
      setState(() {
        _versionFoto++;
      });
    } catch (e) {
      if (!mounted) return;
      _mostrarMensaje("No se pudo guardar la foto: $e", Colors.red);
    } finally {
      if (mounted) {
        setState(() {
          _subiendoFoto = false;
        });
      }
    }
  }

  Future<void> _quitarFoto() async {
    final perfil = usuario;
    if (perfil == null) return;

    final String? actual = perfil.fotoPerfil;
    if (actual == null || actual.isEmpty) return;

    final String uid = supabase.auth.currentUser?.id ?? perfil.id;

    setState(() {
      _subiendoFoto = true;
    });

    try {
      await _usuarioService.actualizarFotoPerfil(uid, '');
      await storageService.borrar(StorageService.bucketAvatares, actual);

      ImagenStorage.invalidar(StorageService.bucketAvatares, actual);
      perfil.fotoPerfil = '';

      if (!mounted) return;
      setState(() {
        _versionFoto++;
      });
    } catch (e) {
      if (!mounted) return;
      _mostrarMensaje("No se pudo quitar la foto: $e", Colors.red);
    } finally {
      if (mounted) {
        setState(() {
          _subiendoFoto = false;
        });
      }
    }
  }

  // Foto de perfil redonda (la de Storage o, si no hay, la de assets)
  Widget _construirAvatar() {
    const double tamano = 140;

    final Widget placeholder = ClipOval(
      child: Image.asset(
        'assets/Starter pfp.jpeg',
        width: tamano,
        height: tamano,
        fit: BoxFit.cover,
      ),
    );

    return Stack(
      alignment: Alignment.center,
      children: [
        ImagenStorage(
          bucket: StorageService.bucketAvatares,
          ruta: usuario?.fotoPerfil,
          width: tamano,
          height: tamano,
          circular: true,
          version: _versionFoto,
          placeholder: placeholder,
        ),
        if (_subiendoFoto)
          const CircularProgressIndicator(),
      ],
    );
  }

  // Función para ver la foto en grande
  void _verFotoEnGrande() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(10),
        child: InteractiveViewer(
          panEnabled: true, // Permite mover la imagen
          minScale: 0.5,
          maxScale: 4,
          child: ImagenStorage(
            bucket: StorageService.bucketAvatares,
            ruta: usuario?.fotoPerfil,
            fit: BoxFit.contain,
            version: _versionFoto,
            placeholder: Image.asset(
              'assets/Starter pfp.jpeg',
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }

  // Menú de opciones al tocar la foto
  void _mostrarOpciones() {
    final bool tieneFoto =
        usuario?.fotoPerfil != null && usuario!.fotoPerfil!.isNotEmpty;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.fullscreen),
                title: const Text('Ver foto'),
                onTap: () {
                  Navigator.of(context).pop();
                  _verFotoEnGrande();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Elegir de la biblioteca'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Tomar foto'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              if (tieneFoto)
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text(
                    'Quitar foto',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _quitarFoto();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  // ============================ Vínculo paciente <-> cuidador ============================

  // EL PACIENTE genera un código para que un cuidador se vincule.
  Future<void> _generarCodigo() async {
    try {
      final datos = await authService.cuidadorPacienteService.generarCodigo();

      final String codigo = datos['codigo'].toString();
      final DateTime expira =
          DateTime.parse(datos['expira_en'].toString()).toLocal();

      if (!mounted) return;

      await showDialog(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text("Código para tu cuidador"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Dale este código a tu cuidador. Él lo escribe en "
                  "\"Vincular paciente\" y quedan vinculados.",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                SelectableText(
                  codigo,
                  style: const TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 8,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Vence a las ${DateFormat('HH:mm').format(expira)} "
                  "y sirve una sola vez.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
            actions: [
              TextButton.icon(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: codigo));
                  if (!dialogContext.mounted) return;
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(content: Text("Código copiado")),
                  );
                },
                icon: const Icon(Icons.copy),
                label: const Text("Copiar"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text("Cerrar"),
              ),
            ],
          );
        },
      );
    } catch (e) {
      if (!mounted) return;
      _mostrarMensaje(
        e.toString().replaceFirst('Exception: ', ''),
        Colors.red,
      );
    }
  }

  // QUITAR el vínculo con un paciente (si eres cuidador) o con un cuidador
  // (si eres paciente). No borra ninguna cuenta, solo deja de compartirse.
  Future<void> _quitarVinculo(Usuario otro) async {
    final bool soyCuidador = authService.cuidadorActual != null;

    final bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(soyCuidador ? "Quitar paciente" : "Quitar cuidador"),
          content: Text(
            "¿Quitar a ${otro.nombre}? Dejarán de compartir las actividades. "
            "Para volver a vincularse, el paciente tendrá que generar un "
            "código nuevo.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Quitar", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmar != true) return;

    try {
      String cuidadorId;
      String pacienteId;

      if (soyCuidador) {
        cuidadorId = authService.cuidadorActual!.cuidadorId;
        pacienteId = (otro as Paciente).pacienteId;
      } else {
        cuidadorId = (otro as Cuidador).cuidadorId;
        pacienteId = authService.pacienteActual!.pacienteId;
      }

      await authService.cuidadorPacienteService.desvincular(cuidadorId, pacienteId);

      if (soyCuidador) {
        await authService.recargarPacientesDelCuidador();
      }

      // Se quitan los avisos de las actividades de esa persona
      unawaited(notificationService.sincronizar());

      if (!mounted) return;
      setState(() {
        _vinculadosFuture = _obtenerVinculados();
        _actividadesHoyFuture = _obtenerActividadesHoy();
      });
      _mostrarMensaje("Vínculo eliminado.", Colors.green);
    } catch (e) {
      if (!mounted) return;
      _mostrarMensaje(
        e.toString().replaceFirst('Exception: ', ''),
        Colors.red,
      );
    }
  }

  // ============================ Widgets auxiliares ============================

  // tarjeta de estadisticas
  Widget tarjetaEstadistica(
      String titulo,
      String valor,
      IconData icono,
      ) {
    return Card(
      child: ListTile(
        leading: Icon(icono),
        title: Text(titulo),
        trailing: Text(
          valor,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _construirEstadisticas() {
    return FutureBuilder<List<Actividad>>(
      future: _actividadesHoyFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (snapshot.hasError) {
          return Text("No se pudieron cargar las estadísticas: ${snapshot.error}");
        }

        final actividades = snapshot.data ?? [];
        final int total = actividades.length;

        int completadas = 0;
        for (final actividad in actividades) {
          if (actividad.completada) {
            completadas++;
          }
        }

        final int pendientes = total - completadas;
        final int porcentaje =
            total == 0 ? 0 : ((completadas / total) * 100).round();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            tarjetaEstadistica("Actividades de hoy", "$total", Icons.list_alt),
            tarjetaEstadistica("Completadas", "$completadas", Icons.check_circle),
            tarjetaEstadistica("Pendientes", "$pendientes", Icons.schedule),
            tarjetaEstadistica("Progreso", "$porcentaje%", Icons.show_chart),
            LinearProgressIndicator(
              value: total == 0 ? 0 : completadas / total,
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool soyCuidador = authService.cuidadorActual != null;
    final String? nombrePacienteVisto = authService.pacienteSeleccionado?.nombre;

    return Scaffold(
        appBar: AppBar(title: const Text('Mi Perfil')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              GestureDetector(
                onTap: _mostrarOpciones,
                onLongPress: _verFotoEnGrande,
                child: _construirAvatar(),
              ),

              const SizedBox(width: 20),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    usuario?.nombre ?? "",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    correo.isNotEmpty ? "$correo · $rol" : rol,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(
                    height: 50,
                  ),

                  // estadisticas
                  Text(
                    soyCuidador && nombrePacienteVisto != null
                        ? "Estadísticas de hoy · $nombrePacienteVisto"
                        : "Estadísticas de hoy",
                  ),
                  _construirEstadisticas(),

                  const SizedBox(height: 30),

                  Text(
                    soyCuidador ? "Pacientes asignados" : "Cuidadores vinculados",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  FutureBuilder<List<Usuario>>(
                    future: _vinculadosFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(10.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      if (snapshot.hasError) {
                        return Text("Error: ${snapshot.error}");
                      }
                      final lista = snapshot.data ?? [];
                      if (lista.isEmpty) {
                        return const Text("No hay personas vinculadas aún.");
                      }

                      final List<Widget> filas = [];
                      for (final item in lista) {
                        filas.add(
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            // Foto de la otra persona (el RLS deja verla
                            // solo si están vinculados)
                            leading: ImagenStorage(
                              bucket: StorageService.bucketAvatares,
                              ruta: item.fotoPerfil,
                              width: 44,
                              height: 44,
                              circular: true,
                              placeholder: const CircleAvatar(
                                radius: 22,
                                child: Icon(Icons.person),
                              ),
                            ),
                            title: Text(item.nombre),
                            subtitle: Text(item.email),
                            trailing: IconButton(
                              icon: const Icon(Icons.person_remove, color: Colors.red),
                              tooltip: soyCuidador ? "Quitar paciente" : "Quitar cuidador",
                              onPressed: () => _quitarVinculo(item),
                            ),
                          ),
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: filas,
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.settings),
                    label: const Text("Configuración"),
                  ),

                  const SizedBox(height: 20),

                  // El CUIDADOR escribe el código del paciente.
                  if (soyCuidador)
                    ElevatedButton.icon(
                      onPressed: () async {
                        final resultado = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const VincularPacienteScreen(),
                          ),
                        );
                        if (resultado == true) {
                          setState(() {
                            _vinculadosFuture = _obtenerVinculados();
                            _actividadesHoyFuture = _obtenerActividadesHoy();
                          });
                        }
                      },
                      icon: const Icon(Icons.link),
                      label: const Text("Vincular paciente"),
                    ),

                  // El PACIENTE genera el código (así él acepta el vínculo).
                  if (!soyCuidador)
                    ElevatedButton.icon(
                      onPressed: _generarCodigo,
                      icon: const Icon(Icons.vpn_key),
                      label: const Text("Generar código para un cuidador"),
                    ),

                  const SizedBox(height: 20),

                  ElevatedButton.icon(onPressed: () async {
                    await authService.cerrarSesion();
                    if (!context.mounted) return;
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LoginScreen(),
                      ),
                    );
                  },
                    label: const Text("Cerrar Sesion"),
                    icon: const Icon(Icons.logout),
                  ),
                ],
              ),
            ],
          ),
        )
    );
  }
}
