import 'package:flutter/material.dart';

class EventPreview {
  const EventPreview({
    required this.id,
    required this.title,
    required this.styleLabel,
    required this.ageRestrictionLabel,
    required this.dateTime,
    required this.dateLabel,
    required this.locationLabel,
    required this.authorLabel,
    required this.currentParticipants,
    required this.maxParticipants,
    required this.participantsLabel,
    required this.latitude,
    required this.longitude,
    this.description,
    this.authorAvatarImage,
    this.coverImage,
  });

  final String id;
  final String title;
  final String styleLabel;
  final String ageRestrictionLabel;
  final DateTime dateTime;
  final String dateLabel;
  final String locationLabel;
  final String authorLabel;
  final int currentParticipants;
  final int maxParticipants;
  final String participantsLabel;
  final double latitude;
  final double longitude;
  final String? description;
  final ImageProvider<Object>? authorAvatarImage;
  final ImageProvider<Object>? coverImage;

  bool get hasFreeSpots => currentParticipants < maxParticipants;
}
