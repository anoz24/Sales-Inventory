import 'package:equatable/equatable.dart';
import '../../../domain/entities/user.dart';

abstract class UserManagementEvent extends Equatable {
  const UserManagementEvent();
  
  @override
  List<Object?> get props => [];
}

class LoadUsers extends UserManagementEvent {}

class CreateUserEvent extends UserManagementEvent {
  final String name;
  final UserRole role;
  final bool requiresPassword;
  final String? password;
  final String? avatarUrl;

  const CreateUserEvent({
    required this.name,
    required this.role,
    this.requiresPassword = false,
    this.password,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [name, role, requiresPassword, password, avatarUrl];
}

class UpdateUserEvent extends UserManagementEvent {
  final User user;

  const UpdateUserEvent({required this.user});

  @override
  List<Object?> get props => [user];
}

class DeleteUserEvent extends UserManagementEvent {
  final String userId;

  const DeleteUserEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class SearchUsersEvent extends UserManagementEvent {
  final String query;

  const SearchUsersEvent({required this.query});

  @override
  List<Object?> get props => [query];
} 