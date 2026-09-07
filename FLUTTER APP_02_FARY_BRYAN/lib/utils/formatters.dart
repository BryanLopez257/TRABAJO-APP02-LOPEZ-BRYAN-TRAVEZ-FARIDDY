import 'package:flutter/services.dart';

// Regex simple para bloquear la mayoría de emojis
final noEmojiFormatter = FilteringTextInputFormatter.deny(
  RegExp(r'(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])'),
);

// Lista blanca estricta para nombres: solo letras (con tildes/ñ) y espacios.
// Bloquea automáticamente números, emojis y caracteres especiales.
final nombreInputFormatter = FilteringTextInputFormatter.allow(
  RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ\s]'),
);

