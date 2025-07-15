part of 'add_product_bloc.dart';

abstract class AddProductState extends Equatable {
  const AddProductState();
  
  @override
  List<Object> get props => [];
}

class AddProductInitial extends AddProductState {}

class AddProductLoading extends AddProductState {}

class AddProductSuccess extends AddProductState {
  final Product product;
  
  const AddProductSuccess(this.product);
  
  @override
  List<Object> get props => [product];
}

class AddProductError extends AddProductState {
  final String message;
  
  const AddProductError(this.message);
  
  @override
  List<Object> get props => [message];
} 