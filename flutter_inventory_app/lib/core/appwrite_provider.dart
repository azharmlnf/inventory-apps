import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appwriteClientProvider = Provider<Client>((ref) {
  return Client()
      .setEndpoint('https://sgp.cloud.appwrite.io/v1')
      .setProject('691431ef001f61d2ee98');
});

final appwriteAccountProvider = Provider<Account>((ref) {
  final client = ref.watch(appwriteClientProvider);
  return Account(client);
});

final appwriteDatabaseProvider = Provider<Databases>((ref) {
  final client = ref.watch(appwriteClientProvider);
  return Databases(client);
});

final appwriteStorageProvider = Provider<Storage>((ref) {
  final client = ref.watch(appwriteClientProvider);
  return Storage(client);
});
