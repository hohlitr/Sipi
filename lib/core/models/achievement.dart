import 'package:equatable/equatable.dart';

class Achievement extends Equatable {
  final String id;
  final String title;
  final String description;
  final double requiredProgress;
  final String? imagePath;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.requiredProgress,
    this.imagePath,
  });

  @override
  List<Object?> get props => [id, title, description, requiredProgress, imagePath];
}
