import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../vault/data/vault_provider.dart';

final marketStatsProvider = Provider<Map<String, int>>((ref) {
  final sneakers = ref.watch(sneakerListProvider).value ?? [];
  final stats = <String, int>{};
  for (var s in sneakers) { stats[s.brand.toUpperCase()] = (stats[s.brand.toUpperCase()] ?? 0) + 1; }
  return stats;
});

final totalValueProvider = Provider<double>((ref) {
  return ref.watch(sneakerListProvider).value?.fold(0.0, (sum, item) => sum! + item.price) ?? 0.0;
});