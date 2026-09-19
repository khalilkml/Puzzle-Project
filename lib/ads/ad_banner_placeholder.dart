import 'package:flutter/material.dart';

import '../ui/cubex_theme.dart';

class AdBannerPlaceholder extends StatelessWidget {
  const AdBannerPlaceholder({super.key, this.height = 60});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('ad-banner-slot'),
      height: height,
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: CubexTheme.hudCream,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8C9A8)),
      ),
      child: const Row(
        children: [
          Icon(Icons.train_rounded, color: CubexTheme.peachDeep, size: 22),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ad Banner Slot',
                  style: TextStyle(
                    color: CubexTheme.woodInk,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
                Text(
                  'Sponsored',
                  style: TextStyle(
                    color: CubexTheme.woodMuted,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
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
