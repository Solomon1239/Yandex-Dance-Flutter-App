import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yandex_dance/core/enums/dance_style.dart';
import 'package:yandex_dance/features/profile/domain/entities/user_profile.dart';

class UserProfileModel {
  const UserProfileModel({
    required this.uid,
    this.email,
    this.displayName,
    this.bio,
    this.city,
    this.dateOfBirth,
    this.avatarUrl,
    this.avatarThumbUrl,
    this.avatarStoragePath,
    this.avatarThumbStoragePath,
    this.introVideoUrl,
    this.introVideoThumbUrl,
    this.introVideoStoragePath,
    this.introVideoThumbStoragePath,
    required this.danceStyles,
    required this.onboardingCompleted,
    this.followingIds = const [],
    this.createdAt,
    this.updatedAt,
  });

  final String uid;
  final String? email;
  final String? displayName;
  final String? bio;
  final String? city;
  final DateTime? dateOfBirth;
  final String? avatarUrl;
  final String? avatarThumbUrl;
  final String? avatarStoragePath;
  final String? avatarThumbStoragePath;

  final String? introVideoUrl;
  final String? introVideoThumbUrl;
  final String? introVideoStoragePath;
  final String? introVideoThumbStoragePath;

  final List<String> danceStyles;
  final bool onboardingCompleted;

  final List<String> followingIds;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory UserProfileModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return UserProfileModel(
      uid: data['uid'] as String,
      email: data['email'] as String?,
      displayName: data['displayName'] as String?,
      bio: data['bio'] as String?,
      city: data['city'] as String?,
      dateOfBirth: _dateFromDynamic(data['dateOfBirth']),
      avatarUrl: data['avatarUrl'] as String?,
      avatarThumbUrl: data['avatarThumbUrl'] as String?,
      avatarStoragePath: data['avatarStoragePath'] as String?,
      avatarThumbStoragePath: data['avatarThumbStoragePath'] as String?,
      introVideoUrl: data['introVideoUrl'] as String?,
      introVideoThumbUrl: data['introVideoThumbUrl'] as String?,
      introVideoStoragePath: data['introVideoStoragePath'] as String?,
      introVideoThumbStoragePath: data['introVideoThumbStoragePath'] as String?,
      danceStyles: List<String>.from(data['danceStyles'] ?? const []),
      onboardingCompleted: data['onboardingCompleted'] as bool? ??
          List<String>.from(data['danceStyles'] ?? const []).isNotEmpty,
      followingIds: List<String>.from(data['followingIds'] ?? data['friendIds'] ?? const []),
      createdAt: _dateFromDynamic(data['createdAt']),
      updatedAt: _dateFromDynamic(data['updatedAt']),
    );
  }

  UserProfile toEntity() {
    return UserProfile(
      uid: uid,
      email: email,
      displayName: displayName,
      bio: bio,
      city: city,
      dateOfBirth: dateOfBirth,
      avatarUrl: avatarUrl,
      avatarThumbUrl: avatarThumbUrl,
      avatarStoragePath: avatarStoragePath,
      avatarThumbStoragePath: avatarThumbStoragePath,
      introVideoUrl: introVideoUrl,
      introVideoThumbUrl: introVideoThumbUrl,
      introVideoStoragePath: introVideoStoragePath,
      introVideoThumbStoragePath: introVideoThumbStoragePath,
      danceStyles: danceStyles.map(DanceStyleX.fromCode).toList(),
      onboardingCompleted: onboardingCompleted,
      followingIds: followingIds,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static UserProfileModel fromEntity(UserProfile entity) {
    return UserProfileModel(
      uid: entity.uid,
      email: entity.email,
      displayName: entity.displayName,
      bio: entity.bio,
      city: entity.city,
      dateOfBirth: entity.dateOfBirth,
      avatarUrl: entity.avatarUrl,
      avatarThumbUrl: entity.avatarThumbUrl,
      avatarStoragePath: entity.avatarStoragePath,
      avatarThumbStoragePath: entity.avatarThumbStoragePath,
      introVideoUrl: entity.introVideoUrl,
      introVideoThumbUrl: entity.introVideoThumbUrl,
      introVideoStoragePath: entity.introVideoStoragePath,
      introVideoThumbStoragePath: entity.introVideoThumbStoragePath,
      danceStyles: entity.danceStyles.map((e) => e.code).toList(),
      onboardingCompleted: entity.onboardingCompleted,
      followingIds: entity.followingIds,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  Map<String, dynamic> toMapForCreate() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'bio': bio,
      'city': city,
      'dateOfBirth':
          dateOfBirth != null ? Timestamp.fromDate(dateOfBirth!) : null,
      'avatarUrl': avatarUrl,
      'avatarThumbUrl': avatarThumbUrl,
      'avatarStoragePath': avatarStoragePath,
      'avatarThumbStoragePath': avatarThumbStoragePath,
      'introVideoUrl': introVideoUrl,
      'introVideoThumbUrl': introVideoThumbUrl,
      'introVideoStoragePath': introVideoStoragePath,
      'introVideoThumbStoragePath': introVideoThumbStoragePath,
      'danceStyles': danceStyles,
      'onboardingCompleted': onboardingCompleted,
      'followingIds': followingIds,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toMapForUpdate() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'bio': bio,
      'city': city,
      'dateOfBirth':
          dateOfBirth != null ? Timestamp.fromDate(dateOfBirth!) : null,
      'avatarUrl': avatarUrl,
      'avatarThumbUrl': avatarThumbUrl,
      'avatarStoragePath': avatarStoragePath,
      'avatarThumbStoragePath': avatarThumbStoragePath,
      'introVideoUrl': introVideoUrl,
      'introVideoThumbUrl': introVideoThumbUrl,
      'introVideoStoragePath': introVideoStoragePath,
      'introVideoThumbStoragePath': introVideoThumbStoragePath,
      'danceStyles': danceStyles,
      'onboardingCompleted': onboardingCompleted,
      'followingIds': followingIds,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static DateTime? _dateFromDynamic(dynamic value) {
    if (value is Timestamp) return value.toDate();
    return null;
  }
}
