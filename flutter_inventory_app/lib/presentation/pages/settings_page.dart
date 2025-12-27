
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neubrutalism_ui/neubrutalism_ui.dart' as neubrutalism_ui;
import 'package:flutter_inventory_app/features/auth/providers/session_controller.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const neubrutalismAccent = Color(0xFFE84A5F);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pengaturan',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFF9F9F9),
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Placeholder for a setting
            neubrutalism_ui.NeuContainer(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Aktifkan Notifikasi',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Switch(
                      value: true,
                      onChanged: (val) {
                        // Placeholder action
                      },
                      activeTrackColor: neubrutalismAccent,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Placeholder for an action button
            neubrutalism_ui.NeuContainer(
              color: const Color(0xFF81A1C1),
              shadowColor: Colors.black,
              borderColor: Colors.black,
              borderRadius: BorderRadius.circular(8), // Assuming 8 for consistency
              offset: const Offset(4, 4), // Assuming consistent offset
              child: InkWell(
                onTap: () {
                  // Placeholder for "About" dialog
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: Colors.transparent, // Make background transparent
                      contentPadding: EdgeInsets.zero,
                      insetPadding: const EdgeInsets.all(16.0),
                      content: neubrutalism_ui.NeuContainer(
                        color: Colors.white,
                        borderColor: Colors.black,
                        shadowColor: Colors.black,
                        borderRadius: BorderRadius.circular(8),
                        offset: const Offset(4, 4),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Tentang Aplikasi',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Inventarisku v2.1\nDibuat dengan Flutter & Appwrite.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.black),
                              ),
                              const SizedBox(height: 24),
                              neubrutalism_ui.NeuTextButton(
                                onPressed: () => Navigator.pop(context),
                                buttonColor: const Color(0xFF81A1C1),
                                shadowColor: Colors.black,
                                borderColor: Colors.black,
                                borderRadius: BorderRadius.circular(8),
                                enableAnimation: true,
                                text: const Text(
                                  'Tutup',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
                child: const SizedBox(
                  height: 50,
                  child: Center(
                    child: Text(
                      'Tentang Aplikasi',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ),
                ),
              ),
            ),
            const Spacer(),
            // Logout Button
            neubrutalism_ui.NeuContainer(
              color: neubrutalismAccent.withAlpha(50),
              shadowColor: Colors.black,
              borderColor: Colors.black,
              borderRadius: BorderRadius.circular(8), // Assuming 8 for consistency
              offset: const Offset(4, 4), // Assuming consistent offset
              child: InkWell(
                onTap: () {
                  ref.read(sessionControllerProvider.notifier).logout();
                },
                child: SizedBox(
                  height: 50,
                  child: Center(
                    child: Text(
                      'Logout',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: neubrutalismAccent,
                      ),
                    ),
                  ),
                ),
              ),
            ),
             const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
