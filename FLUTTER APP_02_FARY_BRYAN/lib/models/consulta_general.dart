class ConsultaGeneral {
  final int num;
  final String paciente;
  final DateTime fechaNacimiento;
  final String direccion;
  final String ciudadPaciente;
  final String doctor;
  final String ciudadDoctor;
  final String especialidad;
  final DateTime fechahora;
  final String descripcion;
  final String tratamiento;

  ConsultaGeneral({
    required this.num,
    required this.paciente,
    required this.fechaNacimiento,
    required this.direccion,
    required this.ciudadPaciente,
    required this.doctor,
    required this.ciudadDoctor,
    required this.especialidad,
    required this.fechahora,
    required this.descripcion,
    required this.tratamiento,
  });

  factory ConsultaGeneral.fromJson(Map<String, dynamic> json) {
    return ConsultaGeneral(
      num: json['num'] ?? 0,
      paciente: json['paciente'] ?? '',
      fechaNacimiento: DateTime.parse(json['fecha_nacimiento'] ?? '2000-01-01'),
      direccion: json['direccion'] ?? '',
      ciudadPaciente: json['ciudad_paciente'] ?? '',
      doctor: json['doctor'] ?? '',
      ciudadDoctor: json['ciudad_doctor'] ?? '',
      especialidad: json['especialidad'] ?? '',
      fechahora: DateTime.parse(json['fechahora'] ?? '2000-01-01'),
      descripcion: json['descripcion'] ?? '',
      tratamiento: json['tratamiento'] ?? '',
    );
  }
}
