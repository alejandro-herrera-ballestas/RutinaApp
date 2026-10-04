import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rutina_app/utils/global.dart';

class _UrlEnCache {
  final String url;
  final DateTime expira;

  _UrlEnCache(this.url, this.expira);
}

// Muestra una imagen guardada en un bucket privado de Supabase Storage.
// Pide el enlace firmado, lo guarda en memoria 50 minutos (el enlace dura
// 60) y muestra un "placeholder" mientras carga o si no hay imagen.
//
// Si cambias la imagen que vive en la MISMA ruta (como la foto de perfil),
// llama a ImagenStorage.invalidar(...) y sube el parámetro 'version'
// para que se vuelva a pedir.
class ImagenStorage extends StatefulWidget {
  final String bucket;
  final String? ruta;
  final double? width;
  final double? height;
  final BoxFit fit;
  final bool circular;
  final Widget? placeholder;
  final int version;

  const ImagenStorage({
    super.key,
    required this.bucket,
    required this.ruta,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.circular = false,
    this.placeholder,
    this.version = 0,
  });

  static final Map<String, _UrlEnCache> _cache = {};

  static void invalidar(String bucket, String? ruta) {
    if (ruta == null) return;
    _cache.remove('$bucket/$ruta');
  }

  @override
  State<ImagenStorage> createState() => _ImagenStorageState();
}

class _ImagenStorageState extends State<ImagenStorage> {
  late Future<String?> _futuroUrl;

  @override
  void initState() {
    super.initState();
    _futuroUrl = _resolverUrl();
  }

  @override
  void didUpdateWidget(covariant ImagenStorage anterior) {
    super.didUpdateWidget(anterior);
    if (anterior.ruta != widget.ruta ||
        anterior.bucket != widget.bucket ||
        anterior.version != widget.version) {
      _futuroUrl = _resolverUrl();
    }
  }

  Future<String?> _resolverUrl() async {
    final ruta = widget.ruta;
    if (ruta == null || ruta.isEmpty) return null;

    final clave = '${widget.bucket}/$ruta';
    final enCache = ImagenStorage._cache[clave];
    if (enCache != null && enCache.expira.isAfter(DateTime.now())) {
      return enCache.url;
    }

    try {
      final url = await storageService.obtenerUrlFirmada(widget.bucket, ruta);
      ImagenStorage._cache[clave] =
          _UrlEnCache(url, DateTime.now().add(const Duration(minutes: 50)));
      return url;
    } catch (e) {
      // Ruta antigua (ej: ruta local del celular) o sin permiso: placeholder.
      // Se imprime para poder ver la causa en la consola de flutter run.
      debugPrint('ImagenStorage: no se pudo firmar "$ruta": $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget placeholder = widget.placeholder ??
        Container(
          width: widget.width,
          height: widget.height,
          color: Colors.grey.shade200,
          child: const Icon(Icons.image_outlined, color: Colors.grey),
        );

    final Widget contenido = FutureBuilder<String?>(
      future: _futuroUrl,
      builder: (context, snapshot) {
        final url = snapshot.data;
        if (url == null) return placeholder;

        return Image.network(
          url,
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
          gaplessPlayback: true,
          errorBuilder: (_, error, __) {
            debugPrint('ImagenStorage: no se pudo mostrar "${widget.ruta}": $error');
            return placeholder;
          },
        );
      },
    );

    if (widget.circular) {
      return ClipOval(child: contenido);
    }
    return contenido;
  }
}
