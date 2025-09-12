import '../../domain/entities/follow.dart';

class FollowModel extends Follow {
  const FollowModel({
    required super.id,
    required super.followerId,
    required super.followingId,
    required super.createdAt,
  });

  factory FollowModel.fromSupabase(Map<String, dynamic> map) {
    return FollowModel(
      id: map['id'] as String,
      followerId: map['follower_id'] as String,
      followingId: map['following_id'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toSupabase() {
    return {
      'id': id,
      'follower_id': followerId,
      'following_id': followingId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory FollowModel.fromEntity(Follow follow) {
    return FollowModel(
      id: follow.id,
      followerId: follow.followerId,
      followingId: follow.followingId,
      createdAt: follow.createdAt,
    );
  }

  Follow toEntity() {
    return Follow(
      id: id,
      followerId: followerId,
      followingId: followingId,
      createdAt: createdAt,
    );
  }
}
