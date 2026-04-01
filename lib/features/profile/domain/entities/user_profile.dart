import 'package:yandex_dance/core/enums/dance_style.dart';
import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  const UserProfile({
    required this.uid,
    this.displayName,
    this.bio,
    this.city,
    this.age,
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
    this.createdAt,
    this.updatedAt,
  });

  final String uid;
  final String? displayName;
  final String? bio;
  final String? city;
  final int? age;
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

  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get hasVideo => introVideoUrl != null && introVideoUrl!.isNotEmpty;
  bool get hasAvatar => avatarUrl != null && avatarUrl!.isNotEmpty;

  UserProfile copyWith({
    String? displayName,
    String? bio,
    String? city,
    int? age,
    double? rating,
    String? avatarUrl,
    String? avatarThumbUrl,
    String? avatarStoragePath,
    String? avatarThumbStoragePath,
    String? introVideoUrl,
    String? introVideoThumbUrl,
    String? introVideoStoragePath,
    String? introVideoThumbStoragePath,
    List<DanceStyle>? danceStyles,
    bool? onboardingCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      uid: uid,
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      city: city ?? this.city,
      age: age ?? this.age,
      rating: rating ?? this.rating,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      avatarThumbUrl: avatarThumbUrl ?? this.avatarThumbUrl,
      avatarStoragePath: avatarStoragePath ?? this.avatarStoragePath,
      avatarThumbStoragePath:
          avatarThumbStoragePath ?? this.avatarThumbStoragePath,
      introVideoUrl: introVideoUrl ?? this.introVideoUrl,
      introVideoThumbUrl: introVideoThumbUrl ?? this.introVideoThumbUrl,
      introVideoStoragePath:
          introVideoStoragePath ?? this.introVideoStoragePath,
      introVideoThumbStoragePath:
          introVideoThumbStoragePath ?? this.introVideoThumbStoragePath,
      danceStyles: danceStyles ?? this.danceStyles,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    uid,
    displayName,
    bio,
    city,
    age,
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
    createdAt,
    updatedAt,
  ];
}
