import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_inventory_app/features/auth/providers/auth_state_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final currentUser = authState.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authControllerProvider.notifier).signOut();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome,', style: Theme.of(context).textTheme.headlineSmall),
            if (currentUser != null)
              Text(
                currentUser.name,
                style: Theme.of(context).textTheme.headlineMedium,
              )
            else
              const CircularProgressIndicator(),
            const SizedBox(height: 8),
            if (currentUser != null) Text(currentUser.email),
          ],
        ),
      ),
    );
  }
}
