import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:secret_vault_app/core/routing/app_router.dart';
import 'package:secret_vault_app/core/theme/app_theme.dart';

// ─── Secret code configuration ───────────────────────────────────────────────
// To change the secret code, update the value of [_secretCode] below.
// Do NOT commit a real secret code to a public repository.
const String _secretCode = '1234';
// ─────────────────────────────────────────────────────────────────────────────

/// Calculator screen — the app entry point.
/// Looks like a normal calculator but validates a secret code on "=" press.
class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String _display = '0';
  String _input = '';
  bool _showError = false;

  void _onButton(String value) {
    setState(() {
      _showError = false;
      if (value == 'C') {
        _display = '0';
        _input = '';
      } else if (value == '⌫') {
        if (_input.isNotEmpty) {
          _input = _input.substring(0, _input.length - 1);
          _display = _input.isEmpty ? '0' : _input;
        }
      } else if (value == '=') {
        // Validate secret code
        if (_input == _secretCode) {
          context.go(AppRoutes.movies);
        } else {
          _showError = true;
          _display = '0';
          _input = '';
        }
      } else {
        // Normal number/operator input — limit display to 12 chars
        if (_input.length < 12) {
          _input += value;
          _display = _input;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      body: SafeArea(
        child: Column(
          children: [
            // ── Display ──────────────────────────────────────────────────────
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                alignment: Alignment.bottomRight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (_showError)
                      const Text(
                        'Invalid code',
                        style: TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    Text(
                      _display,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 64,
                        fontWeight: FontWeight.w300,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            // ── Keypad ───────────────────────────────────────────────────────
            Expanded(
              flex: 3,
              child: _buildKeypad(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    const rows = [
      ['C', '⌫', '%', '÷'],
      ['7', '8', '9', '×'],
      ['4', '5', '6', '−'],
      ['1', '2', '3', '+'],
      ['0',  '.', '='],
    ];

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: rows.map((row) {
          return Expanded(
            child: Row(
              children: row.map((btn) {
                final isWide = btn == '0';
                return Expanded(
                  flex: isWide ? 2 : 1,
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: _CalcButton(
                      label: btn,
                      onTap: () => _onButton(btn),
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _CalcButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _CalcButton({required this.label, required this.onTap});

  Color get _bgColor {
    switch (label) {
      case 'C':
      case '⌫':
        return const Color(0xFFA5A5A5);
      case '÷':
      case '×':
      case '−':
      case '+':
      case '%':
        return AppTheme.primary;
      case '=':
        return AppTheme.primary;
      default:
        return const Color(0xFF333333);
    }
  }

  Color get _fgColor {
    switch (label) {
      case 'C':
      case '⌫':
        return Colors.black;
      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _bgColor,
      borderRadius: BorderRadius.circular(50),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(50),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: _fgColor,
              fontSize: 24,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
