import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/database_service.dart';
import '../domain/sneaker_model.dart';

final databaseServiceProvider = Provider((ref) => DatabaseService());

class SneakerListNotifier extends AsyncNotifier<List<Sneaker>> {
  @override
  Future<List<Sneaker>> build() async {
    // Chargement initial
    final databaseService = ref.read(databaseServiceProvider);
    return await databaseService.getSneakers();
  }

  Future<void> addSneaker(Sneaker sneaker) async {
    final databaseService = ref.read(databaseServiceProvider);
    await databaseService.insertSneaker(sneaker);
    
    // Rafraîchir la liste
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await databaseService.getSneakers();
    });
  }

  // --- C'EST ICI QUE ÇA PLANTAIT SI LE SERVICE N'ÉTAIT PAS À JOUR ---
  Future<void> removeSneaker(int id) async {
    final databaseService = ref.read(databaseServiceProvider);
    
    // Cette ligne (24 env.) appelle la fonction qu'on vient d'ajouter au dessus
    await databaseService.deleteSneaker(id);

    // Rafraîchir la liste
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await databaseService.getSneakers();
    });
  }
}

final sneakerListProvider = AsyncNotifierProvider<SneakerListNotifier, List<Sneaker>>(() {
  return SneakerListNotifier();
});