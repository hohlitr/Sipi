import 'dart:convert';

import 'achievement.dart';
import 'card_group.dart';
import 'card_item.dart';
import 'collection.dart';
import 'study_plan.dart';

Map<String, dynamic> collectionToJson(StudyCollection collection) => {
      'id': collection.id,
      'title': collection.title,
      'description': collection.description,
      'createdAt': collection.createdAt.toIso8601String(),
      'updatedAt': collection.updatedAt.toIso8601String(),
    };

StudyCollection collectionFromJson(Map<String, dynamic> json) => StudyCollection(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> cardToJson(CardItem card) => {
      'id': card.id,
      'collectionId': card.collectionId,
      'question': card.question,
      'answer': card.answer,
      'note': card.note,
      'correctAnswers': card.correctAnswers,
      'attempts': card.attempts,
      'masteryLevel': card.masteryLevel,
    };

CardItem cardFromJson(Map<String, dynamic> json) => CardItem(
      id: json['id'] as String,
      collectionId: json['collectionId'] as String,
      question: json['question'] as String,
      answer: json['answer'] as String,
      note: json['note'] as String?,
      correctAnswers: json['correctAnswers'] as int? ?? 0,
      attempts: json['attempts'] as int? ?? 0,
      masteryLevel: (json['masteryLevel'] as num?)?.toDouble() ?? 0,
    );

Map<String, dynamic> groupToJson(CardGroup group) => {
      'id': group.id,
      'collectionId': group.collectionId,
      'title': group.title,
      'cardIds': group.cardIds,
    };

CardGroup groupFromJson(Map<String, dynamic> json) => CardGroup(
      id: json['id'] as String,
      collectionId: json['collectionId'] as String,
      title: json['title'] as String,
      cardIds: (json['cardIds'] as List<dynamic>? ?? const []).cast<String>(),
    );

Map<String, dynamic> achievementToJson(Achievement achievement) => {
      'id': achievement.id,
      'title': achievement.title,
      'description': achievement.description,
      'requiredProgress': achievement.requiredProgress,
      'imagePath': achievement.imagePath,
    };

Achievement achievementFromJson(Map<String, dynamic> json) => Achievement(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      requiredProgress: (json['requiredProgress'] as num).toDouble(),
      imagePath: json['imagePath'] as String?,
    );

Map<String, dynamic> studyPlanToJson(StudyPlan plan) => {
      'id': plan.id,
      'collectionId': plan.collectionId,
      'startDate': plan.startDate.toIso8601String(),
      'endDate': plan.endDate.toIso8601String(),
      'targetProgress': plan.targetProgress,
    };

StudyPlan studyPlanFromJson(Map<String, dynamic> json) => StudyPlan(
      id: json['id'] as String,
      collectionId: json['collectionId'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      targetProgress: (json['targetProgress'] as num).toDouble(),
    );

String encodeJsonList(List<Map<String, dynamic>> value) => jsonEncode(value);
List<Map<String, dynamic>> decodeJsonList(String value) =>
    (jsonDecode(value) as List<dynamic>).cast<Map<String, dynamic>>();
