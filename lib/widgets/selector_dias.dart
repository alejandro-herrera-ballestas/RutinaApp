import 'package:flutter/material.dart';

// Selector de los días de la semana en que se repite una actividad.
// 1 = lunes ... 7 = domingo (igual que DateTime.weekday).
class SelectorDias extends StatelessWidget {
  final List<int> seleccionados;
  final ValueChanged<List<int>> onCambio;

  // Con habilitado = false solo se muestran los días (el paciente no puede
  // cambiarlos).
  final bool habilitado;

  const SelectorDias({
    super.key,
    required this.seleccionados,
    required this.onCambio,
    this.habilitado = true,
  });

  static const Map<int, String> nombres = {
    1: 'Lun',
    2: 'Mar',
    3: 'Mié',
    4: 'Jue',
    5: 'Vie',
    6: 'Sáb',
    7: 'Dom',
  };

  void _alternarDia(int dia, bool activo) {
    final List<int> nuevos = List<int>.from(seleccionados);

    if (activo) {
      if (!nuevos.contains(dia)) {
        nuevos.add(dia);
      }
    } else {
      nuevos.remove(dia);
    }

    nuevos.sort();
    onCambio(nuevos);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> chips = [];

    for (int dia = 1; dia <= 7; dia++) {
      chips.add(
        FilterChip(
          label: Text(nombres[dia]!),
          selected: seleccionados.contains(dia),
          onSelected: habilitado ? (activo) => _alternarDia(dia, activo) : null,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Días en que se repite',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(spacing: 6, runSpacing: 0, children: chips),
        if (habilitado)
        Wrap(
          spacing: 4,
          children: [
            TextButton(
              onPressed: () => onCambio([1, 2, 3, 4, 5, 6, 7]),
              child: const Text('Todos los días'),
            ),
            TextButton(
              onPressed: () => onCambio([1, 2, 3, 4, 5]),
              child: const Text('Lunes a viernes'),
            ),
            TextButton(
              onPressed: () => onCambio([6, 7]),
              child: const Text('Fin de semana'),
            ),
          ],
        ),
      ],
    );
  }
}
