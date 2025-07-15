import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';

class GetProducts implements UseCaseNoParams<List<Product>> {
  final ProductRepository repository;
  
  GetProducts(this.repository);
  
  @override
  Future<Either<Failure, List<Product>>> call() async {
    return await repository.getProducts();
  }
} 