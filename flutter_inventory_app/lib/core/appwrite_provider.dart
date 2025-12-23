import 'package:appwrite/appwrite.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appwriteClientProvider = Provider<Client>((ref) {
  final endpoint = dotenv.env['APPWRITE_ENDPOINT']!;
  final projectId = dotenv.env['APPWRITE_PROJECT_ID']!;
  return Client()
      .setEndpoint(endpoint)
      .setProject(projectId);
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

final appwriteFunctionProvider = Provider<Functions>((ref) {
  final client = ref.watch(appwriteClientProvider);
  return Functions(client);
});
