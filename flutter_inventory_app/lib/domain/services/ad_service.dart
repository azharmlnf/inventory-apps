import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io';

// Simple provider for the AdService
final adServiceProvider = Provider((ref) => AdService());

class AdService {
  // Use test IDs to avoid policy violations during development.
  // Replace these with your actual ad unit IDs before publishing.
  String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111';
    } else if (Platform.isIOS) {
      // TODO: Add your iOS banner ad unit ID here
      return 'ca-app-pub-3940256099942544/2934735716';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/1033173712';
    } else if (Platform.isIOS) {
      // TODO: Add your iOS interstitial ad unit ID here
      return 'ca-app-pub-3940256099942544/4411468910';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  /// Creates and loads a banner ad.
  BannerAd createBannerAd({
    required Function() onAdLoaded,
    required Function(LoadAdError) onAdFailedToLoad,
  }) {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          print('$ad loaded.');
          onAdLoaded();
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('$ad failed to load: $error');
          ad.dispose();
          onAdFailedToLoad(error);
        },
      ),
    )..load();
  }

  /// Loads an interstitial ad.
  void createInterstitialAd({
    required Function(InterstitialAd) onAdLoaded,
  }) {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          print('$ad loaded');
          onAdLoaded(ad);
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('InterstitialAd failed to load: $error.');
        },
      ),
    );
  }
}
