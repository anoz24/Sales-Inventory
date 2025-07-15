import 'package:dartz/dartz.dart';
import '../entities/user.dart';
import '../repositories/user_repository.dart';
import '../../core/usecases/usecase.dart';
import '../../core/errors/failures.dart';

class CreateUser implements UseCase<User, CreateUserParams> {
  final UserRepository repository;

  CreateUser(this.repository);

  @override
  Future<Either<Failure, User>> call(CreateUserParams params) async {
    return await repository.createUser(
      name: params.name,
      role: params.role,
      requiresPassword: params.requiresPassword,
      password: params.password,
      avatarUrl: params.avatarUrl,
    );
  }
}

class CreateUserParams {
  final String name;
  final UserRole role;
  final bool requiresPassword;
  final String? password;
  final String? avatarUrl;

  CreateUserParams({
    required this.name,
    required this.role,
    this.requiresPassword = false,
    this.password,
    this.avatarUrl,
  });
} 