import 'package:flutter_test/flutter_test.dart';
import 'package:secret_vault_app/features/calculator/domain/calculator_logic.dart';

void main() {
  group('CalculatorLogic - secret code validation', () {
    test('initial display is 0', () {
      final logic = CalculatorLogic.initial();
      expect(logic.display, '0');
    });

    test('initial input is empty', () {
      final logic = CalculatorLogic.initial();
      expect(logic.input, '');
    });

    test('appendChar updates display and input', () {
      final logic = CalculatorLogic.initial().appendChar('4');
      expect(logic.display, '4');
      expect(logic.input, '4');
    });

    test('appendChar chains correctly', () {
      var logic = CalculatorLogic.initial();
      for (final d in ['1', '2', '3', '4']) {
        logic = logic.appendChar(d);
      }
      expect(logic.input, '1234');
    });

    test('deleteLast removes last character', () {
      var logic = CalculatorLogic.initial()
          .appendChar('1')
          .appendChar('2')
          .appendChar('3')
          .deleteLast();
      expect(logic.input, '12');
      expect(logic.display, '12');
    });

    test('deleteLast on empty stays at 0', () {
      final logic = CalculatorLogic.initial().deleteLast();
      expect(logic.input, '');
      expect(logic.display, '0');
    });

    test('deleteLast last char resets display to 0', () {
      final logic =
          CalculatorLogic.initial().appendChar('5').deleteLast();
      expect(logic.input, '');
      expect(logic.display, '0');
    });

    test('clear resets to initial state', () {
      final logic = CalculatorLogic.initial()
          .appendChar('9')
          .appendChar('9')
          .clear();
      expect(logic.input, '');
      expect(logic.display, '0');
    });

    test('isCorrectCode returns true for matching secret', () {
      var logic = CalculatorLogic.initial();
      for (final d in ['1', '2', '3', '4']) {
        logic = logic.appendChar(d);
      }
      // Default secret code is '1234' — change in env.dart / calculator_page.dart
      expect(logic.isCorrectCode('1234'), isTrue);
    });

    test('isCorrectCode returns false for wrong code', () {
      var logic = CalculatorLogic.initial();
      for (final d in ['9', '9', '9', '9']) {
        logic = logic.appendChar(d);
      }
      expect(logic.isCorrectCode('1234'), isFalse);
    });

    test('isCorrectCode returns false for empty input', () {
      final logic = CalculatorLogic.initial();
      expect(logic.isCorrectCode('1234'), isFalse);
    });

    test('isCorrectCode is case-sensitive', () {
      var logic = CalculatorLogic.initial().appendChar('A').appendChar('B');
      expect(logic.isCorrectCode('ab'), isFalse);
      expect(logic.isCorrectCode('AB'), isTrue);
    });

    test('appendChar enforces max length of 12', () {
      var logic = CalculatorLogic.initial();
      for (int i = 0; i < 20; i++) {
        logic = logic.appendChar('1');
      }
      expect(logic.input.length, 12);
    });

    test('immutability: original logic unchanged after appendChar', () {
      final original = CalculatorLogic.initial();
      original.appendChar('5');
      expect(original.input, '');
    });
  });
}
