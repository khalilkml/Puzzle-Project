import 'package:flutter/material.dart';

/// Chunky glossy wooden toy cube — original Cubex treatment.
class ToyBlock extends StatelessWidget {
  const ToyBlock({
    super.key,
    required this.color,
    required this.size,
    this.radius,
    this.dimmed = false,
  });

  final Color color;
  final double size;
  final double? radius;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    final r = radius ?? (size * 0.22).clamp(4.0, 10.0);
    final highlight = Color.lerp(color, Colors.white, 0.42)!;
    final shade = Color.lerp(color, const Color(0xFF3A2418), 0.22)!;

    return Opacity(
      opacity: dimmed ? 0.42 : 1,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(r),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [highlight, color, shade],
            stops: const [0.0, 0.48, 1.0],
          ),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.55),
            width: 1.1,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.38),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.55),
              blurRadius: 0,
              offset: const Offset(0, 1),
              spreadRadius: -1,
            ),
          ],
        ),
        child: Align(
          alignment: const Alignment(-0.55, -0.55),
          child: Container(
            width: size * 0.34,
            height: size * 0.22,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(r),
              color: Colors.white.withValues(alpha: 0.45),
            ),
          ),
        ),
      ),
    );
  }
}
