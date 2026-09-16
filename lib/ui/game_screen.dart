import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../game/board.dart';
import '../state/game_controller.dart';

const Map<int, Color> kBlockColors = {
  1: Color(0xFF4FC3F7),
  2: Color(0xFF81C784),
  3: Color(0xFFFFB74D),
  4: Color(0xFFE57373),
  5: Color(0xFFBA68C8),
  6: Color(0xFF4DB6AC),
  7: Color(0xFFFF8A65),
  8: Color(0xFF9575CD),
  9: Color(0xFF64B5F6),
  10: Color(0xFFFFD54F),
  11: Color(0xFFA1887F),
  12: Color(0xFFF06292),
  13: Color(0xFF90A4AE),
};

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final GlobalKey _boardKey = GlobalKey();
  double _cellSize = 36;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GameController>().init();
    });
  }

  static const double _boardPadding = 6;
  static const double _cellGap = 3;

  Point<int>? _originForPointer(Offset globalPosition, Shape shape) {
    final box = _boardKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return null;

    final local = box.globalToLocal(globalPosition);
    final stride = _cellSize + _cellGap;
    final col = ((local.dx - _boardPadding) / stride).floor();
    final row = ((local.dy - _boardPadding) / stride).floor();
    return Point(col, row);
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();

    return Scaffold(
      backgroundColor: const Color(0xFF121418),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            const _Scoreboard(),
            if (controller.lastLinesCleared > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  controller.lastCombo > 1
                      ? 'Combo x${controller.lastCombo}  •  ${controller.lastLinesCleared} lines'
                      : '${controller.lastLinesCleared} line${controller.lastLinesCleared == 1 ? '' : 's'} cleared',
                  style: TextStyle(
                    color: Colors.amber.shade300,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            Expanded(
              child: Center(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final boardSide = min(
                      constraints.maxWidth - 32,
                      constraints.maxHeight - 24,
                    ).clamp(240.0, 420.0);
                    final inner =
                        boardSide - (_boardPadding * 2) - (_cellGap * (Board.size - 1));
                    _cellSize = inner / Board.size;

                    return SizedBox(
                      width: boardSide,
                      height: boardSide,
                      child: _GameBoard(
                        key: _boardKey,
                        cellSize: _cellSize,
                        padding: _boardPadding,
                        gap: _cellGap,
                      ),
                    );
                  },
                ),
              ),
            ),
            _ShapeTray(
              cellSize: min(_cellSize * 0.72, 28),
              onDragStarted: (index) => controller.beginDrag(index),
              onDragUpdate: (index, details) {
                final shape = controller.tray[index];
                if (shape == null) return;
                final origin = _originForPointer(details.globalPosition, shape);
                controller.updateHover(origin);
              },
              onDragEnd: (details) {
                controller.endDrag(cancelled: false);
              },
              onDragCanceled: () => controller.endDrag(cancelled: true),
            ),
            const SizedBox(height: 12),
            if (controller.isGameOver) const _GameOverBar(),
            const _AdBannerSlot(),
          ],
        ),
      ),
    );
  }
}

class _Scoreboard extends StatelessWidget {
  const _Scoreboard();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _ScoreCard(
              label: 'SCORE',
              value: '${controller.score}',
              accent: const Color(0xFF4FC3F7),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _ScoreCard(
              label: 'BEST',
              value: '${controller.bestScore}',
              accent: const Color(0xFFFFB74D),
            ),
          ),
          const SizedBox(width: 12),
          IconButton.filledTonal(
            onPressed: controller.newGame,
            tooltip: 'New game',
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({
    required this.label,
    required this.value,
    required this.accent,
  });

  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2128),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: accent.withValues(alpha: 0.9),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _GameBoard extends StatelessWidget {
  const _GameBoard({
    super.key,
    required this.cellSize,
    required this.padding,
    required this.gap,
  });

  final double cellSize;
  final double padding;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    final board = controller.board;
    final side = padding * 2 + cellSize * Board.size + gap * (Board.size - 1);

    return Container(
      width: side,
      height: side,
      decoration: BoxDecoration(
        color: const Color(0xFF1C2128),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Stack(
        children: [
          for (var row = 0; row < Board.size; row++)
            for (var col = 0; col < Board.size; col++)
              Positioned(
                left: padding + col * (cellSize + gap),
                top: padding + row * (cellSize + gap),
                width: cellSize,
                height: cellSize,
                child: _BoardCell(
                  value: board.cells[row][col],
                  highlighted: controller.canHighlightAt(row, col),
                  hoverValid: controller.isHoverValid,
                  dragColorId: controller.draggingShape?.colorId,
                ),
              ),
        ],
      ),
    );
  }
}

class _BoardCell extends StatelessWidget {
  const _BoardCell({
    required this.value,
    required this.highlighted,
    required this.hoverValid,
    required this.dragColorId,
  });

  final int? value;
  final bool highlighted;
  final bool hoverValid;
  final int? dragColorId;

  @override
  Widget build(BuildContext context) {
    Color fill;
    if (value != null) {
      fill = kBlockColors[value] ?? Colors.blueGrey;
    } else if (highlighted) {
      final base = kBlockColors[dragColorId ?? 1] ?? Colors.lightBlue;
      fill = hoverValid
          ? base.withValues(alpha: 0.55)
          : Colors.redAccent.withValues(alpha: 0.35);
    } else {
      fill = const Color(0xFF2A313A);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 90),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(6),
        boxShadow: value != null
            ? [
                BoxShadow(
                  color: fill.withValues(alpha: 0.35),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ]
            : null,
      ),
    );
  }
}

class _ShapeTray extends StatelessWidget {
  const _ShapeTray({
    required this.cellSize,
    required this.onDragStarted,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.onDragCanceled,
  });

  final double cellSize;
  final ValueChanged<int> onDragStarted;
  final void Function(int index, DragUpdateDetails details) onDragUpdate;
  final void Function(DraggableDetails details) onDragEnd;
  final VoidCallback onDragCanceled;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 118,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1C2128),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: List.generate(3, (index) {
            final shape = controller.tray[index];
            return Expanded(
              child: Center(
                child: shape == null
                    ? const SizedBox.shrink()
                    : _DraggableShape(
                        shape: shape,
                        cellSize: cellSize,
                        enabled: !controller.isGameOver,
                        onDragStarted: () => onDragStarted(index),
                        onDragUpdate: (details) => onDragUpdate(index, details),
                        onDragEnd: onDragEnd,
                        onDragCanceled: onDragCanceled,
                      ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _DraggableShape extends StatelessWidget {
  const _DraggableShape({
    required this.shape,
    required this.cellSize,
    required this.enabled,
    required this.onDragStarted,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.onDragCanceled,
  });

  final Shape shape;
  final double cellSize;
  final bool enabled;
  final VoidCallback onDragStarted;
  final GestureDragUpdateCallback onDragUpdate;
  final void Function(DraggableDetails details) onDragEnd;
  final VoidCallback onDragCanceled;

  @override
  Widget build(BuildContext context) {
    final preview = _ShapePreview(shape: shape, cellSize: cellSize);
    final feedbackCell = cellSize * 1.25;

    return Draggable<Shape>(
      data: shape,
      maxSimultaneousDrags: enabled ? 1 : 0,
      dragAnchorStrategy: pointerDragAnchorStrategy,
      onDragStarted: onDragStarted,
      onDragUpdate: onDragUpdate,
      onDragEnd: onDragEnd,
      onDraggableCanceled: (_, __) => onDragCanceled(),
      feedback: Material(
        color: Colors.transparent,
        child: Opacity(
          opacity: 0.92,
          child: Transform.translate(
            offset: Offset(-feedbackCell * 0.35, -feedbackCell * 0.35),
            child: _ShapePreview(shape: shape, cellSize: feedbackCell),
          ),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.2, child: preview),
      child: preview,
    );
  }
}

class _ShapePreview extends StatelessWidget {
  const _ShapePreview({
    required this.shape,
    required this.cellSize,
  });

  final Shape shape;
  final double cellSize;

  @override
  Widget build(BuildContext context) {
    final color = kBlockColors[shape.colorId] ?? Colors.lightBlue;
    final width = shape.width * cellSize + (shape.width - 1) * 2;
    final height = shape.height * cellSize + (shape.height - 1) * 2;

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: shape.cells.map((cell) {
          return Positioned(
            left: cell.x * (cellSize + 2),
            top: cell.y * (cellSize + 2),
            child: Container(
              width: cellSize,
              height: cellSize,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(5),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.35),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _GameOverBar extends StatelessWidget {
  const _GameOverBar();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF2A1E1E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            const Expanded(
              child: Text(
                'Game Over',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            FilledButton(
              onPressed: controller.newGame,
              child: const Text('Play Again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdBannerSlot extends StatelessWidget {
  const _AdBannerSlot();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFF1C2128),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Text(
        'Ad Banner Slot',
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.45),
          fontWeight: FontWeight.w600,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}
