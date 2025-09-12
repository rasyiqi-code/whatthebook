import '../../../auth/domain/entities/user.dart';

UserRole _parseUserRole(String? roleString) {
  switch (roleString?.toLowerCase()) {
    case 'admin':
      return UserRole.admin;
    case 'author':
      return UserRole.author;
    case 'publisher':
      return UserRole.publisher;
    case 'reader':
    default:
      return UserRole.reader;
  }
}

String _userRoleToString(UserRole role) {
  switch (role) {
    case UserRole.admin:
      return 'admin';
    case UserRole.author:
      return 'author';
    case UserRole.publisher:
      return 'publisher';
    case UserRole.reader:
      return 'reader';
  }
}

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    super.fullName,
    super.username,
    super.bio,
    super.avatarUrl,
    super.contact,
    required super.role,
    required super.followersCount,
    required super.followingCount,
    required super.booksCount,
    required super.createdAt,
    required super.updatedAt,
  });

  factory UserModel.fromSupabase(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      email: map['email'] as String,
      fullName: map['full_name'] as String?,
      username: map['username'] as String?,
      bio: map['bio'] as String?,
      avatarUrl: map['avatar_url'] as String?,
      contact: map['contact'] as String?,
      role: _parseUserRole(map['role'] as String?),
      followersCount: map['followers_count'] as int? ?? 0,
      followingCount: map['following_count'] as int? ?? 0,
      booksCount: map['books_count'] as int? ?? 0,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toSupabase() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'username': username,
      'bio': bio,
      'avatar_url': avatarUrl,
      'contact': contact,
      'role': _userRoleToString(role),
      'followers_count': followersCount,
      'following_count': followingCount,
      'books_count': booksCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      fullName: user.fullName,
      username: user.username,
      bio: user.bio,
      avatarUrl: user.avatarUrl,
      contact: user.contact,
      role: user.role,
      followersCount: user.followersCount,
      followingCount: user.followingCount,
      booksCount: user.booksCount,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    );
  }

  User toEntity() {
    return User(
      id: id,
      email: email,
      fullName: fullName,
      username: username,
      bio: bio,
      avatarUrl: avatarUrl,
      contact: contact,
      role: role,
      followersCount: followersCount,
      followingCount: followingCount,
      booksCount: booksCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
