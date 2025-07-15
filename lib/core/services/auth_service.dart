import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  User? _currentUser;
  UserRepository? _userRepository;
  
  // Initialize with user repository
  void initialize(UserRepository userRepository) {
    _userRepository = userRepository;
  }
  
  // Predefined users (used for initial seeding)
  static const List<User> _predefinedUsers = [
    // Admin user (requires password)
    User(
      id: 'admin_001',
      name: 'Admin User',
      role: UserRole.admin,
      requiresPassword: true,
      password: 'admin123', // In production, this should be hashed
      avatarUrl: null,
    ),
    
    // Sales users (no password required)
    User(
      id: 'sales_001',
      name: 'John Smith',
      role: UserRole.sales,
      requiresPassword: false,
      avatarUrl: null,
    ),
    User(
      id: 'sales_002',
      name: 'Sarah Johnson',
      role: UserRole.sales,
      requiresPassword: false,
      avatarUrl: null,
    ),
    User(
      id: 'sales_003',
      name: 'Mike Wilson',
      role: UserRole.sales,
      requiresPassword: false,
      avatarUrl: null,
    ),
    User(
      id: 'sales_004',
      name: 'Lisa Davis',
      role: UserRole.sales,
      requiresPassword: false,
      avatarUrl: null,
    ),
  ];

  // Get all available users for login selection
  List<User> get availableUsers {
    if (_userRepository == null) return _predefinedUsers;
    
    // Since this is a synchronous getter, we need to handle the async result
    // For now, return predefined users and let the UI handle loading
    return _predefinedUsers;
  }

  // Get all available users for login selection (async version)
  Future<List<User>> getAvailableUsersAsync() async {
    if (_userRepository == null) return _predefinedUsers;
    
    final result = await _userRepository!.getUsers();
    return result.fold(
      (failure) => _predefinedUsers,
      (users) => users,
    );
  }
  
  // Get current logged-in user
  User? get currentUser => _currentUser;
  
  // Check if user is logged in
  bool get isLoggedIn => _currentUser != null;
  
  // Check if current user is admin
  bool get isCurrentUserAdmin => _currentUser?.isAdmin ?? false;
  
  // Check if current user can access admin features
  bool get canAccessAdmin => _currentUser?.role.canAccessAdmin ?? false;
  
  // Check if current user can access sales features
  bool get canAccessSales => _currentUser?.role.canAccessSales ?? false;

  // Login with user ID and optional password
  Future<AuthResult> login(String userId, [String? password]) async {
    try {
      User? user;
      
      // Try to get user from repository first
      if (_userRepository != null) {
        final result = await _userRepository!.getUser(userId);
        result.fold(
          (failure) => null, // Will fall back to predefined users
          (foundUser) => user = foundUser,
        );
      }
      
      // Fall back to predefined users if not found in repository
      if (user == null) {
        user = _predefinedUsers.firstWhere(
          (u) => u.id == userId,
          orElse: () => throw Exception('User not found'),
        );
      }

      // Check password requirement
      if (user!.requiresPassword) {
        if (password == null || password.isEmpty) {
          return AuthResult.failure('Password is required for this user');
        }
        if (user!.password != password) {
          return AuthResult.failure('Invalid password');
        }
      }

      // Set current user
      _currentUser = user!;
      return AuthResult.success(user!);
      
    } catch (e) {
      return AuthResult.failure('Login failed: ${e.toString()}');
    }
  }

  // Login with user object (for sales users without password)
  Future<AuthResult> loginWithUser(User user) async {
    if (user.requiresPassword) {
      return AuthResult.failure('This user requires password authentication');
    }
    
    _currentUser = user;
    return AuthResult.success(user);
  }

  // Logout
  Future<void> logout() async {
    _currentUser = null;
  }

  // Get user by ID
  Future<User?> getUserById(String userId) async {
    try {
      if (_userRepository != null) {
        final result = await _userRepository!.getUser(userId);
        return result.fold(
          (failure) => null,
          (user) => user,
        );
      }
      return _predefinedUsers.firstWhere((u) => u.id == userId);
    } catch (e) {
      return null;
    }
  }

  // Get users by role
  Future<List<User>> getUsersByRole(UserRole role) async {
    try {
      if (_userRepository != null) {
        final result = await _userRepository!.getUsers();
        return result.fold(
          (failure) => _predefinedUsers.where((u) => u.role == role).toList(),
          (users) => users.where((u) => u.role == role).toList(),
        );
      }
      return _predefinedUsers.where((u) => u.role == role).toList();
    } catch (e) {
      return _predefinedUsers.where((u) => u.role == role).toList();
    }
  }
  
  // Seed initial users if no users exist
  Future<void> seedInitialUsers() async {
    if (_userRepository == null) return;
    
    final result = await _userRepository!.getUsers();
    result.fold(
      (failure) => null, // Do nothing if we can't get users
      (existingUsers) async {
        if (existingUsers.isEmpty) {
          // Create initial users from predefined list
          for (final user in _predefinedUsers) {
            await _userRepository!.createUser(
              name: user.name,
              role: user.role,
              requiresPassword: user.requiresPassword,
              password: user.password,
              avatarUrl: user.avatarUrl,
            );
          }
        }
      },
    );
  }
}

// Authentication result class
class AuthResult {
  final bool isSuccess;
  final String? errorMessage;
  final User? user;

  AuthResult._({
    required this.isSuccess,
    this.errorMessage,
    this.user,
  });

  factory AuthResult.success(User user) {
    return AuthResult._(
      isSuccess: true,
      user: user,
    );
  }

  factory AuthResult.failure(String message) {
    return AuthResult._(
      isSuccess: false,
      errorMessage: message,
    );
  }
} 