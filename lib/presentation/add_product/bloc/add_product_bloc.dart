import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/usecases/create_product.dart';

part 'add_product_event.dart';
part 'add_product_state.dart';

class AddProductBloc extends Bloc<AddProductEvent, AddProductState> {
  final CreateProduct createProduct;
  
  AddProductBloc({
    required this.createProduct,
  }) : super(AddProductInitial()) {
    on<AddProductSubmitted>(_onAddProductSubmitted);
  }
  
  Future<void> _onAddProductSubmitted(
    AddProductSubmitted event,
    Emitter<AddProductState> emit,
  ) async {
    emit(AddProductLoading());
    
    final result = await createProduct(
      CreateProductParams(product: event.product),
    );
    
    result.fold(
      (failure) => emit(AddProductError(failure.message)),
      (product) => emit(AddProductSuccess(product)),
    );
  }
} 