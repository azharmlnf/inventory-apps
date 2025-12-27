import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_inventory_app/features/activity/providers/activity_log_providers.dart';
import 'package:intl/intl.dart';
import 'package:flutter_inventory_app/features/auth/providers/session_controller.dart';
import 'package:flutter_inventory_app/domain/services/ad_service.dart';
import 'package:neubrutalism_ui/neubrutalism_ui.dart';

// Top-level constants for Neubrutalism style
const Color _neubrutalismBg = Color(0xFFF9F9F9);
const Color _neubrutalismAccent = Color(0xFFE84A5F);
const Color _neubrutalismText = Colors.black;
const Color _neubrutalismBorder = Colors.black;
const double _neubrutalismBorderWidth = 3.0;
const Offset _neubrutalismShadowOffset = Offset(5.0, 5.0);

class ActivityLogListPage extends ConsumerStatefulWidget {
  const ActivityLogListPage({super.key});

  @override
  ConsumerState<ActivityLogListPage> createState() => _ActivityLogListPageState();
}

class _ActivityLogListPageState extends ConsumerState<ActivityLogListPage> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isAdLoaded) {
      _loadBannerAd();
    }
  }

  void _loadBannerAd() {
    final user = ref.read(sessionControllerProvider).value;
    
    final dynamic premiumValue = user?.prefs.data['isPremium'];
    bool isPremium = false;
    if (premiumValue is bool) {
      isPremium = premiumValue;
    } else if (premiumValue is String) {
      isPremium = premiumValue.toLowerCase() == 'true';
    }

    if (isPremium) {
      return;
    }

    _bannerAd = ref.read(adServiceProvider).createBannerAd(
      onAdLoaded: () {
        if (mounted) {
          setState(() {
            _isAdLoaded = true;
          });
        }
      },
      onAdFailedToLoad: (error) {
        _bannerAd?.dispose();
        if (mounted) {
          setState(() {
            _isAdLoaded = false;
          });
        }
      },
    );
  }
    
  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final activityLogsAsync = ref.watch(currentActivityLogsProvider);

    return Scaffold(
      backgroundColor: _neubrutalismBg,
      appBar: AppBar(
        title: const Text(
          'Riwayat Aktivitas',
          style: TextStyle(color: _neubrutalismText, fontWeight: FontWeight.bold),
        ),
        backgroundColor: _neubrutalismBg,
        elevation: 0,
        iconTheme: const IconThemeData(color: _neubrutalismText),
      ),
      body: Column(
        children: [
          Expanded(
            child: activityLogsAsync.when(
              data: (logs) {
                if (logs.isEmpty) {
                  return const Center(
                    child: Text('Belum ada aktivitas.', 
                      style: TextStyle(fontSize: 16, color: _neubrutalismText),
                    )
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(currentActivityLogsProvider);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: logs.length,
                    itemBuilder: (context, index) {
                      final log = logs[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: NeuContainer(
                          borderColor: _neubrutalismBorder,
                          borderWidth: _neubrutalismBorderWidth,
                          shadowColor: _neubrutalismBorder,
                          offset: _neubrutalismShadowOffset,
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Icon(Icons.history, color: _neubrutalismText),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        log.description,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: _neubrutalismText,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        DateFormat('dd MMM yyyy, HH:mm').format(log.timestamp),
                                        style: const TextStyle(fontSize: 12, color: Colors.black54),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: _neubrutalismAccent)),
              error: (err, stack) => Center(
                child: Text('Error: ${err.toString()}', 
                  style: const TextStyle(color: _neubrutalismText),
                )
              ),
            ),
          ),
          if (_bannerAd != null && _isAdLoaded)
            Container(
              alignment: Alignment.center,
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),
        ],
      ),
    );
  }
}