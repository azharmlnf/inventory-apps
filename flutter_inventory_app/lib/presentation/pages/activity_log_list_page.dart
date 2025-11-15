import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_inventory_app/features/activity/providers/activity_providers.dart';
import 'package:intl/intl.dart';

class ActivityLogListPage extends ConsumerWidget {
  const ActivityLogListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activityLogsAsync = ref.watch(activityLogsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Aktivitas'),
      ),
      body: activityLogsAsync.when(
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
    );
  }
}
