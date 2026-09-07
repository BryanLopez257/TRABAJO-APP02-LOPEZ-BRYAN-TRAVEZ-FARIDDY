class DoctorView {
  final int doctorID;
  final String nombreDoctor;
  final String especialidad;
  final String ciudad;

  DoctorView({
    required this.doctorID,
    required this.nombreDoctor,
    required this.especialidad,
    required this.ciudad,
  });

  factory DoctorView.fromJson(Map<String, dynamic> json) {
    return DoctorView(
      doctorID: json['doctorID'] ?? 0,
      nombreDoctor: json['nombreDoctor'] ?? '',
      especialidad: json['especialidad'] ?? '',
      ciudad: json['ciudad'] ?? '',
    );
  }
}
