import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_local_datasource.dart';
import '../models/product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductLocalDataSource localDataSource;
  
  ProductRepositoryImpl({
    required this.localDataSource,
  });
  
  @override
  Future<Either<Failure, List<Product>>> getProducts() async {
    try {
      final products = localDataSource.getProducts();
      return Right(products);
    } catch (e) {
      return Left(CacheFailure('Failed to get products: $e'));
    }
  }
  
  @override
  Future<Either<Failure, Product>> getProduct(String id) async {
    try {
      final product = localDataSource.getProduct(id);
      if (product != null) {
        return Right(product);
      } else {
        return const Left(CacheFailure('Product not found'));
      }
    } catch (e) {
      return Left(CacheFailure('Failed to get product: $e'));
    }
  }
  
  @override
  Future<Either<Failure, Product>> createProduct(Product product) async {
    try {
      final productModel = ProductModel.fromEntity(product);
      final createdProduct = await localDataSource.createProduct(
        name: productModel.name,
        barcode: productModel.barcode,
        price: productModel.price,
        stockQuantity: productModel.stockQuantity,
        imageUrl: productModel.imageUrl,
      );
      return Right(createdProduct);
    } catch (e) {
      return Left(CacheFailure('Failed to create product: $e'));
    }
  }
  
  @override
  Future<Either<Failure, Product>> updateProduct(Product product) async {
    try {
      final productModel = ProductModel.fromEntity(product);
      final success = await localDataSource.updateProduct(productModel);
      if (success) {
        return Right(product);
      } else {
        return const Left(CacheFailure('Failed to update product'));
      }
    } catch (e) {
      return Left(CacheFailure('Failed to update product: $e'));
    }
  }
  
  @override
  Future<Either<Failure, void>> deleteProduct(String id) async {
    try {
      final success = await localDataSource.deleteProduct(id);
      if (success) {
        return const Right(null);
      } else {
        return const Left(CacheFailure('Failed to delete product'));
      }
    } catch (e) {
      return Left(CacheFailure('Failed to delete product: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Product>>> searchProducts(String query) async {
    try {
      final products = localDataSource.searchProducts(query);
      return Right(products);
    } catch (e) {
      return Left(CacheFailure('Failed to search products: $e'));
    }
  }
} 