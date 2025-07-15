import 'package:dartz/dartz.dart';
import '../entities/user.dart';
import '../../core/errors/failures.dart';

abstract class UserRepository {
  Future<Either<Failure, List<User>>> getUsers();
  Future<Either<Failure, User?>> getUser(String id);
  Future<Either<Failure, User>> createUser({
    required String name,
    required UserRole role,
    bool requiresPassword = false,
    String? password,
    String? avatarUrl,
  });
  Future<Either<Failure, bool>> updateUser(User user);
  Future<Either<Failure, bool>> deleteUser(String id);
  Future<Either<Failure, List<User>>> searchUsers(String query);
} 