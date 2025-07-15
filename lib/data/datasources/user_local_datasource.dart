import '../../domain/entities/user.dart';
import '../../core/services/hive_storage_service.dart';

abstract class UserLocalDataSource {
  List<User> getUsers();
  User? getUser(String id);
  Future<User> createUser({
    required String name,
    required UserRole role,
    bool requiresPassword = false,
    String? password,
    String? avatarUrl,
  });
  Future<bool> updateUser(User user);
  Future<bool> deleteUser(String id);
  List<User> searchUsers(String query);
}

class UserLocalDataSourceImpl implements UserLocalDataSource {
  final HiveStorageService hiveStorage;
  
  UserLocalDataSourceImpl({required this.hiveStorage});
  
  @override
  List<User> getUsers() {
    return hiveStorage.getAllUsers();
  }
  
  @override
  User? getUser(String id) {
    return hiveStorage.getUserById(id);
  }
  
  @override
  Future<User> createUser({
    required String name,
    required UserRole role,
    bool requiresPassword = false,
    String? password,
    String? avatarUrl,
  }) async {
    return await hiveStorage.addUser(
      name: name,
      role: role,
      requiresPassword: requiresPassword,
      password: password,
      avatarUrl: avatarUrl,
    );
  }
  
  @override
  Future<bool> updateUser(User user) async {
    return await hiveStorage.updateUser(user);
  }
  
  @override
  Future<bool> deleteUser(String id) async {
    return await hiveStorage.deleteUser(id);
  }
  
  @override
  List<User> searchUsers(String query) {
    return hiveStorage.searchUsers(query);
  }
} 