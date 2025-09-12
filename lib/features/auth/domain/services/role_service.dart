import 'package:supabase_flutter/supabase_flutter.dart';
import '../entities/user.dart';
import '../../../books/domain/entities/book.dart';

class RoleService {
  final SupabaseClient _client;
  String? _cachedRole;
  String? _cachedUserId;

  RoleService({required SupabaseClient client}) : _client = client;

  /// Get current user's role with caching
  Future<UserRole?> getCurrentUserRole() async {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) return null;

    // Use cache if same user
    if (_cachedUserId == currentUser.id && _cachedRole != null) {
      return _parseUserRole(_cachedRole!);
    }

    try {
      final response = await _client
          .from('users')
          .select('role')
          .eq('id', currentUser.id)
          .single();

      _cachedRole = response['role'] as String?;
      _cachedUserId = currentUser.id;

      return _parseUserRole(_cachedRole ?? 'reader');
    } catch (e) {
      return UserRole.reader;
    }
  }

  /// Get user role by ID
  Future<UserRole?> getUserRole(String userId) async {
    try {
      final response = await _client
          .from('users')
          .select('role')
          .eq('id', userId)
          .single();

      return _parseUserRole(response['role'] as String? ?? 'reader');
    } catch (e) {
      return UserRole.reader;
    }
  }

  /// Clear role cache (call when user changes or signs out)
  void clearCache() {
    _cachedRole = null;
    _cachedUserId = null;
  }

  /// Permission checks
  Future<bool> canCreateBooks() async {
    final role = await getCurrentUserRole();
    return role?.canCreateBooks ?? false;
  }

  Future<bool> canPublishBooks() async {
    final role = await getCurrentUserRole();
    return role?.canPublishBooks ?? false;
  }

  Future<bool> canManageUsers() async {
    final role = await getCurrentUserRole();
    return role?.canManageUsers ?? false;
  }

  Future<bool> canViewDrafts() async {
    final role = await getCurrentUserRole();
    return role?.canViewDrafts ?? false;
  }

  /// Check if current user is author of a book
  bool isBookAuthor(String bookAuthorId) {
    final currentUser = _client.auth.currentUser;
    return currentUser?.id == bookAuthorId;
  }

  /// Check if current user can edit a book
  Future<bool> canEditBook(String bookAuthorId) async {
    final role = await getCurrentUserRole();
    return isBookAuthor(bookAuthorId) || role == UserRole.admin;
  }

  /// Check if current user can delete a book
  Future<bool> canDeleteBook(String bookAuthorId) async {
    final role = await getCurrentUserRole();
    return isBookAuthor(bookAuthorId) || role == UserRole.admin;
  }

  /// Check if current user can change book status
  Future<bool> canChangeBookStatus(String bookAuthorId) async {
    final role = await getCurrentUserRole();
    return isBookAuthor(bookAuthorId) ||
        role == UserRole.publisher ||
        role == UserRole.admin;
  }

  /// Get available status changes for a book
  Future<List<BookStatus>> getAvailableStatusChanges(
    BookStatus currentStatus,
    String bookAuthorId,
  ) async {
    final role = await getCurrentUserRole();
    final isAuthor = isBookAuthor(bookAuthorId);
    final isAdmin = role == UserRole.admin;
    final isPublisher = role == UserRole.publisher;

    final availableStatuses = <BookStatus>[];

    // Authors can change between draft and completed
    if (isAuthor || isAdmin) {
      if (currentStatus != BookStatus.draft) {
        availableStatuses.add(BookStatus.draft);
      }
      if (currentStatus != BookStatus.completed) {
        availableStatuses.add(BookStatus.completed);
      }
    }

    // Publishers and admins can publish/unpublish
    if (isPublisher || isAdmin) {
      if (currentStatus != BookStatus.published) {
        availableStatuses.add(BookStatus.published);
      } else {
        availableStatuses.add(BookStatus.completed);
      }
    }

    return availableStatuses;
  }

  UserRole _parseUserRole(String roleString) {
    switch (roleString.toLowerCase()) {
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
}
