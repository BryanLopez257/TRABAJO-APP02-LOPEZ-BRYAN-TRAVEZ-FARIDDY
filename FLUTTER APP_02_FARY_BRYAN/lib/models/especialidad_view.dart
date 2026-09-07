class EspecialidadView {
  final int id;
  final String especialidad;

  EspecialidadView({
    required this.id,
    required this.especialidad,
  });

  factory EspecialidadView.fromJson(Map<String, dynamic> json) {
    return EspecialidadView(
      id: json['id'] ?? 0,
      especialidad: json['especialidad'] ?? '',
    );
  }
}
