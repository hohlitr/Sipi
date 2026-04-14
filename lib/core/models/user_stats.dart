import 'package:equatable/equatable.dart';

class UserStats extends Equatable {
  final int totalCollections;
  final int totalCards;
  final int totalAttempts;
  final int totalCorrectAnswers;

  const UserStats({
    required this.totalCollections,
    required this.totalCards,
    required this.totalAttempts,
    required this.totalCorrectAnswers,
  });

  double get accuracy => totalAttempts == 0 ? 0 : totalCorrectAnswers / totalAttempts;

  @override
  List<Object?> get props => [
        totalCollections,
        totalCards,
        totalAttempts,
        totalCorrectAnswers,
      ];
}
