import 'dart:math';

import 'package:flutter/material.dart';

class IdleWiggle extends StatefulWidget {
  const IdleWiggle({
    super.key,
    required this.child,
    this.enabled = true,
    this.delay = Duration.zero,
  });

  final Widget child;
  final bool enabled;
  final Duration delay;

  @override
  State<IdleWiggle> createState() => _IdleWiggleState();
}

class _IdleWiggleState extends State<IdleWiggle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    if (widget.enabled) {
      Future<void>.delayed(widget.delay, () {
        if (!mounted || !widget.enabled) return;
        _controller.forward().then((_) {
          if (mounted) _controller.reverse();
        });
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = sin(_controller.value * pi) * 0.05;
        return Transform.rotate(angle: t, child: child);
      },
      child: widget.child,
    );
  }
}
