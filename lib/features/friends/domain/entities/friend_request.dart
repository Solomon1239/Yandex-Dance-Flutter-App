import 'package:equatable/equatable.dart';

enum FriendRequestStatus { pending, accepted, rejected }

class FriendRequest extends Equatable {
  const FriendRequest({
    required this.id,
    required this.fromUid,
    required this.toUid,
    required this.status,
    this.createdAt,
  });

  final String id;
  final String fromUid;
  final String toUid;
  final FriendRequestStatus status;
  final DateTime? createdAt;

  @override
  List<Object?> get props => [id, fromUid, toUid, status, createdAt];
}
