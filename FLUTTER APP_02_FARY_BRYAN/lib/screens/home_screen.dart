import 'package:flutter/material.dart';
import 'consulta_general_screen.dart';
import 'pacientes_screen.dart';
import 'doctores_screen.dart';
import 'especialidades_screen.dart';
import 'citas_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final menuItems = [
      _MenuItem('Consulta General', Icons.list_alt, Colors.blue, const ConsultaGeneralScreen()),
      _MenuItem('Pacientes', Icons.people, Colors.green, const PacientesScreen()),
      _MenuItem('Doctores', Icons.person, Colors.orange, const DoctoresScreen()),
      _MenuItem('Especialidades', Icons.medical_services, Colors.purple, const EspecialidadesScreen()),
      _MenuItem('Citas Médicas', Icons.calendar_today, Colors.red, const CitasScreen()),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicity'),
        centerTitle: true,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sistema Médico Distribuido',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Fary & Bryan',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: menuItems.map((item) {
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => item.screen),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: item.color.withValues(alpha: 0.15),
                        child: Icon(item.icon, size: 18, color: item.color),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem {
  final String title;
  final IconData icon;
  final Color color;
  final Widget screen;
  _MenuItem(this.title, this.icon, this.color, this.screen);
}
