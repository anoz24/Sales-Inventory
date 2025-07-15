import 'package:dartz/dartz.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../../core/errors/failures.dart';
import '../datasources/user_local_datasource.dart';

class UserRepositoryImpl implements UserRepository {
  final UserLocalDataSource localDataSource;

  UserRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<User>>> getUsers() async {
    try {
      final users = localDataSource.getUsers();
      return Right(users);
    } catch (e) {
      return Left(CacheFailure('Failed to get users: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User?>> getUser(String id) async {
    try {
      final user = localDataSource.getUser(id);
      return Right(user);
    } catch (e) {
      return Left(CacheFailure('Failed to get user: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User>> createUser({
    required String name,
    required UserRole role,
    bool requiresPassword = false,
    String? password,
    String? avatarUrl,
  }) async {
    try {
      final user = await localDataSource.createUser(
        name: name,
        role: role,
        requiresPassword: requiresPassword,
        password: password,
        avatarUrl: avatarUrl,
      );
      return Right(user);
    } catch (e) {
      return Left(CacheFailure('Failed to create user: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> updateUser(User user) async {
    try {
      final success = await localDataSource.updateUser(user);
      return Right(success);
    } catch (e) {
      return Left(CacheFailure('Failed to update user: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteUser(String id) async {
    try {
      final success = await localDataSource.deleteUser(id);
      return Right(success);
    } catch (e) {
      return Left(CacheFailure('Failed to delete user: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<User>>> searchUsers(String query) async {
    try {
      final users = localDataSource.searchUsers(query);
      return Right(users);
    } catch (e) {
      return Left(CacheFailure('Failed to search users: ${e.toString()}'));
    }
  }
} 