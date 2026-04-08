import 'package:yandex_dance/core/enums/dance_style.dart';
import 'package:yandex_dance/core/utils/optional.dart';
import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  const UserProfile({
    required this.uid,
    this.email,
    this.displayName,
    this.bio,
    this.city,
    this.dateOfBirth,
    this.rating,
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
    this.followersCount = 0,
    this.followingCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  final String uid;
  final String? email;
  final String? displayName;
  final String? bio;
  final String? city;
  final DateTime? dateOfBirth;
  final double? rating;

  final String? avatarUrl;
  final String? avatarThumbUrl;
  final String? avatarStoragePath;
  final String? avatarThumbStoragePath;

  final String? introVideoUrl;
  final String? introVideoThumbUrl;
  final String? introVideoStoragePath;
  final String? introVideoThumbStoragePath;

  final List<DanceStyle> danceStyles;
  final bool onboardingCompleted;

  /// Число подписчиков (поле `followersCount` в Firestore).
  final int followersCount;

  /// Число подписок (поле `followingCount` в Firestore).
  final int followingCount;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  int? get age {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    int years = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month ||
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      years--;
    }
    return years;
  }

  bool get hasVideo => introVideoUrl != null && introVideoUrl!.isNotEmpty;
  bool get hasAvatar => avatarUrl != null && avatarUrl!.isNotEmpty;

  UserProfile copyWith({
    String? email,
    String? displayName,
    String? bio,
    String? city,
    Optional<DateTime>? dateOfBirth,
    double? rating,
    Optional<String>? avatarUrl,
    Optional<String>? avatarThumbUrl,
    Optional<String>? avatarStoragePath,
    Optional<String>? avatarThumbStoragePath,
    Optional<String>? introVideoUrl,
    Optional<String>? introVideoThumbUrl,
    Optional<String>? introVideoStoragePath,
    Optional<String>? introVideoThumbStoragePath,
    List<DanceStyle>? danceStyles,
    bool? onboardingCompleted,
    int? followersCount,
    int? followingCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      uid: uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      city: city ?? this.city,
      dateOfBirth: dateOfBirth != null ? dateOfBirth.value : this.dateOfBirth,
      rating: rating ?? this.rating,
      avatarUrl: avatarUrl != null ? avatarUrl.value : this.avatarUrl,
      avatarThumbUrl:
          avatarThumbUrl != null ? avatarThumbUrl.value : this.avatarThumbUrl,
      avatarStoragePath:
          avatarStoragePath != null
              ? avatarStoragePath.value
              : this.avatarStoragePath,
      avatarThumbStoragePath:
          avatarThumbStoragePath != null
              ? avatarThumbStoragePath.value
              : this.avatarThumbStoragePath,
      introVideoUrl:
          introVideoUrl != null ? introVideoUrl.value : this.introVideoUrl,
      introVideoThumbUrl:
          introVideoThumbUrl != null
              ? introVideoThumbUrl.value
              : this.introVideoThumbUrl,
      introVideoStoragePath:
          introVideoStoragePath != null
              ? introVideoStoragePath.value
              : this.introVideoStoragePath,
      introVideoThumbStoragePath:
          introVideoThumbStoragePath != null
              ? introVideoThumbStoragePath.value
              : this.introVideoThumbStoragePath,
      danceStyles: danceStyles ?? this.danceStyles,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    uid,
    email,
    displayName,
    bio,
    city,
    dateOfBirth,
    rating,
    avatarUrl,
    avatarThumbUrl,
    avatarStoragePath,
    avatarThumbStoragePath,
    introVideoUrl,
    introVideoThumbUrl,
    introVideoStoragePath,
    introVideoThumbStoragePath,
    danceStyles,
    onboardingCompleted,
    followersCount,
    followingCount,
    createdAt,
    updatedAt,
  ];
}
