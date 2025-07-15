import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 1)
enum UserRole {
  @HiveField(0)
  admin,
  @HiveField(1)
  sales,
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.sales:
        return 'Sales';
    }
  }

  bool get canAccessAdmin {
    return this == UserRole.admin;
  }

  bool get canAccessSales {
    return this == UserRole.admin || this == UserRole.sales;
  }
}

@HiveType(typeId: 2)
class User extends Equatable {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final UserRole role;
  
  @HiveField(3)
  final bool requiresPassword;
  
  @HiveField(4)
  final String? password; // Only for admin
  
  @HiveField(5)
  final String? avatarUrl;

  const User({
    required this.id,
    required this.name,
    required this.role,
    this.requiresPassword = false,
    this.password,
    this.avatarUrl,
  });

  bool get isAdmin => role == UserRole.admin;
  bool get isSales => role == UserRole.sales;

  @override
  List<Object?> get props => [
        id,
        name,
        role,
        requiresPassword,
        password,
        avatarUrl,
      ];

  User copyWith({
    String? id,
    String? name,
    UserRole? role,
    bool? requiresPassword,
    String? password,
    String? avatarUrl,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      requiresPassword: requiresPassword ?? this.requiresPassword,
      password: password ?? this.password,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
} 