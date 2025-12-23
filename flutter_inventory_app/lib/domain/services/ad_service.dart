import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io';

// Simple provider for the AdService
final adServiceProvider = Provider((ref) => AdService());

class AdService {
  String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return dotenv.env['ADMOB_BANNER_ID_ANDROID']!;
    } else if (Platform.isIOS) {
      return dotenv.env['ADMOB_BANNER_ID_IOS']!;
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return dotenv.env['ADMOB_INTERSTITIAL_ID_ANDROID']!;
    } else if (Platform.isIOS) {
      return dotenv.env['ADMOB_INTERSTITIAL_ID_IOS']!;
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

