import 'package:equatable/equatable.dart';

class Follow extends Equatable {
  final String id;
  final String followerId;
  final String followingId;
  final DateTime createdAt;

  const Follow({
    required this.id,
    required this.followerId,
    required this.followingId,
    required this.createdAt,
  });

  @override
  List<Object> get props => [id, followerId, followingId, createdAt];

  Follow copyWith({
    String? id,
    String? followerId,
    String? followingId,
    DateTime? createdAt,
  }) {
    return Follow(
      id: id ?? this.id,
      followerId: followerId ?? this.followerId,
      followingId: followingId ?? this.followingId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
