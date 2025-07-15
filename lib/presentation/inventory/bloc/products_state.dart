import 'package:equatable/equatable.dart';
import '../../../domain/entities/product.dart';

abstract class ProductsState extends Equatable {
  const ProductsState();
  
  @override
  List<Object> get props => [];
}

class ProductsInitial extends ProductsState {}

class ProductsLoading extends ProductsState {}

class ProductsLoaded extends ProductsState {
  final List<Product> products;
  final bool isSearchResult;
  final String searchQuery;
  
  const ProductsLoaded(
    this.products, {
    this.isSearchResult = false,
    this.searchQuery = '',
  });
  
  @override
  List<Object> get props => [products, isSearchResult, searchQuery];
}

class ProductsError extends ProductsState {
  final String message;
  
  const ProductsError(this.message);
  
  @override
  List<Object> get props => [message];
}

class ProductUpdateSuccess extends ProductsState {
  final Product product;
  
  const ProductUpdateSuccess(this.product);
  
  @override
  List<Object> get props => [product];
}

class ProductDeleteSuccess extends ProductsState {
  final String productId;
  
  const ProductDeleteSuccess(this.productId);
  
  @override
  List<Object> get props => [productId];
}

class ProductOperationError extends ProductsState {
  final String message;
  
  const ProductOperationError(this.message);
  
  @override
  List<Object> get props => [message];
} 