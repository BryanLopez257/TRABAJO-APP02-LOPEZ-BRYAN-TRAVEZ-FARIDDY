import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import '../models/paciente_view.dart';
import '../utils/formatters.dart';
import '../utils/validators.dart';
import '../utils/ciudades.dart';
import '../widgets/combobox_buscador.dart';

class PacientesScreen extends StatefulWidget {
  const PacientesScreen({super.key});

  @override
  State<PacientesScreen> createState() => _PacientesScreenState();
}

class _PacientesScreenState extends State<PacientesScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<PacienteView>> _futurePacientes;

  @override
  void initState() {
    super.initState();
    _futurePacientes = _apiService.getPacientes();
  }

  void _refresh() {
    setState(() {
      _futurePacientes = _apiService.getPacientes();
    });
  }

  void _mostrarDialogoEditar(PacienteView paciente) {
    showDialog(
      context: context,
      builder: (dialogCtx) => _EditarPacienteDialog(
        paciente: paciente,
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
        title: const Text('Pacientes'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: FutureBuilder<List<PacienteView>>(
        future: _futurePacientes,
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
          final pacientes = snapshot.data!;
          if (pacientes.isEmpty) {
            return const Center(child: Text('No hay pacientes'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: pacientes.length,
            itemBuilder: (context, index) {
              final p = pacientes[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    child: Text('${p.id}'),
                  ),
                  title: Text(p.paciente, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${p.ciudad} | ${p.direccion}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.teal),
                    onPressed: () => _mostrarDialogoEditar(p),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _EditarPacienteDialog extends StatefulWidget {
  final PacienteView paciente;
  final ApiService apiService;
  final ValueChanged<String> onSuccess;

  const _EditarPacienteDialog({
    required this.paciente,
    required this.apiService,
    required this.onSuccess,
  });

  @override
  State<_EditarPacienteDialog> createState() => _EditarPacienteDialogState();
}

class _EditarPacienteDialogState extends State<_EditarPacienteDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreCtrl;
  late final TextEditingController _direccionCtrl;
  late DateTime _fechaSeleccionada;
  late int _idCiudadSeleccionada = 1;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nombreCtrl = TextEditingController(text: widget.paciente.paciente);
    _direccionCtrl = TextEditingController(text: widget.paciente.direccion);
    _fechaSeleccionada = widget.paciente.fechaNacimiento;

    final match = buscarCiudadPorNombre(widget.paciente.ciudad);
    _idCiudadSeleccionada = match?.id ?? 1;
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _direccionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Actualizar Paciente'),
      content: SingleChildScrollView(
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
                validator: (val) => FormValidators.validarNombre(val, campo: 'El nombre del paciente'),
                decoration: const InputDecoration(
                  labelText: 'Nombre del Paciente',
                  hintText: 'Solo letras y espacios',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Fecha Nacimiento'),
                subtitle: Text('${_fechaSeleccionada.day}/${_fechaSeleccionada.month}/${_fechaSeleccionada.year}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _fechaSeleccionada,
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() => _fechaSeleccionada = picked);
                  }
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _direccionCtrl,
                inputFormatters: [
                  noEmojiFormatter,
                  LengthLimitingTextInputFormatter(100),
                ],
                validator: FormValidators.validarDireccion,
                decoration: const InputDecoration(
                  labelText: 'Dirección',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.home),
                ),
              ),
              const SizedBox(height: 12),
              ComboboxBuscador<CiudadItem>(
                label: 'Ciudad',
                hintText: 'Buscar ciudad...',
                prefixIcon: Icons.location_city,
                items: listaCiudades,
                itemLabel: (c) => c.nombre,
                initialItem: buscarCiudadPorNombre(widget.paciente.ciudad) ?? buscarCiudadPorId(_idCiudadSeleccionada) ?? listaCiudades.first,
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
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
          onPressed: _isLoading ? null : _guardar,
          child: _isLoading
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Guardar', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _isLoading = true);
    try {
      final msg = await widget.apiService.actualizarPaciente(
        id: widget.paciente.id,
        nombre: _nombreCtrl.text.trim(),
        fechaNacimiento: _fechaSeleccionada,
        direccion: _direccionCtrl.text.trim(),
        idCiudad: _idCiudadSeleccionada,
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

