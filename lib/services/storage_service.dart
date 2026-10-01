import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rutina_app/utils/global.dart';

// Sube, borra y pide el enlace temporal de las imágenes guardadas en
// Supabase Storage. Los buckets son PRIVADOS, por eso se usan enlaces
// firmados (válidos por un tiempo) en vez de enlaces públicos.
class StorageService {
  static const String bucketAvatares = 'avatars';
  static const String bucketActividades = 'actividades';

  String _extension(File archivo) {
    final nombre = archivo.path.toLowerCase();
    if (nombre.endsWith('.png')) return 'png';
    if (nombre.endsWith('.webp')) return 'webp';
    return 'jpg';
  }

  String _tipoMime(String extension) {
    if (extension == 'png') return 'image/png';
    if (extension == 'webp') return 'image/webp';
    return 'image/jpeg';
  }

  // Sube la imagen a "{carpeta}/{nombreBase}.{ext}" y devuelve esa ruta.
  // - Avatares: carpeta = id del usuario, nombreBase = 'avatar'
  // - Actividades: carpeta = id del paciente, nombreBase = un uuid
  // La primera carpeta es la que usan las políticas de seguridad (RLS).
  Future<String> subirImagen({
    required String bucket,
    required String carpeta,
    required String nombreBase,
    required File archivo,
  }) async {
    final extension = _extension(archivo);
    final ruta = '$carpeta/$nombreBase.$extension';

    try {
      await supabase.storage.from(bucket).upload(
            ruta,
            archivo,
            fileOptions: FileOptions(
              upsert: true,
              contentType: _tipoMime(extension),
            ),
          );
      return ruta;
    } catch (e) {
      throw Exception('Error al subir la imagen: $e');
    }
  }

  // Enlace temporal para mostrar una imagen privada (por defecto 1 hora).
  Future<String> obtenerUrlFirmada(String bucket, String ruta,
      {int segundos = 3600}) async {
    try {
      return await supabase.storage.from(bucket).createSignedUrl(ruta, segundos);
    } catch (e) {
      throw Exception('Error al obtener la imagen: $e');
    }
  }

  // Borra una imagen. Si falla no interrumpe nada (solo quedaría un
  // archivo huérfano), por eso no lanza error.
  Future<void> borrar(String bucket, String? ruta) async {
    if (ruta == null || ruta.isEmpty) return;
    try {
      await supabase.storage.from(bucket).remove([ruta]);
    } catch (_) {
      // se ignora a propósito
    }
  }
}
