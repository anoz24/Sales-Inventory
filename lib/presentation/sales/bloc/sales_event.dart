import 'package:equatable/equatable.dart';
import '../../../domain/entities/cart_item.dart';
import '../../../domain/entities/product.dart';

abstract class SalesEvent extends Equatable {
  const SalesEvent();
  
  @override
  List<Object?> get props => [];
}

class LoadProductsEvent extends SalesEvent {}

class SearchProductsEvent extends SalesEvent {
  final String query;
  
  const SearchProductsEvent(this.query);
  
  @override
  List<Object?> get props => [query];
}

class AddToCartEvent extends SalesEvent {
  final Product product;
  final int quantity;
  
  const AddToCartEvent({
    required this.product,
    required this.quantity,
  });
  
  @override
  List<Object?> get props => [product, quantity];
}

class UpdateCartQuantityEvent extends SalesEvent {
  final int cartIndex;
  final int newQuantity;
  
  const UpdateCartQuantityEvent({
    required this.cartIndex,
    required this.newQuantity,
  });
  
  @override
  List<Object?> get props => [cartIndex, newQuantity];
}

class RemoveFromCartEvent extends SalesEvent {
  final int cartIndex;
  
  const RemoveFromCartEvent(this.cartIndex);
  
  @override
  List<Object?> get props => [cartIndex];
}

class ClearCartEvent extends SalesEvent {}

class UpdateSelectedQuantityEvent extends SalesEvent {
  final String productId;
  final int quantity;
  
  const UpdateSelectedQuantityEvent({
    required this.productId,
    required this.quantity,
  });
  
  @override
  List<Object?> get props => [productId, quantity];
} 