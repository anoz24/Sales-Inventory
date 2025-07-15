import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../core/usecases/usecase.dart';
import '../repositories/product_repository.dart';

class DeleteProduct implements UseCase<void, DeleteProductParams> {
  final ProductRepository repository;
  
  DeleteProduct(this.repository);
  
  @override
  Future<Either<Failure, void>> call(DeleteProductParams params) async {
    return await repository.deleteProduct(params.productId);
  }
}

class DeleteProductParams {
  final String productId;
  
  DeleteProductParams({required this.productId});
} 