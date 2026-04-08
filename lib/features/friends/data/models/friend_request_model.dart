import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yandex_dance/features/friends/domain/entities/friend_request.dart';

class FriendRequestModel {
  const FriendRequestModel({
    required this.id,
    required this.fromUid,
    required this.toUid,
    required this.status,
    this.createdAt,
  });

  final String id;
  final String fromUid;
  final String toUid;
  final String status;
  final DateTime? createdAt;

  factory FriendRequestModel.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return FriendRequestModel(
      id: doc.id,
      fromUid: data['fromUid'] as String,
      toUid: data['toUid'] as String,
      status: data['status'] as String,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  FriendRequest toEntity() {
    return FriendRequest(
      id: id,
      fromUid: fromUid,
      toUid: toUid,
      status: _statusFromString(status),
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fromUid': fromUid,
      'toUid': toUid,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  static FriendRequestStatus _statusFromString(String value) => switch (value) {
        'accepted' => FriendRequestStatus.accepted,
        'rejected' => FriendRequestStatus.rejected,
        _ => FriendRequestStatus.pending,
      };
}
