import 'package:equatable/equatable.dart';

class StudyPlan extends Equatable {
  final String id;
  final String collectionId;
  final DateTime startDate;
  final DateTime endDate;
  final double targetProgress;

  const StudyPlan({
    required this.id,
    required this.collectionId,
    required this.startDate,
    required this.endDate,
    required this.targetProgress,
  });

  @override
  List<Object?> get props => [id, collectionId, startDate, endDate, targetProgress];
}
