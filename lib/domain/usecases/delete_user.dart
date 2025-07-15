import 'package:dartz/dartz.dart';
import '../repositories/user_repository.dart';
import '../../core/usecases/usecase.dart';
import '../../core/errors/failures.dart';

class DeleteUser implements UseCase<bool, DeleteUserParams> {
  final UserRepository repository;

  DeleteUser(this.repository);

  @override
  Future<Either<Failure, bool>> call(DeleteUserParams params) async {
    return await repository.deleteUser(params.id);
  }
}

class DeleteUserParams {
  final String id;

  DeleteUserParams({required this.id});
} 