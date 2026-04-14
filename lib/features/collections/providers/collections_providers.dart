import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/achievement.dart';
import '../../../core/models/card_group.dart';
import '../../../core/models/card_item.dart';
import '../../../core/models/collection.dart';
import '../../../core/models/study_plan.dart';
import '../../../core/models/user_stats.dart';
import '../data/collections_repository.dart';
import '../data/local_storage_service.dart';

final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService();
});

final collectionsRepositoryProvider = Provider<CollectionsRepository>((ref) {
  return CollectionsRepository(ref.watch(localStorageServiceProvider));
});

final repositoryInitializationProvider = FutureProvider<void>((ref) async {
  await ref.watch(collectionsRepositoryProvider).initialize();
});

final collectionsProvider = Provider<List<StudyCollection>>((ref) {
  ref.watch(repositoryInitializationProvider);
  return ref.watch(collectionsRepositoryProvider).getCollections();
});

final collectionProvider = Provider.family<StudyCollection?, String>((ref, id) {
  ref.watch(repositoryInitializationProvider);
  return ref.watch(collectionsRepositoryProvider).getCollectionById(id);
});

final cardsForCollectionProvider = Provider.family<List<CardItem>, String>((ref, collectionId) {
  ref.watch(repositoryInitializationProvider);
  return ref.watch(collectionsRepositoryProvider).getCardsForCollection(collectionId);
});

final groupsForCollectionProvider = Provider.family<List<CardGroup>, String>((ref, collectionId) {
  ref.watch(repositoryInitializationProvider);
  return ref.watch(collectionsRepositoryProvider).getGroupsForCollection(collectionId);
});

final weakCardsProvider = Provider.family<List<CardItem>, String>((ref, collectionId) {
  ref.watch(repositoryInitializationProvider);
  return ref.watch(collectionsRepositoryProvider).getWeakCards(collectionId);
});

final achievementsProvider = Provider<List<Achievement>>((ref) {
  ref.watch(repositoryInitializationProvider);
  return ref.watch(collectionsRepositoryProvider).getAchievements();
});

final studyPlansProvider = Provider<List<StudyPlan>>((ref) {
  ref.watch(repositoryInitializationProvider);
  return ref.watch(collectionsRepositoryProvider).getStudyPlans();
});

final userStatsProvider = Provider<UserStats>((ref) {
  ref.watch(repositoryInitializationProvider);
  return ref.watch(collectionsRepositoryProvider).getStats();
});
