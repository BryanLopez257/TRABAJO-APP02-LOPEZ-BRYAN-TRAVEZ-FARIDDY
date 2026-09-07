import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/cita_medica_view.dart';
import '../models/paciente_view.dart';
import '../models/doctor_view.dart';

class CitasScreen extends StatefulWidget {
  const CitasScreen({super.key});

  @override
  State<CitasScreen> createState() => _CitasScreenState();
}

class _CitasScreenState extends State<CitasScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<CitaMedicaView>> _futureCitas;

  @override
  void initState() {
    super.initState();
    _futureCitas = _apiService.getCitasMedicas();
  }

  void _refresh() {
    setState(() {
      _futureCitas = _apiService.getCitasMedicas();
    });
  }

  void _mostrarDialogoEditar(CitaMedicaView cita) {
    showDialog(
      context: context,
      builder: (dialogCtx) => _EditarCitaDialog(
        cita: cita,
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
        title: const Text('Citas Médicas'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: FutureBuilder<List<CitaMedicaView>>(
        future: _futureCitas,
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
          final citas = snapshot.data!;
          if (citas.isEmpty) {
            return const Center(child: Text('No hay citas médicas'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: citas.length,
            itemBuilder: (context, index) {
              final c = citas[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    child: Text('${c.citaId}'),
                  ),
                  title: Text('Paciente: ${c.paciente}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Doctor: ${c.doctor}\nFecha: ${c.fechaCita.day}/${c.fechaCita.month}/${c.fechaCita.year}'),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.teal),
                    onPressed: () => _mostrarDialogoEditar(c),
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

class _EditarCitaDialog extends StatefulWidget {
  final CitaMedicaView cita;
  final ApiService apiService;
  final ValueChanged<String> onSuccess;

  const _EditarCitaDialog({
    required this.cita,
    required this.apiService,
    required this.onSuccess,
  });

  @override
  State<_EditarCitaDialog> createState() => _EditarCitaDialogState();
}

class _EditarCitaDialogState extends State<_EditarCitaDialog> {
  final _formKey = GlobalKey<FormState>();
  late Future<List<dynamic>> _dataFuture;
  late DateTime _fechaSeleccionada;
  late TimeOfDay _horaSeleccionada;
  int? _idPacienteSeleccionado;
  int? _idDoctorSeleccionado;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fechaSeleccionada = widget.cita.fechaCita;
    _horaSeleccionada = TimeOfDay.fromDateTime(widget.cita.fechaCita);
    _dataFuture = Future.wait([
      widget.apiService.getPacientes(),
      widget.apiService.getDoctores(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Actualizar Cita #${widget.cita.citaId}'),
      content: FutureBuilder<List<dynamic>>(
        future: _dataFuture,
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
                    Text('Cargando listas...'),
                  ],
                ),
              ),
            );
          }
          if (snapshot.hasError) {
            return Text('Error al cargar datos: ${snapshot.error}');
          }

          final pacientes = snapshot.data![0] as List<PacienteView>;
          final doctores = snapshot.data![1] as List<DoctorView>;

          if (_idPacienteSeleccionado == null && pacientes.isNotEmpty) {
            final match = pacientes.where(
              (p) => p.paciente.trim().toLowerCase() == widget.cita.paciente.trim().toLowerCase(),
            );
            _idPacienteSeleccionado = match.isNotEmpty ? match.first.id : pacientes.first.id;
          }

          if (_idDoctorSeleccionado == null && doctores.isNotEmpty) {
            final match = doctores.where(
              (d) => d.nombreDoctor.trim().toLowerCase() == widget.cita.doctor.trim().toLowerCase(),
            );
            _idDoctorSeleccionado = match.isNotEmpty ? match.first.doctorID : doctores.first.doctorID;
          }

          return SingleChildScrollView(
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<int>(
                    initialValue: _idPacienteSeleccionado,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Paciente',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    items: pacientes.map((p) {
                      return DropdownMenuItem<int>(
                        value: p.id,
                        child: Text(p.paciente, overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() => _idPacienteSeleccionado = val);
                    },
                    validator: (val) => val == null ? 'Seleccione un paciente' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    initialValue: _idDoctorSeleccionado,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Doctor',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.medical_services),
                    ),
                    items: doctores.map((d) {
                      return DropdownMenuItem<int>(
                        value: d.doctorID,
                        child: Text('${d.nombreDoctor} - ${d.especialidad}', overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() => _idDoctorSeleccionado = val);
                    },
                    validator: (val) => val == null ? 'Seleccione un doctor' : null,
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Fecha'),
                    subtitle: Text('${_fechaSeleccionada.day}/${_fechaSeleccionada.month}/${_fechaSeleccionada.year}'),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _fechaSeleccionada,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        setState(() => _fechaSeleccionada = picked);
                      }
                    },
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Hora'),
                    subtitle: Text('${_horaSeleccionada.hour.toString().padLeft(2, '0')}:${_horaSeleccionada.minute.toString().padLeft(2, '0')}'),
                    trailing: const Icon(Icons.access_time),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: _horaSeleccionada,
                      );
                      if (picked != null) {
                        setState(() => _horaSeleccionada = picked);
                      }
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
          onPressed: _isLoading ? null : _guardar,
          child: _isLoading
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Actualizar', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate() || _idPacienteSeleccionado == null || _idDoctorSeleccionado == null) {
      return;
    }
    setState(() => _isLoading = true);
    try {
      final fechaHora = DateTime(
        _fechaSeleccionada.year,
        _fechaSeleccionada.month,
        _fechaSeleccionada.day,
        _horaSeleccionada.hour,
        _horaSeleccionada.minute,
      );
      final msg = await widget.apiService.actualizarCita(
        id: widget.cita.citaId,
        idPaciente: _idPacienteSeleccionado!,
        idDoctor: _idDoctorSeleccionado!,
        fechaHora: fechaHora,
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

