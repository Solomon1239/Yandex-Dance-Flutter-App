import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yandex_dance/core/enums/dance_style.dart';
import 'package:yandex_dance/features/events/domain/entities/dance_event.dart';

class DanceEventModel {
  const DanceEventModel({
    required this.id,
    required this.title,
    required this.description,
    this.coverUrl,
    this.coverThumbUrl,
    this.coverStoragePath,
    this.coverThumbStoragePath,
    required this.danceStyle,
    required this.dateTime,
    required this.address,
    required this.maxParticipants,
    required this.participantIds,
    required this.ageRestriction,
    this.promoVideoUrl,
    this.promoVideoThumbUrl,
    this.promoVideoStoragePath,
    this.promoVideoThumbStoragePath,
    required this.creatorId,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String title;
  final String description;

  final String? coverUrl;
  final String? coverThumbUrl;
  final String? coverStoragePath;
  final String? coverThumbStoragePath;

  final String danceStyle;
  final DateTime dateTime;
  final String address;
  final int maxParticipants;
  final List<String> participantIds;
  final String ageRestriction;

  final String? promoVideoUrl;
  final String? promoVideoThumbUrl;
  final String? promoVideoStoragePath;
  final String? promoVideoThumbStoragePath;

  final String creatorId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory DanceEventModel.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return DanceEventModel(
      id: doc.id,
      title: data['title'] as String,
      description: data['description'] as String,
      coverUrl: data['coverUrl'] as String?,
      coverThumbUrl: data['coverThumbUrl'] as String?,
      coverStoragePath: data['coverStoragePath'] as String?,
      coverThumbStoragePath: data['coverThumbStoragePath'] as String?,
      danceStyle: data['danceStyle'] as String,
      dateTime: _dateFromDynamic(data['dateTime'])!,
      address: data['address'] as String,
      maxParticipants: data['maxParticipants'] as int,
      participantIds: List<String>.from(data['participantIds'] ?? const []),
      ageRestriction: data['ageRestriction'] as String? ?? 'Для всех',
      promoVideoUrl: data['promoVideoUrl'] as String?,
      promoVideoThumbUrl: data['promoVideoThumbUrl'] as String?,
      promoVideoStoragePath: data['promoVideoStoragePath'] as String?,
      promoVideoThumbStoragePath:
          data['promoVideoThumbStoragePath'] as String?,
      creatorId: data['creatorId'] as String,
      createdAt: _dateFromDynamic(data['createdAt']),
      updatedAt: _dateFromDynamic(data['updatedAt']),
    );
  }

  DanceEvent toEntity() {
    return DanceEvent(
      id: id,
      title: title,
      description: description,
      coverUrl: coverUrl,
      coverThumbUrl: coverThumbUrl,
      coverStoragePath: coverStoragePath,
      coverThumbStoragePath: coverThumbStoragePath,
      danceStyle: DanceStyleX.fromCode(danceStyle),
      dateTime: dateTime,
      address: address,
      maxParticipants: maxParticipants,
      participantIds: participantIds,
      ageRestriction: ageRestriction,
      promoVideoUrl: promoVideoUrl,
      promoVideoThumbUrl: promoVideoThumbUrl,
      promoVideoStoragePath: promoVideoStoragePath,
      promoVideoThumbStoragePath: promoVideoThumbStoragePath,
      creatorId: creatorId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static DanceEventModel fromEntity(DanceEvent entity) {
    return DanceEventModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      coverUrl: entity.coverUrl,
      coverThumbUrl: entity.coverThumbUrl,
      coverStoragePath: entity.coverStoragePath,
      coverThumbStoragePath: entity.coverThumbStoragePath,
      danceStyle: entity.danceStyle.code,
      dateTime: entity.dateTime,
      address: entity.address,
      maxParticipants: entity.maxParticipants,
      participantIds: entity.participantIds,
      ageRestriction: entity.ageRestriction,
      promoVideoUrl: entity.promoVideoUrl,
      promoVideoThumbUrl: entity.promoVideoThumbUrl,
      promoVideoStoragePath: entity.promoVideoStoragePath,
      promoVideoThumbStoragePath: entity.promoVideoThumbStoragePath,
      creatorId: entity.creatorId,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  Map<String, dynamic> toMapForCreate() {
    return {
      'title': title,
      'description': description,
      'coverUrl': coverUrl,
      'coverThumbUrl': coverThumbUrl,
      'coverStoragePath': coverStoragePath,
      'coverThumbStoragePath': coverThumbStoragePath,
      'danceStyle': danceStyle,
      'dateTime': Timestamp.fromDate(dateTime),
      'address': address,
      'maxParticipants': maxParticipants,
      'participantIds': participantIds,
      'ageRestriction': ageRestriction,
      'promoVideoUrl': promoVideoUrl,
      'promoVideoThumbUrl': promoVideoThumbUrl,
      'promoVideoStoragePath': promoVideoStoragePath,
      'promoVideoThumbStoragePath': promoVideoThumbStoragePath,
      'creatorId': creatorId,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toMapForUpdate() {
    return {
      'title': title,
      'description': description,
      'coverUrl': coverUrl,
      'coverThumbUrl': coverThumbUrl,
      'coverStoragePath': coverStoragePath,
      'coverThumbStoragePath': coverThumbStoragePath,
      'danceStyle': danceStyle,
      'dateTime': Timestamp.fromDate(dateTime),
      'address': address,
      'maxParticipants': maxParticipants,
      'participantIds': participantIds,
      'ageRestriction': ageRestriction,
      'promoVideoUrl': promoVideoUrl,
      'promoVideoThumbUrl': promoVideoThumbUrl,
      'promoVideoStoragePath': promoVideoStoragePath,
      'promoVideoThumbStoragePath': promoVideoThumbStoragePath,
      'creatorId': creatorId,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static DateTime? _dateFromDynamic(dynamic value) {
    if (value is Timestamp) return value.toDate();
    return null;
  }
}
