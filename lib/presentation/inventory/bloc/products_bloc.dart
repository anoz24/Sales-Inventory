import 'package:bloc/bloc.dart';
import '../../../domain/usecases/get_products.dart';
import '../../../domain/usecases/search_products.dart';
import '../../../domain/usecases/update_product.dart';
import '../../../domain/usecases/delete_product.dart';
import 'products_event.dart';
import 'products_state.dart';

class ProductsBloc extends Bloc<ProductsEvent, ProductsState> {
  final GetProducts getProducts;
  final SearchProducts searchProducts;
  final UpdateProduct updateProduct;
  final DeleteProduct deleteProduct;
  
  ProductsBloc({
    required this.getProducts,
    required this.searchProducts,
    required this.updateProduct,
    required this.deleteProduct,
  }) : super(ProductsInitial()) {
    on<GetProductsEvent>(_onGetProducts);
    on<SearchProductsEvent>(_onSearchProducts);
    on<UpdateProductEvent>(_onUpdateProduct);
    on<DeleteProductEvent>(_onDeleteProduct);
  }
  
  Future<void> _onGetProducts(
    GetProductsEvent event,
    Emitter<ProductsState> emit,
  ) async {
    emit(ProductsLoading());
    
    final result = await getProducts();
    
    result.fold(
      (failure) => emit(ProductsError(failure.message)),
      (products) => emit(ProductsLoaded(products)),
    );
  }
  
  Future<void> _onSearchProducts(
    SearchProductsEvent event,
    Emitter<ProductsState> emit,
  ) async {
    emit(ProductsLoading());
    
    final result = await searchProducts(SearchProductsParams(query: event.query));
    
    result.fold(
      (failure) => emit(ProductsError(failure.message)),
      (products) => emit(ProductsLoaded(
        products,
        isSearchResult: true,
        searchQuery: event.query,
      )),
    );
  }
  
  Future<void> _onUpdateProduct(
    UpdateProductEvent event,
    Emitter<ProductsState> emit,
  ) async {
    final result = await updateProduct(UpdateProductParams(product: event.product));
    
    result.fold(
      (failure) => emit(ProductOperationError(failure.message)),
      (product) {
        emit(ProductUpdateSuccess(product));
        // Refresh the products list
        add(GetProductsEvent());
      },
    );
  }
  
  Future<void> _onDeleteProduct(
    DeleteProductEvent event,
    Emitter<ProductsState> emit,
  ) async {
    final result = await deleteProduct(DeleteProductParams(productId: event.productId));
    
    result.fold(
      (failure) => emit(ProductOperationError(failure.message)),
      (_) {
        emit(ProductDeleteSuccess(event.productId));
        // Refresh the products list
        add(GetProductsEvent());
      },
    );
  }
} 