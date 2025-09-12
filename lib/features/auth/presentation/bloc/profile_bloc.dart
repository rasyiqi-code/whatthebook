import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/services/logger_service.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

// Events
abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadUserProfile extends ProfileEvent {
  final String userId;

  const LoadUserProfile(this.userId);

  @override
  List<Object?> get props => [userId];
}

class ToggleFollowUser extends ProfileEvent {
  final String userId;
  final bool currentlyFollowing;

  const ToggleFollowUser(this.userId, this.currentlyFollowing);

  @override
  List<Object?> get props => [userId, currentlyFollowing];
}

class UpdateUserProfile extends ProfileEvent {
  final String userId;
  final String? fullName;
  final String? username;
  final String? bio;
  final String? avatarUrl;
  final String? contact;

  const UpdateUserProfile({
    required this.userId,
    this.fullName,
    this.username,
    this.bio,
    this.avatarUrl,
    this.contact,
  });

  @override
  List<Object?> get props => [userId, fullName, username, bio, avatarUrl, contact];
}

// States
abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final User user;
  final bool isFollowing;

  const ProfileLoaded({required this.user, required this.isFollowing});

  @override
  List<Object?> get props => [user, isFollowing];
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}

class ProfileUpdateLoading extends ProfileState {}
class ProfileUpdateSuccess extends ProfileState {}
class ProfileUpdateError extends ProfileState {
  final String message;
  const ProfileUpdateError(this.message);
  @override
  List<Object?> get props => [message];
}

// Bloc
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final AuthRepository authRepository;

  ProfileBloc({required this.authRepository}) : super(ProfileInitial()) {
    on<LoadUserProfile>(_onLoadUserProfile);
    on<ToggleFollowUser>(_onToggleFollowUser);
    on<UpdateUserProfile>(_onUpdateUserProfile);
  }

  Future<void> _onLoadUserProfile(
    LoadUserProfile event,
    Emitter<ProfileState> emit,
  ) async {
    if (emit.isDone) return;

    logger.info('ProfileBloc - Loading profile for user: ${event.userId}');
    emit(ProfileLoading());

    try {
      // Get user data
      logger.debug('ProfileBloc - Calling getUserById...');
      final userResult = await authRepository.getUserById(event.userId);

      await userResult.fold(
        (failure) async {
          logger.error('ProfileBloc - getUserById failed', failure);
          if (!emit.isDone) {
            emit(ProfileError('Failed to load profile: ${failure.toString()}'));
          }
        },
        (user) async {
          logger.debug('ProfileBloc - getUserById success: ${user.fullName}');
          try {
            // Get following status - but don't fail if this fails
            bool isFollowing = false;
            logger.debug('ProfileBloc - Checking following status...');
            final followingResult = await authRepository.isFollowing(
              event.userId,
            );
            followingResult.fold(
              (failure) {
                // Log error but continue with default value
                logger.warning(
                  'ProfileBloc - Failed to get following status',
                  failure,
                );
                isFollowing = false;
              },
              (following) {
                logger.debug('ProfileBloc - Following status: $following');
                isFollowing = following;
              },
            );

            if (!emit.isDone) {
              logger.debug('ProfileBloc - Emitting ProfileLoaded');
              emit(ProfileLoaded(user: user, isFollowing: isFollowing));
            }
          } catch (e) {
            logger.error('ProfileBloc - Error in following check', e);
            // If following check fails, still show profile with default following status
            if (!emit.isDone) {
              emit(ProfileLoaded(user: user, isFollowing: false));
            }
          }
        },
      );
    } catch (e) {
      logger.error('ProfileBloc - Unexpected error', e);
      if (!emit.isDone) {
        emit(ProfileError('Unexpected error: ${e.toString()}'));
      }
    }
  }

  Future<void> _onToggleFollowUser(
    ToggleFollowUser event,
    Emitter<ProfileState> emit,
  ) async {
    if (emit.isDone) return;

    try {
      if (state is ProfileLoaded) {
        final currentState = state as ProfileLoaded;

        // Optimistically update UI
        if (!emit.isDone) {
          emit(
            ProfileLoaded(
              user: currentState.user,
              isFollowing: !event.currentlyFollowing,
            ),
          );
        }

        // Implement actual follow/unfollow in repository
        final result = await authRepository.toggleFollowUser(
          userId: event.userId,
          shouldFollow: !event.currentlyFollowing,
        );

        result.fold(
          (failure) {
            // Revert on failure
            if (!emit.isDone) {
              emit(
                ProfileLoaded(
                  user: currentState.user,
                  isFollowing: event.currentlyFollowing,
                ),
              );
              emit(
                ProfileError(
                  'Failed to update follow status: ${failure.toString()}',
                ),
              );
            }
          },
          (_) => null, // Keep optimistic update
        );
      }
    } catch (e) {
      if (!emit.isDone) {
        emit(ProfileError('Unexpected error: ${e.toString()}'));
      }
    }
  }

  Future<void> _onUpdateUserProfile(
    UpdateUserProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileUpdateLoading());
    final result = await authRepository.updateUserProfile(
      userId: event.userId,
      fullName: event.fullName,
      username: event.username,
      bio: event.bio,
      avatarUrl: event.avatarUrl,
      contact: event.contact,
    );
    result.fold(
      (failure) => emit(ProfileUpdateError(failure.toString())),
      (user) => emit(ProfileUpdateSuccess()),
    );
  }
}
