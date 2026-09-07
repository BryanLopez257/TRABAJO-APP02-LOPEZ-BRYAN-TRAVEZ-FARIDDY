class CitaMedicaView {
  final int citaId;
  final String paciente;
  final String doctor;
  final DateTime fechaCita;

  CitaMedicaView({
    required this.citaId,
    required this.paciente,
    required this.doctor,
    required this.fechaCita,
  });

  factory CitaMedicaView.fromJson(Map<String, dynamic> json) {
    return CitaMedicaView(
      citaId: json['citaId'] ?? 0,
      paciente: json['paciente'] ?? '',
      doctor: json['doctor'] ?? '',
      fechaCita: DateTime.parse(json['fechaCita'] ?? '2000-01-01'),
    );
  }
}
