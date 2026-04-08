import 'package:equatable/equatable.dart';

/// Запись из коллекции `coaches` (мок / Firestore) для списков, где нужны
/// предзагруженные карточки. Экран профиля другого пользователя строится из [UserProfile].
class FriendCoach extends Equatable {
  FriendCoach({
    required this.id,
    required this.name,
    required List<String> styles,
    required this.description,
    required this.rating,
    required this.avatarUrl,
  }) : styles = List.unmodifiable(styles);

  final String id;
  final String name;
  final List<String> styles;
  final String description;
  final double rating;
  final String avatarUrl;

  String get stylesLabel => styles.join(' · ');

  @override
  List<Object?> get props => [id, name, styles, description, rating, avatarUrl];
}
