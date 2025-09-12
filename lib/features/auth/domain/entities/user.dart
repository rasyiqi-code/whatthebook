import 'package:equatable/equatable.dart';

enum UserRole {
  reader,
  author,
  publisher,
  admin;

  String get displayName {
    switch (this) {
      case UserRole.reader:
        return 'Reader';
      case UserRole.author:
        return 'Author';
      case UserRole.publisher:
        return 'Publisher';
      case UserRole.admin:
        return 'Admin';
    }
  }

  bool get canCreateBooks => this == UserRole.author || this == UserRole.admin;
  bool get canPublishBooks =>
      this == UserRole.publisher || this == UserRole.admin;
  bool get canManageUsers => this == UserRole.admin;
  bool get canViewDrafts =>
      this == UserRole.author ||
      this == UserRole.publisher ||
      this == UserRole.admin;
}

class User extends Equatable {
  final String id;
  final String email;
  final String? fullName;
  final String? username;
  final String? bio;
  final String? avatarUrl;
  final String? contact;
  final UserRole role;
  final int followersCount;
  final int followingCount;
  final int booksCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.email,
    this.fullName,
    this.username,
    this.bio,
    this.avatarUrl,
    this.contact,
    required this.role,
    required this.followersCount,
    required this.followingCount,
    required this.booksCount,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    email,
    fullName,
    username,
    bio,
    avatarUrl,
    contact,
    role,
    followersCount,
    followingCount,
    booksCount,
    createdAt,
    updatedAt,
  ];

  User copyWith({
    String? id,
    String? email,
    String? fullName,
    String? username,
    String? bio,
    String? avatarUrl,
    String? contact,
    UserRole? role,
    int? followersCount,
    int? followingCount,
    int? booksCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      contact: contact ?? this.contact,
      role: role ?? this.role,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      booksCount: booksCount ?? this.booksCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
