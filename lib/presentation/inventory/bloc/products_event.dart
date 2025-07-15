import 'package:equatable/equatable.dart';
import '../../../domain/entities/product.dart';

abstract class ProductsEvent extends Equatable {
  const ProductsEvent();
  
  @override
  List<Object> get props => [];
}

class GetProductsEvent extends ProductsEvent {}

class SearchProductsEvent extends ProductsEvent {
  final String query;
  
  const SearchProductsEvent(this.query);
  
  @override
  List<Object> get props => [query];
}

class UpdateProductEvent extends ProductsEvent {
  final Product product;
  
  const UpdateProductEvent(this.product);
  
  @override
  List<Object> get props => [product];
}

class DeleteProductEvent extends ProductsEvent {
  final String productId;
  
  const DeleteProductEvent(this.productId);
  
  @override
  List<Object> get props => [productId];
} 