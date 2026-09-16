import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../ads/ad_service.dart';
import '../game/board.dart';
import '../services/feedback_service.dart';
import '../state/game_controller.dart';
import 'block_colors.dart';
import 'widgets/clear_burst.dart';
import 'widgets/combo_overlay.dart';
import 'widgets/game_over_dialog.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final GlobalKey _boardKey = GlobalKey();
  double _cellSize = 36;
  int _seenEventSeq = 0;
  bool _gameOverDialogOpen = false;
  bool _gameOverDialogQueued = false;
  GameController? _controller;

  static const double _boardPadding = 6;
  static const double _cellGap = 3;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(context.read<GameController>().init());
      unawaited(context.read<FeedbackService>().init());
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = context.read<GameController>();
    if (!identical(_controller, controller)) {
      _controller?.removeListener(_onControllerTick);
      _controller = controller;
      _controller!.addListener(_onControllerTick);
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_onControllerTick);
    super.dispose();
  }

  void _onControllerTick() {
    if (!mounted) return;
    final controller = context.read<GameController>();
    if (controller.eventSeq != _seenEventSeq) {
      _seenEventSeq = controller.eventSeq;
      unawaited(context.read<FeedbackService>().handle(controller.lastEvent));
    }

    if (controller.isGameOver &&
        !_gameOverDialogOpen &&
        !_gameOverDialogQueued) {
      _gameOverDialogQueued = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _gameOverDialogQueued = false;
        if (!mounted) return;
        final current = context.read<GameController>();
        if (!current.isGameOver || _gameOverDialogOpen) return;
        _gameOverDialogOpen = true;
        unawaited(_openGameOverDialog());
      });
    } else if (!controller.isGameOver && _gameOverDialogOpen) {
      final nav = Navigator.of(context, rootNavigator: true);
      if (nav.canPop()) nav.pop();
    }
  }

  Future<void> _openGameOverDialog() async {
    final controller = context.read<GameController>();
    final ads = context.read<AdService>();
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return ListenableBuilder(
          listenable: Listenable.merge([controller, ads]),
          builder: (context, _) {
            return GameOverDialog(
              score: controller.score,
              bestScore: controller.bestScore,
              canRevive: controller.canRevive,
              rewardedReady: ads.isRewardedReady || !ads.adsSupported,
              onPlayAgain: () {
                Navigator.of(dialogContext).pop();
                final deaths = controller.deathCount;
                controller.newGame();
                unawaited(ads.maybeShowInterstitial(deaths));
              },
              onRevive: () async {
                final earned =
                    ads.adsSupported ? await ads.showRewardedRevive() : true;
                if (!earned || !dialogContext.mounted) return;
                controller.revive();
                Navigator.of(dialogContext).pop();
              },
            );
          },
        );
      },
    );
    _gameOverDialogOpen = false;
  }

  Offset _dragLift(Shape shape, double cellSize) {
    final height = shape.height * cellSize + (shape.height - 1) * _cellGap;
    return Offset(-cellSize * 0.15, -height - 12);
  }

  Point<int>? _originForPointer(Offset globalPosition, Shape shape) {
    final box = _boardKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return null;

    final local = box.globalToLocal(
      globalPosition + _dragLift(shape, _cellSize),
    );
    final stride = _cellSize + _cellGap;
    final col = ((local.dx - _boardPadding) / stride).floor();
    final row = ((local.dy - _boardPadding) / stride).floor();
    return Point(col, row);
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    final ads = context.watch<AdService>();

    return Scaffold(
      backgroundColor: const Color(0xFF121418),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            const _Scoreboard(),
            SizedBox(
              height: 44,
              child: ComboOverlay(
                epoch: controller.eventSeq,
                combo: controller.lastCombo,
                lines: controller.lastLinesCleared,
                scoreGain: controller.lastScoreGain,
                perfect: controller.lastPerfectClear,
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
                        boardSide -
                        (_boardPadding * 2) -
                        (_cellGap * (Board.size - 1));
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
              trayCellSize: min(_cellSize * 0.72, 28),
              boardCellSize: _cellSize,
              boardGap: _cellGap,
              dragLiftFor: (shape) => _dragLift(shape, _cellSize),
              onDragStarted: (index) {
                controller.beginDrag(index);
                unawaited(context.read<FeedbackService>().dragStarted());
              },
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
            ads.buildBanner(),
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
                  justPlaced: controller.lastPlacedCells.contains(
                    Point(col, row),
                  ),
                  placeEpoch: controller.eventSeq,
                ),
              ),
          ClearBurst(
            cells: controller.lastClearedCells,
            epoch: controller.eventSeq,
            cellSize: cellSize,
            padding: padding,
            gap: gap,
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
    required this.justPlaced,
    required this.placeEpoch,
  });

  final int? value;
  final bool highlighted;
  final bool hoverValid;
  final int? dragColorId;
  final bool justPlaced;
  final int placeEpoch;

  @override
  Widget build(BuildContext context) {
    Color fill;
    if (value != null) {
      fill = kBlockColors[value] ?? Colors.blueGrey;
    } else if (highlighted) {
      final base = kBlockColors[dragColorId ?? 1] ?? Colors.lightBlue;
      fill =
          hoverValid
              ? base.withValues(alpha: 0.55)
              : Colors.redAccent.withValues(alpha: 0.35);
    } else {
      fill = const Color(0xFF2A313A);
    }

    final cell = AnimatedContainer(
      duration: const Duration(milliseconds: 90),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(6),
        boxShadow:
            value != null
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

    if (!justPlaced || value == null) return cell;

    return TweenAnimationBuilder<double>(
      key: ValueKey('place-$placeEpoch'),
      tween: Tween(begin: 0.72, end: 1),
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: cell,
    );
  }
}

class _ShapeTray extends StatelessWidget {
  const _ShapeTray({
    required this.trayCellSize,
    required this.boardCellSize,
    required this.boardGap,
    required this.dragLiftFor,
    required this.onDragStarted,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.onDragCanceled,
  });

  final double trayCellSize;
  final double boardCellSize;
  final double boardGap;
  final Offset Function(Shape shape) dragLiftFor;
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
                child:
                    shape == null
                        ? const SizedBox.shrink()
                        : Opacity(
                          opacity:
                              controller.canPlaceTrayIndex(index) ? 1 : 0.38,
                          child: _DraggableShape(
                            shape: shape,
                            trayCellSize: trayCellSize,
                            boardCellSize: boardCellSize,
                            boardGap: boardGap,
                            dragLift: dragLiftFor(shape),
                            enabled:
                                !controller.isGameOver &&
                                controller.canPlaceTrayIndex(index),
                            onDragStarted: () => onDragStarted(index),
                            onDragUpdate:
                                (details) => onDragUpdate(index, details),
                            onDragEnd: onDragEnd,
                            onDragCanceled: onDragCanceled,
                          ),
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
    required this.trayCellSize,
    required this.boardCellSize,
    required this.boardGap,
    required this.dragLift,
    required this.enabled,
    required this.onDragStarted,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.onDragCanceled,
  });

  final Shape shape;
  final double trayCellSize;
  final double boardCellSize;
  final double boardGap;
  final Offset dragLift;
  final bool enabled;
  final VoidCallback onDragStarted;
  final GestureDragUpdateCallback onDragUpdate;
  final void Function(DraggableDetails details) onDragEnd;
  final VoidCallback onDragCanceled;

  @override
  Widget build(BuildContext context) {
    final preview = _ShapePreview(shape: shape, cellSize: trayCellSize, gap: 2);

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
            offset: dragLift,
            child: _ShapePreview(
              shape: shape,
              cellSize: boardCellSize,
              gap: boardGap,
            ),
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
    this.gap = 2,
  });

  final Shape shape;
  final double cellSize;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final color = kBlockColors[shape.colorId] ?? Colors.lightBlue;
    final width = shape.width * cellSize + (shape.width - 1) * gap;
    final height = shape.height * cellSize + (shape.height - 1) * gap;

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children:
            shape.cells.map((cell) {
              return Positioned(
                left: cell.x * (cellSize + gap),
                top: cell.y * (cellSize + gap),
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
