import 'package:flutter/material.dart';

class ShuttlecockIcon extends StatelessWidget {
  const ShuttlecockIcon({
    super.key,
    this.size = 22,
    this.color = Colors.white,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _ShuttlecockPainter(color),
    );
  }
}

class _ShuttlecockPainter extends CustomPainter {
  _ShuttlecockPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.09
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final cx = size.width / 2;
    final cork = Rect.fromCenter(
      center: Offset(cx, size.height * 0.78),
      width: size.width * 0.34,
      height: size.height * 0.22,
    );
    canvas.drawOval(cork, paint..style = PaintingStyle.fill);

    paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.08;
    final top = Offset(cx, size.height * 0.12);
    canvas.drawLine(top, Offset(cx, size.height * 0.66), paint);
    canvas.drawLine(Offset(size.width * 0.22, size.height * 0.22), Offset(cx, size.height * 0.62), paint);
    canvas.drawLine(Offset(size.width * 0.78, size.height * 0.22), Offset(cx, size.height * 0.62), paint);
    canvas.drawLine(Offset(size.width * 0.12, size.height * 0.42), Offset(cx, size.height * 0.64), paint);
    canvas.drawLine(Offset(size.width * 0.88, size.height * 0.42), Offset(cx, size.height * 0.64), paint);
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx, size.height * 0.28), width: size.width * 0.72, height: size.height * 0.28),
      3.4,
      2.6,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _ShuttlecockPainter oldDelegate) => oldDelegate.color != color;
}

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 34});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0xFF00A651),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: ShuttlecockIcon(size: size * 0.58),
    );
  }
}
