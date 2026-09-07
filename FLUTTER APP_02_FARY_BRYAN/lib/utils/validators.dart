class FormValidators {
  /// Valida nombres de personas o entidades (solo letras y espacios, sin números ni emojis)
  static String? validarNombre(String? value, {String campo = 'El nombre'}) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return '$campo es obligatorio.';
    }
    if (text.length < 3) {
      return '$campo debe tener al menos 3 caracteres.';
    }
    if (text.length > 50) {
      return '$campo no puede superar los 50 caracteres.';
    }
    final validNameRegex = RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ\s]+$');
    if (!validNameRegex.hasMatch(text)) {
      return '$campo solo puede contener letras y espacios.';
    }
    return null;
  }

  /// Valida identificadores numéricos positivos
  static String? validarIdNumerico(String? value, {String campo = 'El ID'}) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return '$campo es obligatorio.';
    }
    final number = int.tryParse(text);
    if (number == null || number <= 0) {
      return '$campo debe ser un número entero mayor a 0.';
    }
    return null;
  }

  /// Valida direcciones de domicilio
  static String? validarDireccion(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'La dirección es obligatoria.';
    }
    if (text.length < 4) {
      return 'La dirección debe tener al menos 4 caracteres.';
    }
    if (text.length > 100) {
      return 'La dirección no puede superar los 100 caracteres.';
    }
    return null;
  }
}
