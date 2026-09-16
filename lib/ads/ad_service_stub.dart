import 'package:flutter/material.dart';

import 'ad_banner_placeholder.dart';

class AdService extends ChangeNotifier {
  bool get isRewardedReady => false;

  bool get adsSupported => false;

  Future<void> initialize() async {}

  Widget buildBanner({double height = 60}) {
    return AdBannerPlaceholder(height: height);
  }

  Future<void> maybeShowInterstitial(int deathCount) async {}

  Future<bool> showRewardedRevive() async => false;
}
