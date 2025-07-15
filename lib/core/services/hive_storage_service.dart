import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/user.dart';

class HiveStorageService {
  static const String _productsBoxName = 'products';
  static const String _usersBoxName = 'users';
  static const String _settingsBoxName = 'settings';
  
  late Box<Product> _productsBox;
  late Box<User> _usersBox;
  late Box<dynamic> _settingsBox;

  // Initialize Hive and open boxes
  Future<void> init() async {
    await Hive.initFlutter();
    
    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ProductAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(UserRoleAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(UserAdapter());
    }
    
    // Open boxes
    _productsBox = await Hive.openBox<Product>(_productsBoxName);
    _usersBox = await Hive.openBox<User>(_usersBoxName);
    _settingsBox = await Hive.openBox(_settingsBoxName);
  }

  // Product operations
  List<Product> getAllProducts() {
    return _productsBox.values.toList();
  }

  Product? getProductById(String id) {
    return _productsBox.get(id);
  }

  Future<Product> addProduct({
    required String name,
    required String barcode,
    required double price,
    required int stockQuantity,
    String? imageUrl,
  }) async {
    // Generate unique ID if not provided
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    
    final product = Product(
      id: id,
      name: name,
      barcode: barcode,
      price: price,
      stockQuantity: stockQuantity,
      imageUrl: imageUrl,
    );
    
    await _productsBox.put(id, product);
    return product;
  }

  Future<bool> updateProduct(Product product) async {
    try {
      await _productsBox.put(product.id, product);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteProduct(String id) async {
    try {
      await _productsBox.delete(id);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Search products by name or barcode
  List<Product> searchProducts(String query) {
    if (query.isEmpty) return getAllProducts();
    
    final lowerQuery = query.toLowerCase();
    return _productsBox.values.where((product) {
      return product.name.toLowerCase().contains(lowerQuery) ||
             product.barcode.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  // Get products with low stock (less than minimum)
  List<Product> getLowStockProducts({int minimumStock = 10}) {
    return _productsBox.values
        .where((product) => product.stockQuantity < minimumStock)
        .toList();
  }

  // Get total inventory value
  double getTotalInventoryValue() {
    return _productsBox.values
        .fold(0.0, (sum, product) => sum + (product.price * product.stockQuantity));
  }

  // Get default placeholder images
  List<String> getDefaultImages() {
    return [
      'https://via.placeholder.com/300x300/E3F2FD/1976D2?text=Product',
      'https://via.placeholder.com/300x300/E8F5E8/4CAF50?text=Product',
      'https://via.placeholder.com/300x300/FFF3E0/FF9800?text=Product',
      'https://via.placeholder.com/300x300/FCE4EC/E91E63?text=Product',
      'https://via.placeholder.com/300x300/F3E5F5/9C27B0?text=Product',
    ];
  }

  // User operations
  List<User> getAllUsers() {
    return _usersBox.values.toList();
  }

  User? getUserById(String id) {
    return _usersBox.get(id);
  }

  Future<User> addUser({
    required String name,
    required UserRole role,
    bool requiresPassword = false,
    String? password,
    String? avatarUrl,
  }) async {
    // Generate unique ID if not provided
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    
    final user = User(
      id: id,
      name: name,
      role: role,
      requiresPassword: requiresPassword,
      password: password,
      avatarUrl: avatarUrl,
    );
    
    await _usersBox.put(id, user);
    return user;
  }

  Future<bool> updateUser(User user) async {
    try {
      await _usersBox.put(user.id, user);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteUser(String id) async {
    try {
      await _usersBox.delete(id);
      return true;
    } catch (e) {
      return false;
    }
  }

  List<User> searchUsers(String query) {
    if (query.isEmpty) return getAllUsers();
    
    return _usersBox.values.where((user) {
      return user.name.toLowerCase().contains(query.toLowerCase()) ||
             user.role.displayName.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  // Clear all data (useful for testing)
  Future<void> clearAllData() async {
    await _productsBox.clear();
    await _usersBox.clear();
    await _settingsBox.clear();
  }

  // Close all boxes
  Future<void> close() async {
    await _productsBox.close();
    await _usersBox.close();
    await _settingsBox.close();
  }

  // Get box statistics
  Map<String, dynamic> getStorageStats() {
    return {
      'totalProducts': _productsBox.length,
      'totalUsers': _usersBox.length,
      'lowStockProducts': getLowStockProducts().length,
      'totalValue': getTotalInventoryValue(),
      'lastUpdate': DateTime.now().toIso8601String(),
    };
  }
} 