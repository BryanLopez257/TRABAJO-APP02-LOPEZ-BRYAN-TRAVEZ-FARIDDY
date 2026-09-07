import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import '../models/doctor_view.dart';
import '../models/especialidad_view.dart';
import '../utils/formatters.dart';
import '../utils/validators.dart';
import '../utils/ciudades.dart';
import '../widgets/combobox_buscador.dart';

class DoctoresScreen extends StatefulWidget {
  const DoctoresScreen({super.key});

  @override
  State<DoctoresScreen> createState() => _DoctoresScreenState();
}

class _DoctoresScreenState extends State<DoctoresScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<DoctorView>> _futureDoctores;

  @override
  void initState() {
    super.initState();
    _futureDoctores = _apiService.getDoctores();
  }

  void _refresh() {
    setState(() {
      _futureDoctores = _apiService.getDoctores();
    });
  }

  void _mostrarDialogoCrear() {
    showDialog(
      context: context,
      builder: (dialogCtx) => _CrearDoctorDialog(
        apiService: _apiService,
        onSuccess: (msg) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(msg), backgroundColor: Colors.green),
          );
          _refresh();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctores'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: _mostrarDialogoCrear,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: FutureBuilder<List<DoctorView>>(
        future: _futureDoctores,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}', textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: _refresh, child: const Text('Reintentar')),
                ],
              ),
            );
          }
          final doctores = snapshot.data!;
          if (doctores.isEmpty) {
            return const Center(child: Text('No hay doctores'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: doctores.length,
            itemBuilder: (context, index) {
              final d = doctores[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    child: Text('${d.doctorID}'),
                  ),
                  title: Text(d.nombreDoctor, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${d.especialidad} | ${d.ciudad}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _CrearDoctorDialog extends StatefulWidget {
  final ApiService apiService;
  final ValueChanged<String> onSuccess;

  const _CrearDoctorDialog({
    required this.apiService,
    required this.onSuccess,
  });

  @override
  State<_CrearDoctorDialog> createState() => _CrearDoctorDialogState();
}

class _CrearDoctorDialogState extends State<_CrearDoctorDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  late Future<List<EspecialidadView>> _especialidadesFuture;

  int? _idEspecialidadSeleccionada;
  int? _idCiudadSeleccionada;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _especialidadesFuture = widget.apiService.getEspecialidades();
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nuevo Doctor'),
      content: FutureBuilder<List<EspecialidadView>>(
        future: _especialidadesFuture,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              height: 120,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 12),
                    Text('Cargando especialidades...'),
                  ],
                ),
              ),
            );
          }
          if (snapshot.hasError) {
            return Text('Error al cargar especialidades: ${snapshot.error}');
          }

          final especialidades = snapshot.data ?? [];

          return SingleChildScrollView(
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nombreCtrl,
                    inputFormatters: [
                      nombreInputFormatter,
                      LengthLimitingTextInputFormatter(50),
                    ],
                    validator: (val) => FormValidators.validarNombre(val, campo: 'El nombre del doctor'),
                    decoration: const InputDecoration(
                      labelText: 'Nombre del Doctor',
                      hintText: 'Solo letras y espacios',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ComboboxBuscador<EspecialidadView>(
                    label: 'Especialidad',
                    hintText: 'Buscar especialidad...',
                    prefixIcon: Icons.medical_services,
                    items: especialidades,
                    itemLabel: (e) => e.especialidad,
                    initialItem: null,
                    onSelected: (esp) {
                      setState(() => _idEspecialidadSeleccionada = esp.id);
                    },
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Seleccione una especialidad';
                      }
                      final exists = especialidades.any(
                        (e) => e.especialidad.toLowerCase() == val.trim().toLowerCase(),
                      );
                      if (!exists) {
                        return 'Especialidad no válida. Seleccione de la lista';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  ComboboxBuscador<CiudadItem>(
                    label: 'Ciudad',
                    hintText: 'Buscar ciudad...',
                    prefixIcon: Icons.location_city,
                    items: listaCiudades,
                    itemLabel: (c) => c.nombre,
                    initialItem: null,
                    onSelected: (ciudad) {
                      setState(() => _idCiudadSeleccionada = ciudad.id);
                    },
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Seleccione una ciudad';
                      }
                      final exists = listaCiudades.any(
                        (c) => c.nombre.toLowerCase() == val.trim().toLowerCase(),
                      );
                      if (!exists) {
                        return 'Ciudad no válida. Seleccione de la lista';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
          onPressed: _isLoading ? null : _crear,
          child: _isLoading
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Crear', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Future<void> _crear() async {
    if (!_formKey.currentState!.validate() || _idEspecialidadSeleccionada == null || _idCiudadSeleccionada == null) {
      return;
    }
    setState(() => _isLoading = true);
    try {
      final msg = await widget.apiService.crearDoctor(
        nombre: _nombreCtrl.text.trim(),
        idEspecialidad: _idEspecialidadSeleccionada!,
        idCiudad: _idCiudadSeleccionada!,
      );
      if (mounted) {
        Navigator.pop(context);
        widget.onSuccess(msg);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}

