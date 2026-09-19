import 'package:flutter/material.dart';

import '../../game/board.dart';
import '../block_colors.dart';
import '../cubex_theme.dart';

class ClearBurst extends StatefulWidget {
  const ClearBurst({
    super.key,
    required this.cells,
    required this.epoch,
    required this.cellSize,
    required this.padding,
    required this.gap,
  });

  final List<ClearedCell> cells;
  final int epoch;
  final double cellSize;
  final double padding;
  final double gap;

  @override
  State<ClearBurst> createState() => _ClearBurstState();
}

class _ClearBurstState extends State<ClearBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _t;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _t = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    if (widget.cells.isNotEmpty) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant ClearBurst oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.epoch != widget.epoch && widget.cells.isNotEmpty) {
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
    if (widget.cells.isEmpty) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _t,
      builder: (context, _) {
        final progress = _t.value;
        final opacity = (1 - progress).clamp(0.0, 1.0);
        return IgnorePointer(
          child: Stack(
            children: [
              for (final cell in widget.cells) ...[
                Positioned(
                  left:
                      widget.padding +
                      cell.at.x * (widget.cellSize + widget.gap),
                  top:
                      widget.padding +
                      cell.at.y * (widget.cellSize + widget.gap),
                  width: widget.cellSize,
                  height: widget.cellSize,
                  child: Opacity(
                    opacity: opacity,
                    child: Transform.scale(
                      scale: 1 + progress * 0.55,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: (kBlockColors[cell.colorId] ?? Colors.white)
                              .withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFFFFE082,
                              ).withValues(alpha: 0.7 * opacity),
                              blurRadius: 12 + progress * 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left:
                      widget.padding +
                      cell.at.x * (widget.cellSize + widget.gap) +
                      widget.cellSize * 0.35,
                  top:
                      widget.padding +
                      cell.at.y * (widget.cellSize + widget.gap) -
                      progress * 10,
                  child: Opacity(
                    opacity: opacity,
                    child: Icon(
                      Icons.star_rounded,
                      size: 10 + progress * 6,
                      color: CubexTheme.peachDeep.withValues(alpha: 0.9),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
