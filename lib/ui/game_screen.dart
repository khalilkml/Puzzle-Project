import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../ads/ad_service.dart';
import '../game/board.dart';
import '../services/feedback_service.dart';
import '../state/game_controller.dart';
import 'block_colors.dart';
import 'cubex_theme.dart';
import 'drag_placement.dart';
import 'widgets/clear_burst.dart';
import 'widgets/combo_overlay.dart';
import 'widgets/game_over_dialog.dart';
import 'widgets/idle_wiggle.dart';
import 'widgets/level_bar.dart';
import 'widgets/toy_block.dart';

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

  static const double _boardPadding = 10;
  static const double _cellGap = 5;

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
      barrierColor: const Color(0x99FFF4EC),
      builder: (dialogContext) {
        return ListenableBuilder(
          listenable: Listenable.merge([controller, ads]),
          builder: (context, _) {
            return GameOverDialog(
              score: controller.score,
              bestScore: controller.bestScore,
              lastScoreGain: controller.lastScoreGain,
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

  /// Lift shared by floating feedback and hover/drop mapping.
  Offset _dragLift(Shape shape, double cellSize) {
    return DragPlacement.feedbackLift(
      shapeWidth: shape.width,
      shapeHeight: shape.height,
      cellSize: cellSize,
      gap: _cellGap,
    );
  }

  Point<int>? _originForPointer(Offset globalPosition, Shape shape) {
    final box = _boardKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return null;

    return DragPlacement.originForPointer(
      globalPointer: globalPosition,
      boardGlobalTopLeft: box.localToGlobal(Offset.zero),
      shapeWidth: shape.width,
      shapeHeight: shape.height,
      cellSize: _cellSize,
      gap: _cellGap,
      boardPadding: _boardPadding,
      boardSize: Board.size,
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    final ads = context.watch<AdService>();

    return Scaffold(
      backgroundColor: CubexTheme.cream,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            const _GameHeader(),
            SizedBox(
              height: 40,
              child: ComboOverlay(
                epoch: controller.eventSeq,
                combo: controller.lastCombo,
                lines: controller.lastLinesCleared,
                scoreGain: controller.lastScoreGain,
                perfect: controller.lastPerfectClear,
              ),
            ),
            LevelBar(score: controller.score),
            Expanded(
              child: Center(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final boardSide = min(
                      constraints.maxWidth - 28,
                      constraints.maxHeight - 16,
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
            const SizedBox(height: 8),
            ads.buildBanner(),
          ],
        ),
      ),
    );
  }
}

class _GameHeader extends StatelessWidget {
  const _GameHeader();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    final canPop = Navigator.of(context).canPop();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          _HudIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onPressed: canPop ? () => Navigator.of(context).pop() : null,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _ScorePill(
              label: 'SCORE',
              value: '${controller.score}',
              tint: CubexTheme.hudCream,
              icon: Icons.extension_rounded,
              iconColor: CubexTheme.peachDeep,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _ScorePill(
              label: 'BEST',
              value: '${controller.bestScore}',
              tint: const Color(0xFFFFD7B8),
              icon: Icons.emoji_events_rounded,
              iconColor: CubexTheme.peachDeep,
            ),
          ),
          const SizedBox(width: 8),
          _HudIconButton(
            icon: Icons.refresh_rounded,
            accent: true,
            onPressed: controller.newGame,
          ),
        ],
      ),
    );
  }
}

class _ScorePill extends StatelessWidget {
  const _ScorePill({
    required this.label,
    required this.value,
    required this.tint,
    required this.icon,
    required this.iconColor,
  });

  final String label;
  final String value;
  final Color tint;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 18),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: CubexTheme.woodMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: CubexTheme.woodInk,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HudIconButton extends StatelessWidget {
  const _HudIconButton({
    required this.icon,
    this.onPressed,
    this.accent = false,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: accent ? CubexTheme.peachDeep : Colors.white,
      shape: const CircleBorder(),
      elevation: 1,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(
            icon,
            size: 20,
            color: accent ? Colors.white : CubexTheme.woodMuted,
          ),
        ),
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
        color: CubexTheme.boardFill,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
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
                  size: cellSize,
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
    required this.size,
  });

  final int? value;
  final bool highlighted;
  final bool hoverValid;
  final int? dragColorId;
  final bool justPlaced;
  final int placeEpoch;
  final double size;

  @override
  Widget build(BuildContext context) {
    Widget cell;
    if (value != null) {
      cell = ToyBlock(
        color: kBlockColors[value] ?? Colors.orange,
        size: size,
      );
    } else if (highlighted) {
      final base = kBlockColors[dragColorId ?? 1] ?? Colors.lightBlue;
      cell = Container(
        decoration: BoxDecoration(
          color:
              hoverValid
                  ? base.withValues(alpha: 0.45)
                  : Colors.redAccent.withValues(alpha: 0.28),
          borderRadius: BorderRadius.circular((size * 0.22).clamp(4.0, 10.0)),
          border: Border.all(
            color:
                hoverValid
                    ? base.withValues(alpha: 0.9)
                    : Colors.redAccent.withValues(alpha: 0.7),
            width: 1.4,
          ),
        ),
      );
    } else {
      cell = Container(
        decoration: BoxDecoration(
          color: CubexTheme.cellEmpty,
          borderRadius: BorderRadius.circular((size * 0.22).clamp(4.0, 10.0)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
      );
    }

    if (!justPlaced || value == null) return cell;

    return TweenAnimationBuilder<double>(
      key: ValueKey('place-$placeEpoch'),
      tween: Tween(begin: 0.72, end: 1),
      duration: const Duration(milliseconds: 220),
      curve: Curves.elasticOut,
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
        height: 132,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          color: CubexTheme.boardFill,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: List.generate(3, (index) {
            final shape = controller.tray[index];
            return Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border(
                    right:
                        index < 2
                            ? const BorderSide(
                              color: Color(0x33C9966A),
                              width: 1,
                            )
                            : BorderSide.none,
                  ),
                ),
                child: Center(
                  child:
                      shape == null
                          ? const SizedBox.expand()
                          : _DraggableShape(
                            shape: shape,
                            trayCellSize: trayCellSize,
                            boardCellSize: boardCellSize,
                            boardGap: boardGap,
                            dragLift: dragLiftFor(shape),
                            enabled:
                                !controller.isGameOver &&
                                controller.canPlaceTrayIndex(index),
                            dimmed: !controller.canPlaceTrayIndex(index),
                            wiggleDelay: Duration(milliseconds: 180 * index),
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
    required this.dimmed,
    required this.wiggleDelay,
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
  final bool dimmed;
  final Duration wiggleDelay;
  final VoidCallback onDragStarted;
  final GestureDragUpdateCallback onDragUpdate;
  final void Function(DraggableDetails details) onDragEnd;
  final VoidCallback onDragCanceled;

  @override
  Widget build(BuildContext context) {
    final preview = IdleWiggle(
      enabled: enabled,
      delay: wiggleDelay,
      child: _ShapePreview(
        shape: shape,
        cellSize: trayCellSize,
        gap: 3,
        dimmed: dimmed,
      ),
    );

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
        elevation: 0,
        child: Transform.translate(
          offset: dragLift,
          // No scale here — must match DragPlacement.originForPointer exactly.
          child: _ShapePreview(
            shape: shape,
            cellSize: boardCellSize,
            gap: boardGap,
          ),
        ),
      ),
      childWhenDragging: const SizedBox.expand(),
      child: SizedBox.expand(
        child: ColoredBox(
          color: Colors.transparent,
          child: Center(child: preview),
        ),
      ),
    );
  }
}

class _ShapePreview extends StatelessWidget {
  const _ShapePreview({
    required this.shape,
    required this.cellSize,
    this.gap = 2,
    this.dimmed = false,
  });

  final Shape shape;
  final double cellSize;
  final double gap;
  final bool dimmed;

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
                child: ToyBlock(
                  color: color,
                  size: cellSize,
                  dimmed: dimmed,
                ),
              );
            }).toList(),
      ),
    );
  }
}
