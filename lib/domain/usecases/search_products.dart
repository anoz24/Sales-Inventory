import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';

class SearchProducts implements UseCase<List<Product>, SearchProductsParams> {
  final ProductRepository repository;
  
  SearchProducts(this.repository);
  
  @override
  Future<Either<Failure, List<Product>>> call(SearchProductsParams params) async {
    return await repository.searchProducts(params.query);
  }
}

class SearchProductsParams {
  final String query;
  
  SearchProductsParams({required this.query});
} 