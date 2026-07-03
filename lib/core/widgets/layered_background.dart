import 'dart:math' as math;

import 'package:flutter/material.dart';

/// 白底 + 頂部淡色實心半圓（非全屏漸層）。
class LayeredAuthBackground extends StatelessWidget {
  const LayeredAuthBackground({super.key, required this.child});

  final Widget child;

  /// 半圓弧深約為螢幕寬度的 34%。
  static double semiCircleDepth(double width) => width * 0.34;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final depth = semiCircleDepth(width);

    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: Colors.white),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: depth,
          child: CustomPaint(
            painter: _TopSemiCirclePainter(),
            size: Size(width, depth),
          ),
        ),
        child,
      ],
    );
  }
}

class _TopSemiCirclePainter extends CustomPainter {
  static const _fill = Color(0xFFE3F1EB);

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width * 0.82;
    final center = Offset(size.width / 2, 0);

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..arcTo(
        Rect.fromCircle(center: center, radius: radius),
        0,
        math.pi,
        false,
      )
      ..close();

    canvas.drawPath(path, Paint()..color = _fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
