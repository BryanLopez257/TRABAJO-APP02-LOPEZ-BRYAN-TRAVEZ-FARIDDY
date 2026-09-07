import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import '../models/especialidad_view.dart';
import '../utils/formatters.dart';
import '../utils/validators.dart';

class EspecialidadesScreen extends StatefulWidget {
  const EspecialidadesScreen({super.key});

  @override
  State<EspecialidadesScreen> createState() => _EspecialidadesScreenState();
}

class _EspecialidadesScreenState extends State<EspecialidadesScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<EspecialidadView>> _futureEspecialidades;

  @override
  void initState() {
    super.initState();
    _futureEspecialidades = _apiService.getEspecialidades();
  }

  void _refresh() {
    setState(() {
      _futureEspecialidades = _apiService.getEspecialidades();
    });
  }

  void _mostrarDialogoCrear() {
    final formKey = GlobalKey<FormState>();
    final nombreCtrl = TextEditingController();

    final messenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: const Text('Nueva Especialidad'),
          content: Form(
            key: formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: TextFormField(
              controller: nombreCtrl,
              inputFormatters: [
                nombreInputFormatter,
                LengthLimitingTextInputFormatter(50),
              ],
              validator: (val) => FormValidators.validarNombre(val, campo: 'El nombre de la especialidad'),
              decoration: const InputDecoration(
                labelText: 'Nombre de la Especialidad',
                hintText: 'Solo letras y espacios',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancelar')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              onPressed: () async {
                if (!formKey.currentState!.validate()) {
                  return;
                }
                try {
                  final msg = await _apiService.crearEspecialidad(nombre: nombreCtrl.text.trim());
                  if (dialogCtx.mounted) Navigator.pop(dialogCtx);
                  if (mounted) {
                    messenger.showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.green));
                    _refresh();
                  }
                } catch (e) {
                  if (mounted) {
                    messenger.showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
                  }
                }
              },
              child: const Text('Crear', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Especialidades'),
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
      body: FutureBuilder<List<EspecialidadView>>(
        future: _futureEspecialidades,
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
          final especialidades = snapshot.data!;
          if (especialidades.isEmpty) {
            return const Center(child: Text('No hay especialidades'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: especialidades.length,
            itemBuilder: (context, index) {
              final e = especialidades[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    child: Text('${e.id}'),
                  ),
                  title: Text(e.especialidad, style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
