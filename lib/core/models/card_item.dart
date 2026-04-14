import 'package:equatable/equatable.dart';

class CardItem extends Equatable {
  final String id;
  final String collectionId;
  final String question;
  final String answer;
  final String? note;
  final int correctAnswers;
  final int attempts;
  final double masteryLevel;

  const CardItem({
    required this.id,
    required this.collectionId,
    required this.question,
    required this.answer,
    this.note,
    this.correctAnswers = 0,
    this.attempts = 0,
    this.masteryLevel = 0,
  });

  @override
  List<Object?> get props => [
        id,
        collectionId,
        question,
        answer,
        note,
        correctAnswers,
        attempts,
        masteryLevel,
      ];
}
