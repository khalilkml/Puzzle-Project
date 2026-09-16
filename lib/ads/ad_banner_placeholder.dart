import 'package:flutter/material.dart';

class AdBannerPlaceholder extends StatelessWidget {
  const AdBannerPlaceholder({super.key, this.height = 60});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('ad-banner-slot'),
      height: height,
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
