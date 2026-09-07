class CiudadItem {
  final int id;
  final String nombre;

  const CiudadItem({required this.id, required this.nombre});

  @override
  String toString() => nombre;
}

/// Únicas ciudades existentes en la base de datos y API
const List<CiudadItem> listaCiudades = [
  CiudadItem(id: 1, nombre: 'Quito'),
  CiudadItem(id: 2, nombre: 'Ambato'),
];

CiudadItem? buscarCiudadPorNombre(String? nombre) {
  if (nombre == null || nombre.trim().isEmpty) return null;
  final clean = nombre.trim().toLowerCase();
  try {
    return listaCiudades.firstWhere((c) => c.nombre.toLowerCase() == clean);
  } catch (_) {
    return null;
  }
}

CiudadItem? buscarCiudadPorId(int? id) {
  if (id == null) return null;
  try {
    return listaCiudades.firstWhere((c) => c.id == id);
  } catch (_) {
    return null;
  }
}
