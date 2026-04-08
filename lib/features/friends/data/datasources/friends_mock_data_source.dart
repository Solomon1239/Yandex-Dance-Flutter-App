import 'package:yandex_dance/features/friends/data/datasources/friends_data_source.dart';
import 'package:yandex_dance/features/friends/data/models/friend_coach_model.dart';

/// Локальные мок-данные для экрана «Друзья» без Firestore.
class FriendsMockDataSource implements FriendsDataSource {
  FriendsMockDataSource();

  static final List<FriendCoachModel> _coaches = [
    FriendCoachModel(
      id: 'mock-anna',
      name: 'Анна Морозова',
      styles: ['Hip-Hop', 'Breaking'],
      description:
          'Сертифицированный преподаватель уличных стилей, участник баттлов.',
      rating: 4.9,
      avatarUrl: 'https://randomuser.me/api/portraits/women/65.jpg',
    ),
    FriendCoachModel(
      id: 'mock-dmitry',
      name: 'Дмитрий Волков',
      styles: ['House', 'Vogue'],
      description: 'Студия и онлайн: house, vogue, работа с пластикой.',
      rating: 4.7,
      avatarUrl: 'https://randomuser.me/api/portraits/men/32.jpg',
    ),
    FriendCoachModel(
      id: 'mock-elena',
      name: 'Елена Соколова',
      styles: ['Contemporary', 'Heels'],
      description: 'Современный танец и heels: от базы до постановок.',
      rating: 4.8,
      avatarUrl: 'https://randomuser.me/api/portraits/women/44.jpg',
    ),
    FriendCoachModel(
      id: 'mock-kirill',
      name: 'Кирилл Орлов',
      styles: ['Dancehall'],
      description: 'Dancehall и регги: энергия, ритм и изоляции.',
      rating: 4.6,
      avatarUrl: 'https://randomuser.me/api/portraits/men/75.jpg',
    ),
    FriendCoachModel(
      id: 'mock-maria',
      name: 'Мария Лебедева',
      styles: ['Hip-Hop', 'House', 'Breaking'],
      description: 'Группы для начинающих и продвинутых, подготовка к сцене.',
      rating: 5.0,
      avatarUrl: 'https://randomuser.me/api/portraits/women/68.jpg',
    ),
  ];

  @override
  Future<List<FriendCoachModel>> fetchCoaches() async {
    final copy = List<FriendCoachModel>.from(_coaches);
    copy.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return copy;
  }

  @override
  Future<FriendCoachModel?> getCoach(String id) async {
    try {
      return _coaches.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}
