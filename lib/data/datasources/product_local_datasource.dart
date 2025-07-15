import '../../core/services/hive_storage_service.dart';
import '../models/product_model.dart';

abstract class ProductLocalDataSource {
  List<ProductModel> getProducts();
  ProductModel? getProduct(String id);
  Future<ProductModel> createProduct({
    required String name,
    required String barcode,
    required double price,
    required int stockQuantity,
    String? imageUrl,
  });
  Future<bool> updateProduct(ProductModel product);
  Future<bool> deleteProduct(String id);
  List<ProductModel> searchProducts(String query);
}

class ProductLocalDataSourceImpl implements ProductLocalDataSource {
  final HiveStorageService hiveStorage;
  
  ProductLocalDataSourceImpl({required this.hiveStorage});
  
  @override
  List<ProductModel> getProducts() {
    final products = hiveStorage.getAllProducts();
    return products.map((product) => ProductModel.fromEntity(product)).toList();
  }
  
  @override
  ProductModel? getProduct(String id) {
    final product = hiveStorage.getProductById(id);
    return product != null ? ProductModel.fromEntity(product) : null;
  }
  
  @override
  Future<ProductModel> createProduct({
    required String name,
    required String barcode,
    required double price,
    required int stockQuantity,
    String? imageUrl,
  }) async {
    final product = await hiveStorage.addProduct(
      name: name,
      barcode: barcode,
      price: price,
      stockQuantity: stockQuantity,
      imageUrl: imageUrl,
    );
    return ProductModel.fromEntity(product);
  }
  
  @override
  Future<bool> updateProduct(ProductModel product) async {
    return await hiveStorage.updateProduct(product);
  }
  
  @override
  Future<bool> deleteProduct(String id) async {
    return await hiveStorage.deleteProduct(id);
  }

  @override
  List<ProductModel> searchProducts(String query) {
    final products = hiveStorage.searchProducts(query);
    return products.map((product) => ProductModel.fromEntity(product)).toList();
  }
} 