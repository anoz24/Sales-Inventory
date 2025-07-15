import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';

class CreateProduct implements UseCase<Product, CreateProductParams> {
  final ProductRepository repository;
  
  CreateProduct(this.repository);
  
  @override
  Future<Either<Failure, Product>> call(CreateProductParams params) async {
    return await repository.createProduct(params.product);
  }
}

class CreateProductParams {
  final Product product;
  
  CreateProductParams({required this.product});
} 