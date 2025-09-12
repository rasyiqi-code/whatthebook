import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> signInWithEmail({
    required String email,
    required String password,
  });

  Future<Either<Failure, User>> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
  });

  Future<Either<Failure, User>> signInWithGoogle();

  Future<Either<Failure, void>> signOut();

  Future<Either<Failure, User?>> getCurrentUser();

  Future<Either<Failure, User>> updateUserProfile({
    required String userId,
    String? fullName,
    String? username,
    String? bio,
    String? avatarUrl,
    String? contact,
  });

  Future<Either<Failure, User>> getUserById(String userId);

  Future<Either<Failure, List<User>>> searchUsers(String query);

  Future<Either<Failure, bool>> isFollowing(String userId);

  Future<Either<Failure, void>> toggleFollowUser({
    required String userId,
    required bool shouldFollow,
  });

  Stream<User?> get authStateChanges;
}
