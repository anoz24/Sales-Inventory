import 'package:equatable/equatable.dart';
import '../../../domain/entities/cart_item.dart';
import '../../../domain/entities/product.dart';

abstract class SalesState extends Equatable {
  const SalesState();
  
  @override
  List<Object?> get props => [];
}

class SalesInitial extends SalesState {}

class SalesLoading extends SalesState {}

class SalesLoaded extends SalesState {
  final List<Product> products;
  final List<CartItem> cartItems;
  final Map<String, int> selectedQuantities;
  final List<Product> filteredProducts;
  
  const SalesLoaded({
    required this.products,
    required this.cartItems,
    required this.selectedQuantities,
    List<Product>? filteredProducts,
  }) : filteredProducts = filteredProducts ?? products;
  
  @override
  List<Object?> get props => [products, cartItems, selectedQuantities, filteredProducts];
  
  SalesLoaded copyWith({
    List<Product>? products,
    List<CartItem>? cartItems,
    Map<String, int>? selectedQuantities,
    List<Product>? filteredProducts,
  }) {
    return SalesLoaded(
      products: products ?? this.products,
      cartItems: cartItems ?? this.cartItems,
      selectedQuantities: selectedQuantities ?? this.selectedQuantities,
      filteredProducts: filteredProducts ?? this.filteredProducts,
    );
  }
  
  // Convenience getters
  double get subtotal => cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  double get tax => subtotal * 0.08; // 8% tax
  double get total => subtotal + tax;
}

class SalesError extends SalesState {
  final String message;
  
  const SalesError(this.message);
  
  @override
  List<Object?> get props => [message];
}

class CartItemAdded extends SalesState {
  final Product product;
  final int quantity;
  
  const CartItemAdded({
    required this.product,
    required this.quantity,
  });
  
  @override
  List<Object?> get props => [product, quantity];
}

class CartItemRemoved extends SalesState {
  final Product product;
  
  const CartItemRemoved(this.product);
  
  @override
  List<Object?> get props => [product];
}

class StockError extends SalesState {
  final Product product;
  final int requestedQuantity;
  final int availableStock;
  
  const StockError({
    required this.product,
    required this.requestedQuantity,
    required this.availableStock,
  });
  
  @override
  List<Object?> get props => [product, requestedQuantity, availableStock];
} 