import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_banner_placeholder.dart';
import 'ad_config.dart';

class AdService extends ChangeNotifier {
  BannerAd? _banner;
  InterstitialAd? _interstitial;
  RewardedAd? _rewarded;
  bool _bannerReady = false;
  bool _rewardedReady = false;
  bool _initialized = false;

  bool get isRewardedReady => _rewardedReady;

  bool get adsSupported => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  Future<void> initialize() async {
    if (_initialized || !adsSupported) return;
    _initialized = true;
    await MobileAds.instance.initialize();
    await _loadBanner();
    await _loadInterstitial();
    await _loadRewarded();
  }

  Widget buildBanner({double height = 60}) {
    if (_bannerReady && _banner != null) {
      return Container(
        key: const Key('ad-banner-slot'),
        height: height,
        width: double.infinity,
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        alignment: Alignment.center,
        child: AdWidget(ad: _banner!),
      );
    }
    return AdBannerPlaceholder(height: height);
  }

  Future<void> maybeShowInterstitial(int deathCount) async {
    if (!adsSupported) return;
    if (deathCount <= 0 || deathCount % kInterstitialEveryNDeaths != 0) {
      return;
    }
    final ad = _interstitial;
    if (ad == null) {
      unawaited(_loadInterstitial());
      return;
    }
    _interstitial = null;
    final completer = Completer<void>();
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        unawaited(_loadInterstitial());
        if (!completer.isCompleted) completer.complete();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        unawaited(_loadInterstitial());
        if (!completer.isCompleted) completer.complete();
      },
    );
    await ad.show();
    await completer.future.timeout(
      const Duration(seconds: 8),
      onTimeout: () {},
    );
  }

  Future<bool> showRewardedRevive() async {
    if (!adsSupported) return false;
    final ad = _rewarded;
    if (ad == null) {
      unawaited(_loadRewarded());
      return false;
    }
    _rewarded = null;
    _rewardedReady = false;
    notifyListeners();

    final completer = Completer<bool>();
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        unawaited(_loadRewarded());
        if (!completer.isCompleted) completer.complete(false);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        unawaited(_loadRewarded());
        if (!completer.isCompleted) completer.complete(false);
      },
    );
    await ad.show(
      onUserEarnedReward: (ad, reward) {
        if (!completer.isCompleted) completer.complete(true);
      },
    );
    return completer.future.timeout(
      const Duration(seconds: 60),
      onTimeout: () => false,
    );
  }

  Future<void> _loadBanner() async {
    await _banner?.dispose();
    _banner = null;
    _bannerReady = false;
    final banner = BannerAd(
      adUnitId: AdConfig.bannerAdUnitId(ios: Platform.isIOS),
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _bannerReady = true;
          notifyListeners();
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (_banner == ad) {
            _banner = null;
            _bannerReady = false;
            notifyListeners();
          }
        },
      ),
    );
    _banner = banner;
    await banner.load();
  }

  Future<void> _loadInterstitial() async {
    await InterstitialAd.load(
      adUnitId: AdConfig.interstitialAdUnitId(ios: Platform.isIOS),
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitial = ad;
        },
        onAdFailedToLoad: (error) {
          _interstitial = null;
        },
      ),
    );
  }

  Future<void> _loadRewarded() async {
    _rewardedReady = false;
    await RewardedAd.load(
      adUnitId: AdConfig.rewardedAdUnitId(ios: Platform.isIOS),
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewarded = ad;
          _rewardedReady = true;
          notifyListeners();
        },
        onAdFailedToLoad: (error) {
          _rewarded = null;
          _rewardedReady = false;
          notifyListeners();
        },
      ),
    );
  }

  @override
  void dispose() {
    _banner?.dispose();
    _interstitial?.dispose();
    _rewarded?.dispose();
    super.dispose();
  }
}
