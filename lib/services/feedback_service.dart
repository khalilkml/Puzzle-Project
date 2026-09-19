import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../state/game_controller.dart';

class FeedbackService extends ChangeNotifier {
  FeedbackService({
    bool soundsEnabled = true,
    bool hapticsEnabled = true,
    AudioPlayer? player,
  }) : _soundsEnabled = soundsEnabled,
       _hapticsEnabled = hapticsEnabled,
       _player = player;

  factory FeedbackService.silent() {
    return FeedbackService(soundsEnabled: false, hapticsEnabled: false);
  }

  bool _soundsEnabled;
  bool _hapticsEnabled;
  AudioPlayer? _player;
  bool _ready = false;

  bool get soundsEnabled => _soundsEnabled;
  bool get hapticsEnabled => _hapticsEnabled;

  AudioPlayer get _audio => _player ??= AudioPlayer();

  void setSoundsEnabled(bool value) {
    if (_soundsEnabled == value) return;
    _soundsEnabled = value;
    if (value && !_ready) {
      // ignore: discarded_futures
      init();
    }
    notifyListeners();
  }

  void toggleSounds() => setSoundsEnabled(!_soundsEnabled);

  void setHapticsEnabled(bool value) {
    if (_hapticsEnabled == value) return;
    _hapticsEnabled = value;
    notifyListeners();
  }

  void toggleHaptics() => setHapticsEnabled(!_hapticsEnabled);

  Future<void> init() async {
    if (!_soundsEnabled || _ready) return;
    try {
      await _audio.setReleaseMode(ReleaseMode.stop);
      await _audio.setPlayerMode(PlayerMode.lowLatency);
      _ready = true;
    } catch (_) {
      _ready = false;
    }
  }

  Future<void> handle(GameEvent? event) async {
    if (event == null) return;
    switch (event) {
      case GameEvent.placed:
        await _haptic(HapticFeedback.lightImpact);
        await _play('sounds/place.wav');
      case GameEvent.cleared:
        await _haptic(HapticFeedback.mediumImpact);
        await _play('sounds/clear.wav');
      case GameEvent.combo:
        await _haptic(HapticFeedback.heavyImpact);
        await _play('sounds/combo.wav');
      case GameEvent.gameOver:
        await _haptic(HapticFeedback.heavyImpact);
        await _play('sounds/game_over.wav');
      case GameEvent.revived:
        await _haptic(HapticFeedback.mediumImpact);
        await _play('sounds/revive.wav');
      case GameEvent.invalid:
        await _haptic(HapticFeedback.selectionClick);
        await _play('sounds/invalid.wav');
    }
  }

  Future<void> dragStarted() async {
    await _haptic(HapticFeedback.selectionClick);
  }

  Future<void> _haptic(Future<void> Function() fn) async {
    if (!_hapticsEnabled) return;
    try {
      await fn();
    } catch (_) {}
  }

  Future<void> _play(String asset) async {
    if (!_soundsEnabled) return;
    try {
      await _audio.stop();
      await _audio.play(AssetSource(asset));
    } catch (_) {
      try {
        await SystemSound.play(SystemSoundType.click);
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    final player = _player;
    _player = null;
    // ignore: discarded_futures
    player?.dispose();
    super.dispose();
  }
}
