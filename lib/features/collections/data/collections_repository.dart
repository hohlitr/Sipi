import '../../../core/models/card_group.dart';
import '../../../core/models/card_item.dart';
import '../../../core/models/collection.dart';
import '../../../core/models/user_stats.dart';

class CollectionsRepository {
  CollectionsRepository()
      : _collections = [
          StudyCollection(
            id: 'bio',
            title: 'Biology basics',
            description: 'Starter deck for MVP testing',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ],
        _cards = [
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
        ],
        _groups = [
          const CardGroup(
            id: 'bio-important',
            collectionId: 'bio',
            title: 'Important definitions',
            cardIds: ['bio-1', 'bio-2'],
          ),
        ];

  final List<StudyCollection> _collections;
  final List<CardItem> _cards;
  final List<CardGroup> _groups;

  List<StudyCollection> getCollections() => List.unmodifiable(_collections);

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

  void addCollection(String title, String description) {
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
  }

  void addCard({
    required String collectionId,
    required String question,
    required String answer,
    String? note,
  }) {
    _cards.add(
      CardItem(
        id: 'card-${DateTime.now().microsecondsSinceEpoch}',
        collectionId: collectionId,
        question: question,
        answer: answer,
        note: note,
      ),
    );
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
}
