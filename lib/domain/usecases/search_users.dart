import 'package:dartz/dartz.dart';
import '../entities/user.dart';
import '../repositories/user_repository.dart';
import '../../core/usecases/usecase.dart';
import '../../core/errors/failures.dart';

class SearchUsers implements UseCase<List<User>, SearchUsersParams> {
  final UserRepository repository;

  SearchUsers(this.repository);

  @override
  Future<Either<Failure, List<User>>> call(SearchUsersParams params) async {
    return await repository.searchUsers(params.query);
  }
}

class SearchUsersParams {
  final String query;

  SearchUsersParams({required this.query});
} 