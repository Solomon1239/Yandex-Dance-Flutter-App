import 'package:equatable/equatable.dart';
import 'package:yandex_dance/core/enums/dance_style.dart';

class DanceEvent extends Equatable {
  const DanceEvent({
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
    this.latitude,
    this.longitude,
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

  final DanceStyle danceStyle;
  final DateTime dateTime;
  final String address;
  final double? latitude;
  final double? longitude;
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

  int get currentParticipants => participantIds.length;
  bool get isFull => currentParticipants >= maxParticipants;
  bool get hasCover => coverUrl != null && coverUrl!.isNotEmpty;
  bool get hasPromoVideo => promoVideoUrl != null && promoVideoUrl!.isNotEmpty;

  bool isParticipant(String uid) => participantIds.contains(uid);
  bool isCreator(String uid) => creatorId == uid;

  DanceEvent copyWith({
    String? title,
    String? description,
    String? coverUrl,
    String? coverThumbUrl,
    String? coverStoragePath,
    String? coverThumbStoragePath,
    DanceStyle? danceStyle,
    DateTime? dateTime,
    String? address,
    double? latitude,
    double? longitude,
    int? maxParticipants,
    List<String>? participantIds,
    String? ageRestriction,
    String? promoVideoUrl,
    String? promoVideoThumbUrl,
    String? promoVideoStoragePath,
    String? promoVideoThumbStoragePath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DanceEvent(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      coverUrl: coverUrl ?? this.coverUrl,
      coverThumbUrl: coverThumbUrl ?? this.coverThumbUrl,
      coverStoragePath: coverStoragePath ?? this.coverStoragePath,
      coverThumbStoragePath:
          coverThumbStoragePath ?? this.coverThumbStoragePath,
      danceStyle: danceStyle ?? this.danceStyle,
      dateTime: dateTime ?? this.dateTime,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      participantIds: participantIds ?? this.participantIds,
      ageRestriction: ageRestriction ?? this.ageRestriction,
      promoVideoUrl: promoVideoUrl ?? this.promoVideoUrl,
      promoVideoThumbUrl: promoVideoThumbUrl ?? this.promoVideoThumbUrl,
      promoVideoStoragePath:
          promoVideoStoragePath ?? this.promoVideoStoragePath,
      promoVideoThumbStoragePath:
          promoVideoThumbStoragePath ?? this.promoVideoThumbStoragePath,
      creatorId: creatorId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    coverUrl,
    coverThumbUrl,
    coverStoragePath,
    coverThumbStoragePath,
    danceStyle,
    dateTime,
    address,
    latitude,
    longitude,
    maxParticipants,
    participantIds,
    ageRestriction,
    promoVideoUrl,
    promoVideoThumbUrl,
    promoVideoStoragePath,
    promoVideoThumbStoragePath,
    creatorId,
    createdAt,
    updatedAt,
  ];
}
