import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yandex_dance/features/friends/domain/entities/friend_coach.dart';

/// Модель документа Firestore `coaches/{coachId}`.
///
/// Поля документа:
/// - `name` (string)
/// - `styles` (array of string)
/// - `description` (string)
/// - `rating` (number)
/// - `avatarUrl` (string)
class FriendCoachModel {
  const FriendCoachModel({
    required this.id,
    required this.name,
    required this.styles,
    required this.description,
    required this.rating,
    required this.avatarUrl,
  });

  final String id;
  final String name;
  final List<String> styles;
  final String description;
  final double rating;
  final String avatarUrl;

  factory FriendCoachModel.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    if (data == null) {
      throw StateError('Friend coach ${doc.id}: empty data');
    }

    final raw = data['styles'];
    final styles =
        raw is List ? raw.map((e) => e.toString()).toList() : <String>[];

    return FriendCoachModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      styles: styles,
      description: data['description'] as String? ?? '',
      rating: (data['rating'] as num?)?.toDouble() ?? 0,
      avatarUrl: data['avatarUrl'] as String? ?? '',
    );
  }

  FriendCoach toEntity() {
    return FriendCoach(
      id: id,
      name: name,
      styles: styles,
      description: description,
      rating: rating,
      avatarUrl: avatarUrl,
    );
  }
}
