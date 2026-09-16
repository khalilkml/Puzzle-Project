import 'dart:math';

import 'package:flutter/foundation.dart';

import '../game/board.dart';
import '../services/score_storage.dart';

class GameController extends ChangeNotifier {
  GameController({
    ScoreStorage? scoreStorage,
    Random? random,
  })  : _scoreStorage = scoreStorage ?? ScoreStorage(),
        _random = random ?? Random();

  final ScoreStorage _scoreStorage;
  final Random _random;

  Board _board = Board();
  List<Shape?> _tray = const [null, null, null];
  int _score = 0;
  int _bestScore = 0;
  int _lastCombo = 0;
  int _lastLinesCleared = 0;
  bool _isGameOver = false;
  bool _initialized = false;

  Point<int>? _hoverOrigin;
  int? _draggingTrayIndex;

  Board get board => _board;
  List<Shape?> get tray => List.unmodifiable(_tray);
  int get score => _score;
  int get bestScore => _bestScore;
  int get lastCombo => _lastCombo;
  int get lastLinesCleared => _lastLinesCleared;
  bool get isGameOver => _isGameOver;
  bool get isInitialized => _initialized;
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
    _isGameOver = false;
    _hoverOrigin = null;
    _draggingTrayIndex = null;
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
      notifyListeners();
      return;
    }

    _tryPlace(trayIndex, shape, origin.y, origin.x);
  }

  bool tryPlaceAt(int trayIndex, int row, int col) {
    final shape = _tray[trayIndex];
    if (shape == null) return false;
    return _tryPlace(trayIndex, shape, row, col);
  }

  bool _tryPlace(int trayIndex, Shape shape, int row, int col) {
    if (_isGameOver) return false;
    if (!_board.canPlaceShape(shape, row, col)) {
      notifyListeners();
      return false;
    }

    _board.placeShape(shape, row, col);
    _tray[trayIndex] = null;

    final placedBlocks = shape.blockCount;
    final clearResult = _board.checkAndClearLines();
    final lines = clearResult.linesCleared;
    final combo = _comboMultiplier(lines);

    _lastLinesCleared = lines;
    _lastCombo = combo;
    _score += placedBlocks;
    if (lines > 0) {
      _score += lines * 10 * combo;
      if (_board.filledCount == 0) {
        _score += 50;
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

    notifyListeners();
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
      _tray = List<Shape?>.from(ShapeCatalog.deal(_random));
    }
    _evaluateGameOver();
  }

  void _evaluateGameOver() {
    _isGameOver = _board.isGameOver(_tray);
  }

  bool canHighlightAt(int row, int col) {
    final shape = draggingShape;
    final origin = _hoverOrigin;
    if (shape == null || origin == null) return false;
    if (!_board.canPlaceShape(shape, origin.y, origin.x)) return false;
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
}
