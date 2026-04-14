import 'package:equatable/equatable.dart';

class CardGroup extends Equatable {
  final String id;
  final String collectionId;
  final String title;
  final List<String> cardIds;

  const CardGroup({
    required this.id,
    required this.collectionId,
    required this.title,
    this.cardIds = const [],
  });

  @override
  List<Object?> get props => [id, collectionId, title, cardIds];
}
