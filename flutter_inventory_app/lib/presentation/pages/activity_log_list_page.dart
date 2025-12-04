import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_inventory_app/features/activity/providers/activity_providers.dart';
import 'package:intl/intl.dart';
import 'package:flutter_inventory_app/features/auth/providers/auth_state_provider.dart';
import 'package:flutter_inventory_app/domain/services/ad_service.dart';

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
      // _loadBannerAd() is now called in didChangeDependencies
    }
  
    @override
    void didChangeDependencies() {
      super.didChangeDependencies();
      if (!_isAdLoaded) {
        _loadBannerAd();
      }
    }
  
    void _loadBannerAd() {
      if (ref.read(authControllerProvider).isPremium) {
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
    void dispose() {    _bannerAd?.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final activityLogsAsync = ref.watch(activityLogsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Aktivitas'),
      ),
      body: Column(
        children: [
          Expanded(
            child: activityLogsAsync.when(
              data: (logs) {
                if (logs.isEmpty) {
                  return const Center(child: Text('Belum ada aktivitas.'));
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(activityLogsProvider);
                  },
                  child: ListView.builder(
                    itemCount: logs.length,
                    itemBuilder: (context, index) {
                      final log = logs[index];
                      return ListTile(
                        leading: const Icon(Icons.history),
                        title: Text(log.description),
                        subtitle: Text(
                          DateFormat('dd MMM yyyy, HH:mm').format(log.timestamp),
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: ${err.toString()}')),
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
