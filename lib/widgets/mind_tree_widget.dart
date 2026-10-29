import 'package:flutter/material.dart';
import 'dart:math';

class MindTreeWidget extends StatelessWidget {
  final int masteredCount;
  final Color themeColor;

  const MindTreeWidget({
    super.key,
    required this.masteredCount,
    required this.themeColor,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(120, 120),
      painter: _TreePainter(
        masteredCount: masteredCount,
        color: themeColor,
      ),
    );
  }
}

class _TreePainter extends CustomPainter {
  final int masteredCount;
  final Color color;

  _TreePainter({required this.masteredCount, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final trunkPaint = Paint()
      ..color = const Color(0xFF6B4F3A) // Dark brown
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final leafPaint = Paint()
      ..color = color.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;

    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    final centerX = size.width / 2;
    final bottomY = size.height;

    // Draw soft glow behind tree
    if (masteredCount > 0) {
      canvas.drawCircle(
          Offset(centerX, size.height * 0.4), size.width * 0.45, glowPaint);
    }

    // Draw organic trunk
    final trunkPath = Path();
    trunkPath.moveTo(centerX, bottomY);
    trunkPath.quadraticBezierTo(
        centerX - 10, bottomY - 30, centerX - 5, size.height * 0.5);
    trunkPath.quadraticBezierTo(
        centerX + 5, size.height * 0.3, centerX - 15, size.height * 0.2);

    final branch1 = Path();
    branch1.moveTo(centerX - 5, size.height * 0.5);
    branch1.quadraticBezierTo(
        centerX + 20, size.height * 0.4, centerX + 30, size.height * 0.25);

    final branch2 = Path();
    branch2.moveTo(centerX - 5, size.height * 0.5);
    branch2.quadraticBezierTo(
        centerX - 25, size.height * 0.4, centerX - 35, size.height * 0.3);

    canvas.drawPath(trunkPath, trunkPaint);
    canvas.drawPath(branch1, trunkPaint);
    canvas.drawPath(branch2, trunkPaint);

    // Draw leaves
    final random = Random(42); // Fixed seed for consistency
    const int baseLeaves = 5; // Shuru mein 5 patte
    final int dynamicLeaves =
        (masteredCount * 3).clamp(0, 80); // Har mastery pe 3 naye patte
    final int totalLeaves = baseLeaves + dynamicLeaves;

    for (int i = 0; i < totalLeaves; i++) {
      double angle = random.nextDouble() * pi * 2;
      double radius = 15 + random.nextDouble() * 35;

      double leafX = centerX + cos(angle) * radius;
      double leafY = (size.height * 0.3) + sin(angle) * radius;

      canvas.save();
      canvas.translate(leafX, leafY);
      canvas.rotate(angle);
      // Make leaves slightly bigger
      canvas.drawOval(
          Rect.fromCenter(center: Offset.zero, width: 8, height: 12),
          leafPaint);
      canvas.restore();
    }

    // If 0 mastered, draw a tiny seed
    if (masteredCount == 0) {
      canvas.drawCircle(Offset(centerX, size.height * 0.8), 4, leafPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _TreePainter oldDelegate) {
    return oldDelegate.masteredCount != masteredCount ||
        oldDelegate.color != color;
  }
}
