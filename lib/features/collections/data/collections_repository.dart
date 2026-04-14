import '../../../core/models/achievement.dart';
import '../../../core/models/card_group.dart';
import '../../../core/models/card_item.dart';
import '../../../core/models/collection.dart';
import '../../../core/models/serializable_models.dart';
import '../../../core/models/study_plan.dart';
import '../../../core/models/user_stats.dart';
import 'local_storage_service.dart';

class CollectionsRepository {
  CollectionsRepository(this._storageService);

  final LocalStorageService _storageService;

  final List<StudyCollection> _collections = [];
  final List<CardItem> _cards = [];
  final List<CardGroup> _groups = [];
  final List<Achievement> _achievements = [];
  final List<StudyPlan> _studyPlans = [];
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    final collectionsRaw = await _storageService.read(LocalStorageService.collectionsKey);
    final cardsRaw = await _storageService.read(LocalStorageService.cardsKey);
    final groupsRaw = await _storageService.read(LocalStorageService.groupsKey);
    final achievementsRaw = await _storageService.read(LocalStorageService.achievementsKey);
    final studyPlansRaw = await _storageService.read(LocalStorageService.studyPlansKey);

    if (collectionsRaw == null || cardsRaw == null) {
      _seedDemoData();
      await _persist();
      _isInitialized = true;
      return;
    }

    _collections
      ..clear()
      ..addAll(decodeJsonList(collectionsRaw).map(collectionFromJson));
    _cards
      ..clear()
      ..addAll(decodeJsonList(cardsRaw).map(cardFromJson));
    _groups
      ..clear()
      ..addAll(groupsRaw == null ? const [] : decodeJsonList(groupsRaw).map(groupFromJson));
    _achievements
      ..clear()
      ..addAll(achievementsRaw == null
          ? const []
          : decodeJsonList(achievementsRaw).map(achievementFromJson));
    _studyPlans
      ..clear()
      ..addAll(studyPlansRaw == null
          ? const []
          : decodeJsonList(studyPlansRaw).map(studyPlanFromJson));

    _isInitialized = true;
  }

  List<StudyCollection> getCollections() => List.unmodifiable(_collections);
  List<Achievement> getAchievements() => List.unmodifiable(_achievements);
  List<StudyPlan> getStudyPlans() => List.unmodifiable(_studyPlans);

  StudyCollection? getCollectionById(String id) {
    for (final collection in _collections) {
      if (collection.id == id) return collection;
    }
    return null;
  }

  List<CardItem> getCardsForCollection(String collectionId) {
    return _cards.where((card) => card.collectionId == collectionId).toList();
  }

  List<CardGroup> getGroupsForCollection(String collectionId) {
    return _groups.where((group) => group.collectionId == collectionId).toList();
  }

  Future<void> addCollection(String title, String description) async {
    final now = DateTime.now();
    _collections.add(
      StudyCollection(
        id: 'collection-${now.microsecondsSinceEpoch}',
        title: title,
        description: description.isEmpty ? null : description,
        createdAt: now,
        updatedAt: now,
      ),
    );
    await _persist();
  }

  Future<void> updateCollection({
    required String collectionId,
    required String title,
    required String description,
  }) async {
    final index = _collections.indexWhere((collection) => collection.id == collectionId);
    if (index == -1) return;

    final current = _collections[index];
    _collections[index] = StudyCollection(
      id: current.id,
      title: title,
      description: description.isEmpty ? null : description,
      createdAt: current.createdAt,
      updatedAt: DateTime.now(),
    );
    await _persist();
  }

  Future<void> deleteCollection(String collectionId) async {
    _collections.removeWhere((collection) => collection.id == collectionId);
    _cards.removeWhere((card) => card.collectionId == collectionId);
    _groups.removeWhere((group) => group.collectionId == collectionId);
    _studyPlans.removeWhere((plan) => plan.collectionId == collectionId);
    await _persist();
  }

  Future<void> addCard({
    required String collectionId,
    required String question,
    required String answer,
    String? note,
  }) async {
    _cards.add(
      CardItem(
        id: 'card-${DateTime.now().microsecondsSinceEpoch}',
        collectionId: collectionId,
        question: question,
        answer: answer,
        note: note,
      ),
    );
    await _persist();
  }

  Future<void> updateCard({
    required String cardId,
    required String question,
    required String answer,
    String? note,
  }) async {
    final index = _cards.indexWhere((card) => card.id == cardId);
    if (index == -1) return;

    final current = _cards[index];
    _cards[index] = CardItem(
      id: current.id,
      collectionId: current.collectionId,
      question: question,
      answer: answer,
      note: note,
      correctAnswers: current.correctAnswers,
      attempts: current.attempts,
      masteryLevel: current.masteryLevel,
    );
    await _persist();
  }

  Future<void> deleteCard(String cardId) async {
    _cards.removeWhere((card) => card.id == cardId);
    for (var i = 0; i < _groups.length; i++) {
      final group = _groups[i];
      _groups[i] = CardGroup(
        id: group.id,
        collectionId: group.collectionId,
        title: group.title,
        cardIds: group.cardIds.where((id) => id != cardId).toList(),
      );
    }
    await _persist();
  }

  Future<void> recordQuizAnswer({
    required String collectionId,
    required String cardId,
    required bool correct,
  }) async {
    final index = _cards.indexWhere((card) => card.id == cardId && card.collectionId == collectionId);
    if (index == -1) return;

    final current = _cards[index];
    final attempts = current.attempts + 1;
    final correctAnswers = current.correctAnswers + (correct ? 1 : 0);

    _cards[index] = CardItem(
      id: current.id,
      collectionId: current.collectionId,
      question: current.question,
      answer: current.answer,
      note: current.note,
      correctAnswers: correctAnswers,
      attempts: attempts,
      masteryLevel: correctAnswers / attempts,
    );

    await _persist();
  }

  Future<void> addStudyPlan({
    required String collectionId,
    required DateTime startDate,
    required DateTime endDate,
    required double targetProgress,
  }) async {
    _studyPlans.add(
      StudyPlan(
        id: 'plan-${DateTime.now().microsecondsSinceEpoch}',
        collectionId: collectionId,
        startDate: startDate,
        endDate: endDate,
        targetProgress: targetProgress,
      ),
    );
    await _persist();
  }

  List<CardItem> getWeakCards(String collectionId, {int limit = 10}) {
    final cards = getCardsForCollection(collectionId);
    cards.sort((a, b) => a.masteryLevel.compareTo(b.masteryLevel));
    return cards.take(limit).toList();
  }

  UserStats getStats() {
    final totalAttempts = _cards.fold<int>(0, (sum, card) => sum + card.attempts);
    final totalCorrectAnswers = _cards.fold<int>(0, (sum, card) => sum + card.correctAnswers);

    return UserStats(
      totalCollections: _collections.length,
      totalCards: _cards.length,
      totalAttempts: totalAttempts,
      totalCorrectAnswers: totalCorrectAnswers,
    );
  }

  Future<String> exportCollection(String collectionId) async {
    final collection = getCollectionById(collectionId);
    final cards = getCardsForCollection(collectionId);
    if (collection == null) return '{}';

    return encodeJsonList([
      {
        'collection': collectionToJson(collection),
        'cards': cards
            .map((card) => {
                  'id': card.id,
                  'question': card.question,
                  'answer': card.answer,
                  'note': card.note,
                })
            .toList(),
      }
    ]);
  }

  void _seedDemoData() {
    final now = DateTime.now();
    _collections
      ..clear()
      ..add(
        StudyCollection(
          id: 'bio',
          title: 'Biology basics',
          description: 'Starter deck for MVP testing',
          createdAt: now,
          updatedAt: now,
        ),
      );
    _cards
      ..clear()
      ..addAll([
        const CardItem(
          id: 'bio-1',
          collectionId: 'bio',
          question: 'What is a cell?',
          answer: 'The basic structural and functional unit of life.',
          note: 'Start with the simplest definition.',
          correctAnswers: 2,
          attempts: 3,
          masteryLevel: 0.66,
        ),
        const CardItem(
          id: 'bio-2',
          collectionId: 'bio',
          question: 'What carries genetic information?',
          answer: 'DNA carries genetic information.',
          correctAnswers: 1,
          attempts: 3,
          masteryLevel: 0.33,
        ),
      ]);
    _groups
      ..clear()
      ..add(
        const CardGroup(
          id: 'bio-important',
          collectionId: 'bio',
          title: 'Important definitions',
          cardIds: ['bio-1', 'bio-2'],
        ),
      );
    _achievements
      ..clear()
      ..add(
        const Achievement(
          id: 'first-steps',
          title: 'First steps',
          description: 'Create your first collection',
          requiredProgress: 0.0,
        ),
      );
    _studyPlans
      ..clear();
  }

  Future<void> _persist() async {
    await _storageService.write(
      LocalStorageService.collectionsKey,
      encodeJsonList(_collections.map(collectionToJson).toList()),
    );
    await _storageService.write(
      LocalStorageService.cardsKey,
      encodeJsonList(_cards.map(cardToJson).toList()),
    );
    await _storageService.write(
      LocalStorageService.groupsKey,
      encodeJsonList(_groups.map(groupToJson).toList()),
    );
    await _storageService.write(
      LocalStorageService.achievementsKey,
      encodeJsonList(_achievements.map(achievementToJson).toList()),
    );
    await _storageService.write(
      LocalStorageService.studyPlansKey,
      encodeJsonList(_studyPlans.map(studyPlanToJson).toList()),
    );
  }
}
