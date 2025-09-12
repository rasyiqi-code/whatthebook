import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../models/user_model.dart';
import '../../../../core/services/logger_service.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  });

  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
  });

  Future<UserModel> signInWithGoogle();

  Future<void> signOut();

  Future<UserModel?> getCurrentUser();

  Future<UserModel> updateUserProfile({
    required String userId,
    String? fullName,
    String? username,
    String? bio,
    String? avatarUrl,
    String? contact,
  });

  Future<UserModel> getUserById(String userId);

  Future<List<UserModel>> searchUsers(String query);

  Stream<UserModel?> get authStateChanges;

  Future<bool> isFollowing(String userId);

  Future<void> toggleFollowUser({
    required String userId,
    required bool shouldFollow,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final supabase.SupabaseClient client;

  AuthRemoteDataSourceImpl({required this.client});

  @override
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      logger.info(
        'AuthRemoteDataSource - Attempting email sign in for: $email',
      );
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Sign in failed - no user returned');
      }

      logger.info(
        'AuthRemoteDataSource - Sign in successful, fetching user profile...',
      );
      // Get user profile from users table with computed fields
      final userProfile = await client
          .from('users')
          .select('*, followers_count, following_count, books_count')
          .eq('id', response.user!.id)
          .single();

      logger.info('AuthRemoteDataSource - User profile fetched successfully');
      return UserModel.fromSupabase(userProfile);
    } catch (e) {
      logger.error('AuthRemoteDataSource - Sign in error', e);
      throw Exception('Failed to sign in: $e');
    }
  }

  @override
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      logger.info(
        'AuthRemoteDataSource - Attempting email sign up for: $email',
      );
      final response = await client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );

      if (response.user == null) {
        throw Exception('Sign up failed - no user returned');
      }

      logger.info(
        'AuthRemoteDataSource - Sign up successful, waiting for profile creation...',
      );
      // The user profile should be automatically created by the trigger
      // Wait a bit and then fetch the profile
      await Future.delayed(const Duration(milliseconds: 500));

      logger.info('AuthRemoteDataSource - Fetching created user profile...');
      final userProfile = await client
          .from('users')
          .select('*, followers_count, following_count, books_count')
          .eq('id', response.user!.id)
          .single();

      logger.info('AuthRemoteDataSource - User profile fetched successfully');
      return UserModel.fromSupabase(userProfile);
    } catch (e) {
      logger.error('AuthRemoteDataSource - Sign up error', e);
      throw Exception('Failed to sign up: $e');
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      logger.info('AuthRemoteDataSource - Attempting Google sign in...');
      final response = await client.auth.signInWithOAuth(
        supabase.OAuthProvider.google,
      );

      if (response == false) {
        throw Exception('Google sign in failed - OAuth response was false');
      }

      logger.info(
        'AuthRemoteDataSource - Google sign in successful, waiting for auth state...',
      );
      // Wait for auth state to update
      await Future.delayed(const Duration(seconds: 1));

      final user = client.auth.currentUser;
      if (user == null) {
        throw Exception('No user after Google sign in');
      }

      logger.info(
        'AuthRemoteDataSource - Fetching user profile after Google sign in...',
      );
      // Get user profile from users table with computed fields
      final userProfile = await client
          .from('users')
          .select('*, followers_count, following_count, books_count')
          .eq('id', user.id)
          .single();

      logger.info('AuthRemoteDataSource - User profile fetched successfully');
      return UserModel.fromSupabase(userProfile);
    } catch (e) {
      logger.error('AuthRemoteDataSource - Google sign in error', e);
      throw Exception('Failed to sign in with Google: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      logger.info('AuthRemoteDataSource - Signing out...');
      await client.auth.signOut();
      logger.info('AuthRemoteDataSource - Sign out successful');
    } catch (e) {
      logger.error('AuthRemoteDataSource - Sign out error', e);
      throw Exception('Failed to sign out: $e');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      logger.debug('AuthRemoteDataSource - Getting current user...');
      final user = client.auth.currentUser;
      if (user == null) {
        logger.debug('AuthRemoteDataSource - No current user found');
        return null;
      }

      logger.debug('AuthRemoteDataSource - Fetching current user profile...');
      final userProfile = await client
          .from('users')
          .select('*, followers_count, following_count, books_count')
          .eq('id', user.id)
          .single();

      logger.debug(
        'AuthRemoteDataSource - Current user profile fetched successfully',
      );
      return UserModel.fromSupabase(userProfile);
    } catch (e) {
      logger.error('AuthRemoteDataSource - Get current user error', e);
      return null;
    }
  }

  @override
  Future<UserModel> updateUserProfile({
    required String userId,
    String? fullName,
    String? username,
    String? bio,
    String? avatarUrl,
    String? contact,
  }) async {
    try {
      logger.info('AuthRemoteDataSource - Updating user profile for: $userId');
      final updateData = <String, dynamic>{};
      if (fullName != null) updateData['full_name'] = fullName;
      if (username != null) updateData['username'] = username;
      if (bio != null) updateData['bio'] = bio;
      if (avatarUrl != null) updateData['avatar_url'] = avatarUrl;
      if (contact != null) updateData['contact'] = contact;

      logger.debug('AuthRemoteDataSource - Update data: $updateData');
      final response = await client
          .from('users')
          .update(updateData)
          .eq('id', userId)
          .select('*, followers_count, following_count, books_count')
          .single();

      logger.info('AuthRemoteDataSource - Profile updated successfully');
      return UserModel.fromSupabase(response);
    } catch (e) {
      logger.error('AuthRemoteDataSource - Update profile error', e);
      throw Exception('Failed to update user profile: $e');
    }
  }

  @override
  Future<UserModel> getUserById(String userId) async {
    try {
      logger.debug('AuthRemoteDataSource - Getting user by ID: $userId');
      final response = await client
          .from('users')
          .select('*, followers_count, following_count, books_count')
          .eq('id', userId)
          .single();

      logger.debug('AuthRemoteDataSource - User fetched successfully');
      return UserModel.fromSupabase(response);
    } catch (e) {
      logger.error('AuthRemoteDataSource - Get user by ID error', e);
      throw Exception('Failed to get user: $e');
    }
  }

  @override
  Future<List<UserModel>> searchUsers(String query) async {
    try {
      logger.debug('AuthRemoteDataSource - Searching users with query: $query');
      final response = await client
          .from('users')
          .select('*, followers_count, following_count, books_count')
          .or('full_name.ilike.%$query%,username.ilike.%$query%')
          .limit(20);

      logger.debug(
        'AuthRemoteDataSource - Search successful, found ${response.length} users',
      );
      return response.map((user) => UserModel.fromSupabase(user)).toList();
    } catch (e) {
      logger.error('AuthRemoteDataSource - Search users error', e);
      throw Exception('Failed to search users: $e');
    }
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return client.auth.onAuthStateChange.asyncMap((authState) async {
      final user = authState.session?.user;
      if (user == null) {
        logger.debug('AuthRemoteDataSource - Auth state changed: No user');
        return null;
      }

      try {
        logger.debug(
          'AuthRemoteDataSource - Auth state changed: Fetching user profile',
        );
        final userProfile = await client
            .from('users')
            .select('*, followers_count, following_count, books_count')
            .eq('id', user.id)
            .single();

        logger.debug(
          'AuthRemoteDataSource - Auth state user profile fetched successfully',
        );
        return UserModel.fromSupabase(userProfile);
      } catch (e) {
        logger.error(
          'AuthRemoteDataSource - Auth state user profile fetch error',
          e,
        );
        return null;
      }
    });
  }

  @override
  Future<bool> isFollowing(String userId) async {
    try {
      logger.debug(
        'AuthRemoteDataSource - Checking following status for user: $userId',
      );
      final currentUser = client.auth.currentUser;
      if (currentUser == null) {
        logger.warning('AuthRemoteDataSource - Not authenticated');
        throw Exception('Not authenticated');
      }

      final response = await client
          .from('follows')
          .select()
          .eq('follower_id', currentUser.id)
          .eq('following_id', userId)
          .maybeSingle();

      final isFollowing = response != null;
      logger.debug('AuthRemoteDataSource - Following status: $isFollowing');
      return isFollowing;
    } catch (e) {
      logger.error('AuthRemoteDataSource - Check following status error', e);
      throw Exception('Failed to check following status: $e');
    }
  }

  @override
  Future<void> toggleFollowUser({
    required String userId,
    required bool shouldFollow,
  }) async {
    try {
      logger.info(
        'AuthRemoteDataSource - Toggling follow status: shouldFollow=$shouldFollow for user: $userId',
      );
      final currentUser = client.auth.currentUser;
      if (currentUser == null) {
        logger.warning('AuthRemoteDataSource - Not authenticated');
        throw Exception('Not authenticated');
      }

      if (shouldFollow) {
        logger.info('AuthRemoteDataSource - Following user...');
        // Follow user
        await client.from('follows').insert({
          'follower_id': currentUser.id,
          'following_id': userId,
        });
      } else {
        logger.info('AuthRemoteDataSource - Unfollowing user...');
        // Unfollow user
        await client
            .from('follows')
            .delete()
            .eq('follower_id', currentUser.id)
            .eq('following_id', userId);
      }
      logger.info('AuthRemoteDataSource - Toggle follow successful');
    } catch (e) {
      logger.error('AuthRemoteDataSource - Toggle follow error', e);
      throw Exception('Failed to toggle follow: $e');
    }
  }
}
