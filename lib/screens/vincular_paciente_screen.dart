import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VincularPacienteScreen extends StatefulWidget {
  const VincularPacienteScreen({Key? key}) : super(key: key);

  @override
  State<VincularPacienteScreen> createState() => _VincularPacienteScreenState();
}

class _VincularPacienteScreenState extends State<VincularPacienteScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  final TextEditingController _codigoController = TextEditingController();

  bool _isLoading = false;
  bool _isSearching = false;

  List<Map<String, dynamic>> _pacientesVinculados = [];
  Map<String, dynamic>? _pacienteEncontrado;

  @override
  void initState() {
    super.initState();
    _cargarPacientesVinculados();
  }

  @override
  void dispose() {
    _codigoController.dispose();
    super.dispose();
  }

  // 1. Cargar la lista de pacientes vinculados al cuidador actual
  Future<void> _cargarPacientesVinculados() async {
    final String? userId = _supabase.auth.currentUser?.id;

    if (userId == null) {
      _mostrarMensaje('No hay un usuario autenticado activo.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Realizamos el JOIN con la tabla 'paciente' utilizando la relación cuidador_id -> paciente_id
      final response = await _supabase
          .from('cuidador_paciente')
          .select('paciente_id, paciente(*)')
          .eq('cuidador_id', userId);

      final List<Map<String, dynamic>> listaTemporal = [];

      for (var item in (response as List)) {
        if (item['paciente'] != null) {
          listaTemporal.add(item['paciente'] as Map<String, dynamic>);
        }
      }

      setState(() {
        _pacientesVinculados = listaTemporal;
      });
    } catch (e) {
      _mostrarMensaje('Error al obtener la lista de pacientes: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 2. Buscar paciente por ID o Código de vinculación
  Future<void> _buscarPaciente() async {
    final codigo = _codigoController.text.trim();

    if (codigo.isEmpty) {
      _mostrarMensaje('Por favor ingresa un código o identificador de paciente.');
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isSearching = true;
      _pacienteEncontrado = null;
    });

    try {
      // Buscamos al paciente por su ID (UUID)
      final paciente = await _supabase
          .from('paciente')
          .select()
          .eq('id', codigo)
          .maybeSingle();

      if (paciente == null) {
        _mostrarMensaje('No se encontró ningún paciente con ese identificador.');
      } else {
        setState(() {
          _pacienteEncontrado = paciente;
        });
      }
    } catch (e) {
      _mostrarMensaje('Error en la búsqueda del paciente: $e');
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  // 3. Vincular el paciente encontrado al cuidador actual
  Future<void> _vincularPaciente() async {
    final String? idCuidador = _supabase.auth.currentUser?.id;

    if (idCuidador == null) {
      _mostrarMensaje('Sesión no válida. Por favor inicia sesión nuevamente.');
      return;
    }

    if (_pacienteEncontrado == null) {
      _mostrarMensaje('Selecciona un paciente válido para vincular.');
      return;
    }

    final String idPaciente = _pacienteEncontrado!['id'].toString();

    // Verificación preliminar local: si ya está en la lista mostrada
    final yaExisteEnLista = _pacientesVinculados.any((p) => p['id'].toString() == idPaciente);
    if (yaExisteEnLista) {
      _mostrarMensaje('Este paciente ya se encuentra vinculado a tu cuenta.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Verificación en Supabase
      final existeRelacion = await _supabase
          .from('cuidador_paciente')
          .select()
          .eq('cuidador_id', idCuidador)
          .eq('paciente_id', idPaciente)
          .maybeSingle();

      if (existeRelacion != null) {
        _mostrarMensaje('Este paciente ya está vinculado a tu cuenta.');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Inserción en la tabla de unión
      await _supabase.from('cuidador_paciente').insert({
        'cuidador_id': idCuidador,
        'paciente_id': idPaciente,
      });

      _mostrarMensaje('¡Paciente vinculado exitosamente!', esError: false);

      // Limpiar formulario y actualizar la lista de la pantalla
      _codigoController.clear();
      setState(() {
        _pacienteEncontrado = null;
      });

      await _cargarPacientesVinculados();
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        _mostrarMensaje('Este paciente ya se encuentra vinculado.');
      } else {
        _mostrarMensaje('Error de base de datos: ${e.message}');
      }
    } catch (e) {
      _mostrarMensaje('Error inesperado al vincular: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _mostrarMensaje(String mensaje, {bool esError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: esError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vincular Paciente'),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _cargarPacientesVinculados,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- SECCIÓN: Búsqueda y Vinculación ---
              const Text(
                'Ingresa el ID del Paciente',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _codigoController,
                      decoration: InputDecoration(
                        hintText: 'Ej: UUID del paciente',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isSearching ? null : _buscarPaciente,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isSearching
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Icon(Icons.search),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // --- SECCIÓN: Resultado de Búsqueda ---
              if (_pacienteEncontrado != null) ...[
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 24,
                          child: Icon(Icons.person),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _pacienteEncontrado!['nombre'] ?? 'Sin Nombre',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              if (_pacienteEncontrado!['edad'] != null)
                                Text('Edad: ${_pacienteEncontrado!['edad']} años'),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _vincularPaciente,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          child: const Text('Vincular'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              const Divider(height: 32),

              // --- SECCIÓN: Pacientes Vinculados ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Pacientes Vinculados',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _cargarPacientesVinculados,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (_isLoading && _pacientesVinculados.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_pacientesVinculados.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Text(
                      'No tienes pacientes vinculados actualmente.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _pacientesVinculados.length,
                  itemBuilder: (context, index) {
                    final paciente = _pacientesVinculados[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.person_outline),
                        ),
                        title: Text(
                          paciente['nombre'] ?? 'Paciente sin nombre',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text('ID: ${paciente['id']}'),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}