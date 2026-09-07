import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/consulta_general.dart';

class ConsultaGeneralScreen extends StatefulWidget {
  const ConsultaGeneralScreen({super.key});

  @override
  State<ConsultaGeneralScreen> createState() => _ConsultaGeneralScreenState();
}

class _ConsultaGeneralScreenState extends State<ConsultaGeneralScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<ConsultaGeneral>> _futureConsultas;

  @override
  void initState() {
    super.initState();
    _futureConsultas = _apiService.getConsultaGeneral();
  }

  void _refresh() {
    setState(() {
      _futureConsultas = _apiService.getConsultaGeneral();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Consulta General'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: FutureBuilder<List<ConsultaGeneral>>(
        future: _futureConsultas,
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
          final consultas = snapshot.data!;
          if (consultas.isEmpty) {
            return const Center(child: Text('No hay datos disponibles'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: consultas.length,
            itemBuilder: (context, index) {
              final c = consultas[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    child: Text('${c.num}'),
                  ),
                  title: Text(c.paciente, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Doctor: ${c.doctor} | ${c.especialidad}'),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _infoRow('Dirección', c.direccion),
                          _infoRow('Ciudad Paciente', c.ciudadPaciente),
                          _infoRow('Ciudad Doctor', c.ciudadDoctor),
                          _infoRow('Fecha Nacimiento', '${c.fechaNacimiento.day}/${c.fechaNacimiento.month}/${c.fechaNacimiento.year}'),
                          _infoRow('Fecha Cita', '${c.fechahora.day}/${c.fechahora.month}/${c.fechahora.year} ${c.fechahora.hour}:${c.fechahora.minute.toString().padLeft(2, '0')}'),
                          _infoRow('Descripción', c.descripcion),
                          _infoRow('Tratamiento', c.tratamiento),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
