part of 'add_product_bloc.dart';

abstract class AddProductEvent extends Equatable {
  const AddProductEvent();
  
  @override
  List<Object> get props => [];
}

class AddProductSubmitted extends AddProductEvent {
  final Product product;
  
  const AddProductSubmitted(this.product);
  
  @override
  List<Object> get props => [product];
} 