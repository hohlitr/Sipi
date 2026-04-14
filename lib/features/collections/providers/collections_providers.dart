import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/card_group.dart';
import '../../../core/models/card_item.dart';
import '../../../core/models/collection.dart';
import '../../../core/models/user_stats.dart';
import '../data/collections_repository.dart';

final collectionsRepositoryProvider = Provider<CollectionsRepository>((ref) {
  return CollectionsRepository();
});

final collectionsProvider = Provider<List<StudyCollection>>((ref) {
  return ref.watch(collectionsRepositoryProvider).getCollections();
});

final collectionProvider = Provider.family<StudyCollection?, String>((ref, id) {
  return ref.watch(collectionsRepositoryProvider).getCollectionById(id);
});

final cardsForCollectionProvider = Provider.family<List<CardItem>, String>((ref, collectionId) {
  return ref.watch(collectionsRepositoryProvider).getCardsForCollection(collectionId);
});

final groupsForCollectionProvider = Provider.family<List<CardGroup>, String>((ref, collectionId) {
  return ref.watch(collectionsRepositoryProvider).getGroupsForCollection(collectionId);
});

final weakCardsProvider = Provider.family<List<CardItem>, String>((ref, collectionId) {
  return ref.watch(collectionsRepositoryProvider).getWeakCards(collectionId);
});

final userStatsProvider = Provider<UserStats>((ref) {
  return ref.watch(collectionsRepositoryProvider).getStats();
});
