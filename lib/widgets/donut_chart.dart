import 'package:flutter/material.dart';

import '../models/expense.dart';

/// رسم دائري (Donut) مبسّط لتوزيع المصروفات حسب الفئة، بدون أي حزمة خارجية.
class DonutChart extends StatelessWidget {
  const DonutChart({super.key, required this.categories, this.size = 120});

  final List<ExpenseCategory> categories;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _DonutPainter(categories)),
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter(this.categories);

  final List<ExpenseCategory> categories;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    const strokeWidth = 18.0;
    var startAngle = -1.5708; // -90 درجة، يبدأ من الأعلى.

    for (final category in categories) {
      final sweep = (category.percent / 100) * 6.28319;
      final paint = Paint()
        ..color = category.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(
        rect.deflate(strokeWidth / 2),
        startAngle,
        sweep,
        false,
        paint,
      );
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) =>
      oldDelegate.categories != categories;
}
