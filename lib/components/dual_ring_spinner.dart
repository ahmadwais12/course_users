import 'dart:math' as math;
import 'package:flutter/material.dart';

class DualRingSpinner extends StatefulWidget {
  final double size;
  final double strokeWidth;
  final Color outerColor;
  final Color innerColor;

  const DualRingSpinner({
    super.key,
    this.size = 56,
    this.strokeWidth = 3,
    this.outerColor = const Color(0xFF8B5CF6),
    this.innerColor = const Color(0xFFEC4899),
  });

  @override
  State<DualRingSpinner> createState() => _DualRingSpinnerState();
}

class _DualRingSpinnerState extends State<DualRingSpinner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform.rotate(
                angle: _controller.value * 2 * math.pi,
                child: CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: _RingPainter(
                    color: widget.outerColor,
                    strokeWidth: widget.strokeWidth,
                    startAngle: 0,
                    sweepAngle: 270 * (math.pi / 180),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(widget.strokeWidth * 2),
                child: Transform.rotate(
                  angle: -_controller.value * 2 * math.pi,
                  child: CustomPaint(
                    size: Size(
                      widget.size - widget.strokeWidth * 4,
                      widget.size - widget.strokeWidth * 4,
                    ),
                    painter: _RingPainter(
                      color: widget.innerColor,
                      strokeWidth: widget.strokeWidth,
                      startAngle: math.pi,
                      sweepAngle: 270 * (math.pi / 180),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double startAngle;
  final double sweepAngle;

  _RingPainter({
    required this.color,
    required this.strokeWidth,
    required this.startAngle,
    required this.sweepAngle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) => true;
}
