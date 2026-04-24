import 'package:flutter/material.dart';
import 'package:patirchi/core/dev_mode/widgets/dev_theme.dart';

/// Monospace matn widget.
///
/// Debugger ichida kod, URL, header va boshqa texnik matnlar uchun.
class MonoText extends StatelessWidget {
  const MonoText(
    this.text, {
    super.key,
    this.color,
    this.fontSize = 12,
    this.overflow,
    this.maxLines,
    this.softWrap = true,
    this.fontWeight,
  });

  final String text;
  final Color? color;
  final double fontSize;
  final TextOverflow? overflow;
  final int? maxLines;
  final bool softWrap;
  final FontWeight? fontWeight;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: DevTheme.mono.copyWith(
        color: color ?? DevTheme.textPrimary,
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
      overflow: overflow,
      maxLines: maxLines,
      softWrap: softWrap,
    );
  }
}
