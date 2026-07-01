/// Pure logic class for the calculator secret code validation.
/// Extracted from the UI to allow unit testing without Flutter dependencies.
///
/// To change the secret code, update AppConstants.secretCode or
/// the _secretCode constant in calculator_page.dart.
class CalculatorLogic {
  final String _display;
  final String _input;

  const CalculatorLogic({
    String display = '0',
    String input = '',
  })  : _display = display,
        _input = input;

  /// The text shown in the calculator display
  String get display => _display;

  /// The raw input string (never shown to user directly in plain form)
  String get input => _input;

  /// Factory to create initial state
  factory CalculatorLogic.initial() =>
      const CalculatorLogic(display: '0', input: '');

  /// Append a digit or operator character (max 12 chars)
  CalculatorLogic appendChar(String char) {
    if (_input.length >= 12) return this;
    final newInput = _input + char;
    return CalculatorLogic(display: newInput, input: newInput);
  }

  /// Remove the last character from input
  CalculatorLogic deleteLast() {
    if (_input.isEmpty) return this;
    final newInput = _input.substring(0, _input.length - 1);
    return CalculatorLogic(
      display: newInput.isEmpty ? '0' : newInput,
      input: newInput,
    );
  }

  /// Clear input and display
  CalculatorLogic clear() =>
      const CalculatorLogic(display: '0', input: '');

  /// Returns true if current input matches the given secret code
  bool isCorrectCode(String secretCode) =>
      _input.isNotEmpty && _input == secretCode;
}
