import 'dart:async';

import 'package:flutter/material.dart';

class ComboOverlay extends StatefulWidget {
  const ComboOverlay({
    super.key,
    required this.epoch,
    required this.combo,
    required this.lines,
    required this.scoreGain,
    required this.perfect,
  });

  final int epoch;
  final int combo;
  final int lines;
  final int scoreGain;
  final bool perfect;

  @override
  State<ComboOverlay> createState() => _ComboOverlayState();
}

class _ComboOverlayState extends State<ComboOverlay> {
  Timer? _hide;
  bool _visible = false;

  @override
  void didUpdateWidget(covariant ComboOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.epoch == widget.epoch) return;
    final shouldShow =
        widget.scoreGain > 0 &&
        (widget.lines > 0 || widget.perfect || widget.combo > 1);
    if (!shouldShow) {
      _hide?.cancel();
      if (_visible) setState(() => _visible = false);
      return;
    }
    setState(() => _visible = true);
    _hide?.cancel();
    _hide = Timer(const Duration(milliseconds: 1400), () {
      if (mounted) setState(() => _visible = false);
    });
  }

  @override
  void dispose() {
    _hide?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();

    final label =
        widget.perfect
            ? 'ALL CLEAR'
            : widget.combo > 1
            ? 'COMBO x${widget.combo}'
            : widget.lines > 0
            ? '${widget.lines} LINE${widget.lines == 1 ? '' : 'S'}'
            : '+${widget.scoreGain}';

    return IgnorePointer(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        child: Column(
          key: ValueKey('juice-${widget.epoch}-$label'),
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color:
                    widget.perfect
                        ? const Color(0xFFFFD54F)
                        : Colors.amber.shade200,
                fontWeight: FontWeight.w800,
                fontSize: widget.perfect || widget.combo > 1 ? 22 : 16,
                letterSpacing: 1.1,
                shadows: const [Shadow(color: Colors.black54, blurRadius: 12)],
              ),
            ),
            Text(
              '+${widget.scoreGain}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
