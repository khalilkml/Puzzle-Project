import 'dart:math';

import 'package:flutter/foundation.dart';

import '../game/board.dart';
import '../services/score_storage.dart';

enum GameEvent { placed, cleared, combo, gameOver, revived, invalid }

class GameController extends ChangeNotifier {
  GameController({ScoreStorage? scoreStorage, Random? random})
    : _scoreStorage = scoreStorage ?? ScoreStorage(),
      _random = random ?? Random();

  final ScoreStorage _scoreStorage;
  final Random _random;

  Board _board = Board();
  List<Shape?> _tray = const [null, null, null];
  int _score = 0;
  int _bestScore = 0;
  int _lastCombo = 0;
  int _lastLinesCleared = 0;
  int _lastScoreGain = 0;
  bool _lastPerfectClear = false;
  bool _isGameOver = false;
  bool _initialized = false;
  bool _reviveUsed = false;
  int _deathCount = 0;
  int _eventSeq = 0;
  GameEvent? _lastEvent;
  List<Point<int>> _lastPlacedCells = const [];
  List<ClearedCell> _lastClearedCells = const [];

  Point<int>? _hoverOrigin;
  int? _draggingTrayIndex;

  Board get board => _board;
  List<Shape?> get tray => List.unmodifiable(_tray);
  int get score => _score;
  int get bestScore => _bestScore;
  int get lastCombo => _lastCombo;
  int get lastLinesCleared => _lastLinesCleared;
  int get lastScoreGain => _lastScoreGain;
  bool get lastPerfectClear => _lastPerfectClear;
  bool get isGameOver => _isGameOver;
  bool get isInitialized => _initialized;
  bool get reviveUsed => _reviveUsed;
  bool get canRevive => _isGameOver && !_reviveUsed;
  int get deathCount => _deathCount;
  int get eventSeq => _eventSeq;
  GameEvent? get lastEvent => _lastEvent;
  List<Point<int>> get lastPlacedCells => _lastPlacedCells;
  List<ClearedCell> get lastClearedCells => _lastClearedCells;
  Point<int>? get hoverOrigin => _hoverOrigin;
  int? get draggingTrayIndex => _draggingTrayIndex;

  Shape? get draggingShape {
    final index = _draggingTrayIndex;
    if (index == null) return null;
    return _tray[index];
  }

  Future<void> init() async {
    if (_initialized) return;
    _bestScore = await _scoreStorage.loadBestScore();
    _startNewRound(dealFresh: true);
    _initialized = true;
    notifyListeners();
  }

  void newGame() {
    _score = 0;
    _lastCombo = 0;
    _lastLinesCleared = 0;
    _lastScoreGain = 0;
    _lastPerfectClear = false;
    _isGameOver = false;
    _reviveUsed = false;
    _hoverOrigin = null;
    _draggingTrayIndex = null;
    _lastPlacedCells = const [];
    _lastClearedCells = const [];
    _lastEvent = null;
    _board = Board();
    _startNewRound(dealFresh: true);
    notifyListeners();
  }

  void beginDrag(int trayIndex) {
    if (_isGameOver) return;
    if (trayIndex < 0 || trayIndex >= _tray.length) return;
    if (_tray[trayIndex] == null) return;
    _draggingTrayIndex = trayIndex;
    notifyListeners();
  }

  void updateHover(Point<int>? origin) {
    if (_draggingTrayIndex == null) return;
    if (_hoverOrigin == origin) return;
    _hoverOrigin = origin;
    notifyListeners();
  }

  void endDrag({required bool cancelled}) {
    if (cancelled) {
      if (_draggingTrayIndex == null && _hoverOrigin == null) return;
      _draggingTrayIndex = null;
      _hoverOrigin = null;
      notifyListeners();
      return;
    }

    final trayIndex = _draggingTrayIndex;
    final origin = _hoverOrigin;
    final shape = trayIndex == null ? null : _tray[trayIndex];

    _draggingTrayIndex = null;
    _hoverOrigin = null;

    if (trayIndex == null || origin == null || shape == null) {
      _emit(GameEvent.invalid);
      return;
    }

    final placed = _tryPlace(trayIndex, shape, origin.y, origin.x);
    if (!placed) {
      _emit(GameEvent.invalid);
    }
  }

  bool tryPlaceAt(int trayIndex, int row, int col) {
    final shape = _tray[trayIndex];
    if (shape == null) return false;
    return _tryPlace(trayIndex, shape, row, col);
  }

  bool revive() {
    if (!canRevive) return false;

    _board.clearFullestLines(count: 2);
    _tray = _dealPlayableTray();
    _reviveUsed = true;
    _lastPlacedCells = const [];
    _lastClearedCells = const [];
    _evaluateGameOver();

    if (_isGameOver) {
      _board.clearFullestLines(count: 2);
      _tray = _dealPlayableTray();
      _evaluateGameOver();
    }

    _emit(GameEvent.revived);
    return true;
  }

  bool _tryPlace(int trayIndex, Shape shape, int row, int col) {
    if (_isGameOver) return false;
    if (!_board.canPlaceShape(shape, row, col)) {
      notifyListeners();
      return false;
    }

    _board.placeShape(shape, row, col);
    _tray[trayIndex] = null;
    _lastPlacedCells = [
      for (final cell in shape.cells) Point(col + cell.x, row + cell.y),
    ];

    final placedBlocks = shape.blockCount;
    final clearResult = _board.checkAndClearLines();
    final lines = clearResult.linesCleared;
    final combo = _comboMultiplier(lines);
    final perfect = lines > 0 && _board.filledCount == 0;

    _lastLinesCleared = lines;
    _lastCombo = combo;
    _lastClearedCells = clearResult.cells;
    _lastPerfectClear = perfect;
    _lastScoreGain = placedBlocks;
    _score += placedBlocks;
    if (lines > 0) {
      final clearScore = lines * 10 * combo;
      _score += clearScore;
      _lastScoreGain += clearScore;
      if (perfect) {
        _score += 50;
        _lastScoreGain += 50;
      }
    }

    if (_score > _bestScore) {
      _bestScore = _score;
      _scoreStorage.saveBestScore(_bestScore);
    }

    if (_tray.every((shape) => shape == null)) {
      _startNewRound(dealFresh: true);
    } else {
      _evaluateGameOver();
    }

    final event =
        _isGameOver
            ? GameEvent.gameOver
            : lines > 1
            ? GameEvent.combo
            : lines == 1
            ? GameEvent.cleared
            : GameEvent.placed;
    _emit(event);
    return true;
  }

  int _comboMultiplier(int linesCleared) {
    if (linesCleared <= 0) return 0;
    if (linesCleared == 1) return 1;
    if (linesCleared == 2) return 2;
    if (linesCleared == 3) return 3;
    return 4;
  }

  void _startNewRound({required bool dealFresh}) {
    if (dealFresh) {
      _tray = _dealPlayableTray();
    }
    _evaluateGameOver();
  }

  List<Shape?> _dealPlayableTray() {
    var tray = List<Shape?>.from(ShapeCatalog.deal(_random, score: _score));
    var attempts = 0;
    while (_board.isGameOver(tray) && attempts < 8) {
      tray = List<Shape?>.from(ShapeCatalog.deal(_random, score: _score));
      attempts++;
    }
    return tray;
  }

  void _evaluateGameOver() {
    final over = _board.isGameOver(_tray);
    if (over && !_isGameOver) {
      _deathCount++;
    }
    _isGameOver = over;
  }

  void _emit(GameEvent event) {
    _lastEvent = event;
    _eventSeq++;
    notifyListeners();
  }

  bool canPlaceTrayIndex(int index) {
    if (index < 0 || index >= _tray.length) return false;
    final shape = _tray[index];
    if (shape == null) return false;
    return _board.canPlaceAnywhere(shape);
  }

  bool canHighlightAt(int row, int col) {
    final shape = draggingShape;
    final origin = _hoverOrigin;
    if (shape == null || origin == null) return false;
    for (final cell in shape.cells) {
      if (origin.y + cell.y == row && origin.x + cell.x == col) {
        return true;
      }
    }
    return false;
  }

  bool get isHoverValid {
    final shape = draggingShape;
    final origin = _hoverOrigin;
    if (shape == null || origin == null) return false;
    return _board.canPlaceShape(shape, origin.y, origin.x);
  }

  @visibleForTesting
  void debugLoadBoard(List<List<int?>> cells, List<Shape?> tray) {
    _board = Board(
      cells: List.generate(Board.size, (r) => List<int?>.from(cells[r])),
    );
    _tray = List<Shape?>.from(tray);
    _evaluateGameOver();
    notifyListeners();
  }
}
