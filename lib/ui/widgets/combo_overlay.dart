import 'dart:async';

import 'package:flutter/material.dart';

import '../cubex_theme.dart';

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
                        ? CubexTheme.peachDeep
                        : const Color(0xFFE65100),
                fontWeight: FontWeight.w900,
                fontSize: widget.perfect || widget.combo > 1 ? 22 : 16,
                letterSpacing: 0.8,
              ),
            ),
            Text(
              '+${widget.scoreGain}',
              style: const TextStyle(
                color: CubexTheme.woodInk,
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
