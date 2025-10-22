import 'package:bloc/bloc.dart';
import '../../../domain/entities/cart_item.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/usecases/get_products.dart';
import '../../../domain/usecases/search_products.dart';
import 'sales_event.dart';
import 'sales_state.dart';

class SalesBloc extends Bloc<SalesEvent, SalesState> {
  final GetProducts getProducts;
  final SearchProducts searchProducts;
  
  // Internal state management
  List<Product> _allProducts = [];
  List<CartItem> _cartItems = [];
  Map<String, int> _selectedQuantities = {};
  
  SalesBloc({
    required this.getProducts,
    required this.searchProducts,
  }) : super(SalesInitial()) {
    on<LoadProductsEvent>(_onLoadProducts);
    on<SearchProductsEvent>(_onSearchProducts);
    on<AddToCartEvent>(_onAddToCart);
    on<UpdateCartQuantityEvent>(_onUpdateCartQuantity);
    on<RemoveFromCartEvent>(_onRemoveFromCart);
    on<ClearCartEvent>(_onClearCart);
    on<UpdateSelectedQuantityEvent>(_onUpdateSelectedQuantity);
  }
  
  Future<void> _onLoadProducts(LoadProductsEvent event, Emitter<SalesState> emit) async {
    emit(SalesLoading());
    
    final result = await getProducts();
    
    result.fold(
      (failure) => emit(SalesError(failure.message)),
      (products) {
        _allProducts = products;
        // Always emit fresh copies to ensure proper state updates
        emit(SalesLoaded(
          products: List.from(_allProducts),
          cartItems: List.from(_cartItems),
          selectedQuantities: Map.from(_selectedQuantities),
        ));
      },
    );
  }
  
  Future<void> _onSearchProducts(SearchProductsEvent event, Emitter<SalesState> emit) async {
    if (event.query.trim().isEmpty) {
      // Show all products if search is empty
      emit(SalesLoaded(
        products: List.from(_allProducts),
        cartItems: List.from(_cartItems),
        selectedQuantities: Map.from(_selectedQuantities),
        filteredProducts: List.from(_allProducts),
      ));
      return;
    }
    
    final result = await searchProducts(SearchProductsParams(query: event.query));
    
    result.fold(
      (failure) => emit(SalesError(failure.message)),
      (filteredProducts) {
        emit(SalesLoaded(
          products: List.from(_allProducts),
          cartItems: List.from(_cartItems),
          selectedQuantities: Map.from(_selectedQuantities),
          filteredProducts: List.from(filteredProducts),
        ));
      },
    );
  }
  
  Future<void> _onAddToCart(AddToCartEvent event, Emitter<SalesState> emit) async {
    final product = event.product;
    final quantity = event.quantity;
    
    // Check if product already exists in cart
    final existingIndex = _cartItems.indexWhere((item) => item.product.id == product.id);
    
    if (existingIndex != -1) {
      // Update existing item
      final existingItem = _cartItems[existingIndex];
      final newQuantity = existingItem.quantity + quantity;
      
      // Validate stock
      if (newQuantity > product.stockQuantity) {
        // Remove the existing item instead of showing error
        _cartItems.removeAt(existingIndex);
        
        emit(StockError(
          product: product,
          requestedQuantity: newQuantity,
          availableStock: product.stockQuantity,
        ));
        
        // Still emit the updated loaded state
        emit(SalesLoaded(
          products: List.from(_allProducts),
          cartItems: List.from(_cartItems),
          selectedQuantities: Map.from(_selectedQuantities),
        ));
        return;
      }
      
      _cartItems[existingIndex] = existingItem.copyWith(quantity: newQuantity);
    } else {
      // Add new item
      if (quantity > product.stockQuantity) {
        emit(StockError(
          product: product,
          requestedQuantity: quantity,
          availableStock: product.stockQuantity,
        ));
        
        // Still emit the updated loaded state
        emit(SalesLoaded(
          products: List.from(_allProducts),
          cartItems: List.from(_cartItems),
          selectedQuantities: Map.from(_selectedQuantities),
        ));
        return;
      }
      
      _cartItems.add(CartItem(
        product: product,
        quantity: quantity,
        unitPrice: product.price,
      ));
    }
    
    // Reset selected quantity for this product
    _selectedQuantities.remove(product.id);
    
    // Emit success state
    emit(CartItemAdded(product: product, quantity: quantity));
    
    // Then emit the updated loaded state
    emit(SalesLoaded(
      products: List.from(_allProducts),
      cartItems: List.from(_cartItems),
      selectedQuantities: Map.from(_selectedQuantities),
    ));
  }
  
  Future<void> _onUpdateCartQuantity(UpdateCartQuantityEvent event, Emitter<SalesState> emit) async {
    if (event.cartIndex < 0 || event.cartIndex >= _cartItems.length) {
      emit(const SalesError('Invalid cart item index'));
      return;
    }
    
    final item = _cartItems[event.cartIndex];
    final newQuantity = event.newQuantity;
    
    if (newQuantity <= 0) {
      // Remove item if quantity is 0 or negative
      _cartItems.removeAt(event.cartIndex);
      emit(CartItemRemoved(item.product));
    } else {
      // Validate stock
      if (newQuantity > item.product.stockQuantity) {
        // Remove the item instead of showing old error
        _cartItems.removeAt(event.cartIndex);
        
        emit(StockError(
          product: item.product,
          requestedQuantity: newQuantity,
          availableStock: item.product.stockQuantity,
        ));
        
        // Always emit updated state
        emit(SalesLoaded(
          products: List.from(_allProducts),
          cartItems: List.from(_cartItems),
          selectedQuantities: Map.from(_selectedQuantities),
        ));
        return;
      }
      
      _cartItems[event.cartIndex] = item.copyWith(quantity: newQuantity);
    }
    
    // Emit updated state
    emit(SalesLoaded(
      products: List.from(_allProducts),
      cartItems: List.from(_cartItems),
      selectedQuantities: Map.from(_selectedQuantities),
    ));
  }
  
  Future<void> _onRemoveFromCart(RemoveFromCartEvent event, Emitter<SalesState> emit) async {
    if (event.cartIndex < 0 || event.cartIndex >= _cartItems.length) {
      emit(const SalesError('Invalid cart item index'));
      return;
    }
    
    final removedItem = _cartItems.removeAt(event.cartIndex);
    
    emit(CartItemRemoved(removedItem.product));
    
    // Emit updated state
    emit(SalesLoaded(
      products: List.from(_allProducts),
      cartItems: List.from(_cartItems),
      selectedQuantities: Map.from(_selectedQuantities),
    ));
  }
  
  Future<void> _onClearCart(ClearCartEvent event, Emitter<SalesState> emit) async {
    _cartItems.clear();
    _selectedQuantities.clear();
    
    emit(SalesLoaded(
      products: List.from(_allProducts),
      cartItems: List.from(_cartItems),
      selectedQuantities: Map.from(_selectedQuantities),
    ));
  }
  
  Future<void> _onUpdateSelectedQuantity(UpdateSelectedQuantityEvent event, Emitter<SalesState> emit) async {
    // Always ensure we have a valid state
    if (_allProducts.isEmpty) {
      return;
    }
    
    if (event.quantity <= 0) {
      _selectedQuantities.remove(event.productId);
    } else {
      _selectedQuantities[event.productId] = event.quantity;
    }
    
    // Always emit a fresh state to ensure UI updates
    emit(SalesLoaded(
      products: List.from(_allProducts),
      cartItems: List.from(_cartItems),
      selectedQuantities: Map.from(_selectedQuantities),
    ));
  }
  
  // Convenience getters
  List<CartItem> get cartItems => List.unmodifiable(_cartItems);
  Map<String, int> get selectedQuantities => Map.unmodifiable(_selectedQuantities);
  double get subtotal => _cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  double get tax => subtotal * 0.08;
  double get total => subtotal + tax;
} 