import 'package:flutter/material.dart';

class BarChartData {
  final String label;
  final double value;
  final Color color;

  const BarChartData({
    required this.label,
    required this.value,
    required this.color,
  });
}

class SimpleBarChart extends StatefulWidget {
  final List<BarChartData> data;
  final double? maxValue;
  final double height;
  final double barWidth;
  final bool showYLabels;
  final bool showGridLines;

  const SimpleBarChart({
    super.key,
    required this.data,
    this.maxValue,
    this.height = 160,
    this.barWidth = 20,
    this.showYLabels = true,
    this.showGridLines = true,
  });

  @override
  State<SimpleBarChart> createState() => _SimpleBarChartState();
}

class _SimpleBarChartState extends State<SimpleBarChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(SimpleBarChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) return SizedBox(height: widget.height);

    final maxVal = widget.maxValue ??
        widget.data.map((d) => d.value).reduce((a, b) => a > b ? a : b);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return SizedBox(
          height: widget.height,
          child: CustomPaint(
            painter: _BarChartPainter(
              data: widget.data,
              maxValue: maxVal == 0 ? 1 : maxVal,
              animationValue: _animation.value,
              barWidth: widget.barWidth,
              showYLabels: widget.showYLabels,
              showGridLines: widget.showGridLines,
            ),
            child: const SizedBox.expand(),
          ),
        );
      },
    );
  }
}

class _BarChartPainter extends CustomPainter {
  final List<BarChartData> data;
  final double maxValue;
  final double animationValue;
  final double barWidth;
  final bool showYLabels;
  final bool showGridLines;

  static const double _labelHeight = 20;
  static const double _yLabelWidth = 40;
  static const int _gridLines = 4;

  const _BarChartPainter({
    required this.data,
    required this.maxValue,
    required this.animationValue,
    required this.barWidth,
    required this.showYLabels,
    required this.showGridLines,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final chartLeft = showYLabels ? _yLabelWidth : 8.0;
    final chartRight = size.width - 8;
    final chartTop = 8.0;
    final chartBottom = size.height - _labelHeight;
    final chartWidth = chartRight - chartLeft;
    final chartHeight = chartBottom - chartTop;

    // Draw grid lines
    if (showGridLines) {
      final gridPaint = Paint()
        ..color = Colors.grey.withValues(alpha: 0.2)
        ..strokeWidth = 1;

      for (var i = 0; i <= _gridLines; i++) {
        final y = chartBottom - (chartHeight / _gridLines) * i;
        canvas.drawLine(
          Offset(chartLeft, y),
          Offset(chartRight, y),
          gridPaint,
        );

        // Y-axis labels
        if (showYLabels) {
          final value = (maxValue / _gridLines * i);
          final label = _formatValue(value);
          final tp = TextPainter(
            text: TextSpan(
              text: label,
              style: const TextStyle(
                color: Color(0xFF9E9E9E),
                fontSize: 9,
              ),
            ),
            textDirection: TextDirection.ltr,
          )..layout(maxWidth: _yLabelWidth - 4);
          tp.paint(
            canvas,
            Offset(0, y - tp.height / 2),
          );
        }
      }
    }

    // Draw bars
    final barPaint = Paint()..style = PaintingStyle.fill;
    final n = data.length;
    final slotWidth = chartWidth / n;

    for (var i = 0; i < n; i++) {
      final d = data[i];
      final barH = (d.value / maxValue) * chartHeight * animationValue;
      final slotCenter = chartLeft + slotWidth * i + slotWidth / 2;
      final barLeft = slotCenter - barWidth / 2;
      final barTop = chartBottom - barH;

      barPaint.color = d.color;
      final rrect = RRect.fromLTRBAndCorners(
        barLeft,
        barTop.clamp(chartTop, chartBottom),
        barLeft + barWidth,
        chartBottom,
        topLeft: const Radius.circular(4),
        topRight: const Radius.circular(4),
      );
      canvas.drawRRect(rrect, barPaint);

      // X-axis label
      final tp = TextPainter(
        text: TextSpan(
          text: d.label,
          style: const TextStyle(
            color: Color(0xFF9E9E9E),
            fontSize: 9,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: slotWidth);
      tp.paint(
        canvas,
        Offset(
          slotCenter - tp.width / 2,
          chartBottom + 4,
        ),
      );
    }
  }

  String _formatValue(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}k';
    return v.toStringAsFixed(0);
  }

  @override
  bool shouldRepaint(_BarChartPainter old) =>
      old.animationValue != animationValue ||
      old.data != data ||
      old.maxValue != maxValue;
}
