import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/consulta_general.dart';
import '../models/paciente_view.dart';
import '../models/especialidad_view.dart';
import '../models/doctor_view.dart';
import '../models/cita_medica_view.dart';

class ApiService {
  // Cambiar esta URL según tu entorno:
  // - Android emulador: http://10.0.2.2:5020
  // - Windows/Web: http://localhost:5020
  static const String baseUrl = 'http://localhost:5086/api/medicity/distribuida';


  // ============ VISTAS (GET) ============

  // Consulta General
  Future<List<ConsultaGeneral>> getConsultaGeneral() async {
    final response = await http.get(Uri.parse('$baseUrl/view'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => ConsultaGeneral.fromJson(item)).toList();
    } else {
      throw Exception('Error al cargar consulta general');
    }
  }

  // Pacientes
  Future<List<PacienteView>> getPacientes() async {
    final response = await http.get(Uri.parse('$baseUrl/view_pacientes'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => PacienteView.fromJson(item)).toList();
    } else {
      throw Exception('Error al cargar pacientes');
    }
  }

  // Especialidades
  Future<List<EspecialidadView>> getEspecialidades() async {
    final response = await http.get(Uri.parse('$baseUrl/view_especialidades'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => EspecialidadView.fromJson(item)).toList();
    } else {
      throw Exception('Error al cargar especialidades');
    }
  }

  // Doctores
  Future<List<DoctorView>> getDoctores() async {
    final response = await http.get(Uri.parse('$baseUrl/view_doctores'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => DoctorView.fromJson(item)).toList();
    } else {
      throw Exception('Error al cargar doctores');
    }
  }

  // Citas Médicas
  Future<List<CitaMedicaView>> getCitasMedicas() async {
    final response = await http.get(Uri.parse('$baseUrl/view_citaMedica'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => CitaMedicaView.fromJson(item)).toList();
    } else {
      throw Exception('Error al cargar citas médicas');
    }
  }

  // ============ CREAR (POST) ============

  // Crear Doctor
  Future<String> crearDoctor({
    required String nombre,
    required int idEspecialidad,
    required int idCiudad,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/sp_doctor'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'nombre': nombre,
        'idEspecialidad': idEspecialidad,
        'idCiudad': idCiudad,
      }),
    );
    final data = json.decode(response.body);
    if (response.statusCode == 200) {
      return data['mensaje'];
    } else {
      throw Exception(data['mensaje'] ?? 'Error al crear doctor');
    }
  }

  // Crear Especialidad
  Future<String> crearEspecialidad({required String nombre}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/sp_especialidades'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'nombre': nombre}),
    );
    final data = json.decode(response.body);
    if (response.statusCode == 200) {
      return data['mensaje'];
    } else {
      throw Exception(data['mensaje'] ?? 'Error al crear especialidad');
    }
  }

  // ============ ACTUALIZAR (PUT) ============

  // Actualizar Cita Médica
  Future<String> actualizarCita({
    required int id,
    required int idPaciente,
    required int idDoctor,
    required DateTime fechaHora,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'idPaciente': idPaciente,
        'idDoctor': idDoctor,
        'fechaHora': fechaHora.toIso8601String(),
      }),
    );
    final data = json.decode(response.body);
    if (response.statusCode == 200) {
      return data['mensaje'];
    } else {
      throw Exception(data['mensaje'] ?? 'Error al actualizar cita');
    }
  }

  // Actualizar Paciente
  Future<String> actualizarPaciente({
    required int id,
    required String nombre,
    required DateTime fechaNacimiento,
    required String direccion,
    required int idCiudad,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/sp_paciente/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'nombre': nombre,
        'fechaNacimiento': fechaNacimiento.toIso8601String(),
        'direccion': direccion,
        'idCiudad': idCiudad,
      }),
    );
    final data = json.decode(response.body);
    if (response.statusCode == 200) {
      return data['mensaje'];
    } else {
      throw Exception(data['mensaje'] ?? 'Error al actualizar paciente');
    }
  }
}
