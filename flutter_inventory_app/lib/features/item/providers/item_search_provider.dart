import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

/// Provider sederhana untuk menampung query pencarian item.
/// UI akan mengubah state provider ini, dan provider data item akan "mendengarkan"
/// perubahan ini untuk memfilter hasil.
final itemSearchQueryProvider = StateProvider<String>((ref) {
  return '';
});
