class PacienteView {
  final int id;
  final String paciente;
  final DateTime fechaNacimiento;
  final String direccion;
  final String ciudad;

  PacienteView({
    required this.id,
    required this.paciente,
    required this.fechaNacimiento,
    required this.direccion,
    required this.ciudad,
  });

  factory PacienteView.fromJson(Map<String, dynamic> json) {
    return PacienteView(
      id: json['id'] ?? 0,
      paciente: json['paciente'] ?? '',
      fechaNacimiento: DateTime.parse(json['fecha_NACIMIENTO'] ?? '2000-01-01'),
      direccion: json['direccion'] ?? '',
      ciudad: json['ciudad'] ?? '',
    );
  }
}
