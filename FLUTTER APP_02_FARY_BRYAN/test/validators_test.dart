import 'package:flutter_test/flutter_test.dart';
import 'package:app_02_fary_bryan/utils/validators.dart';

void main() {
  group('FormValidators - validarNombre', () {
    test('rechaza nombres vacíos o solo espacios', () {
      expect(FormValidators.validarNombre(''), isNotNull);
      expect(FormValidators.validarNombre('   '), isNotNull);
      expect(FormValidators.validarNombre(null), isNotNull);
    });

    test('rechaza nombres con menos de 3 caracteres', () {
      expect(FormValidators.validarNombre('Ab'), isNotNull);
    });

    test('rechaza nombres con números', () {
      expect(FormValidators.validarNombre('Carlos 2do'), isNotNull);
      expect(FormValidators.validarNombre('12345'), isNotNull);
    });

    test('rechaza nombres con símbolos o emojis', () {
      expect(FormValidators.validarNombre('Juan 👨‍⚕️'), isNotNull);
      expect(FormValidators.validarNombre('Doctor@#'), isNotNull);
    });

    test('acepta nombres válidos con tildes, diéresis y ñ', () {
      expect(FormValidators.validarNombre('María José'), isNull);
      expect(FormValidators.validarNombre('Agüero Peña'), isNull);
      expect(FormValidators.validarNombre('Bryan Caiza'), isNull);
    });
  });

  group('FormValidators - validarIdNumerico', () {
    test('rechaza valores no numéricos o vacíos', () {
      expect(FormValidators.validarIdNumerico(''), isNotNull);
      expect(FormValidators.validarIdNumerico('abc'), isNotNull);
      expect(FormValidators.validarIdNumerico('0'), isNotNull);
      expect(FormValidators.validarIdNumerico('-5'), isNotNull);
    });

    test('acepta enteros positivos mayores a 0', () {
      expect(FormValidators.validarIdNumerico('1'), isNull);
      expect(FormValidators.validarIdNumerico('42'), isNull);
    });
  });
}
