import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ExpenseKeypadButton extends StatefulWidget {
  final String text;
  final bool isPrimary;
  final bool isAction;
  final VoidCallback onTap;

  const ExpenseKeypadButton({
    super.key,
    required this.text,
    required this.onTap,
    this.isPrimary = false,
    this.isAction = false,
  });

  @override
  State<ExpenseKeypadButton> createState() => _ExpenseKeypadButtonState();
}

class _ExpenseKeypadButtonState extends State<ExpenseKeypadButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) {
      setState(() => _pressed = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    Color background = Colors.white;
    Color foreground = const Color(0xFF1D1D1D);
    double elevation = 0;
    Color splashColor = Colors.black.withValues(alpha: 0.06);

    if (widget.isAction) {
      background = const Color(0xFFE2F0E5);
      foreground = const Color(0xFF0C3D2B);
      splashColor = Colors.black.withValues(alpha: 0.08);
    }

    if (widget.isPrimary) {
      background = const Color(0xFF0C3D2B);
      foreground = Colors.white;
      elevation = 2;
      splashColor = Colors.white.withValues(alpha: 0.2);
    }

    return AnimatedScale(
      scale: _pressed ? 0.94 : 1.0,
      duration: const Duration(milliseconds: 90),
      curve: Curves.easeOut,
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(12),
        elevation: elevation,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: widget.onTap,
          onHighlightChanged: _setPressed,
          splashColor: splashColor,
          child: Center(
            child: Text(
              widget.text,
              style: GoogleFonts.nunito(
                fontSize: widget.text == "C" || widget.text == "⌫" ? 18 : 22,
                fontWeight: widget.isPrimary || widget.isAction
                    ? FontWeight.w700
                    : FontWeight.w600,
                color: foreground,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
