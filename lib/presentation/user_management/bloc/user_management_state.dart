import 'package:equatable/equatable.dart';
import '../../../domain/entities/user.dart';

abstract class UserManagementState extends Equatable {
  const UserManagementState();
  
  @override
  List<Object?> get props => [];
}

class UserManagementInitial extends UserManagementState {}

class UserManagementLoading extends UserManagementState {}

class UserManagementLoaded extends UserManagementState {
  final List<User> users;
  final List<User> filteredUsers;

  const UserManagementLoaded({
    required this.users,
    required this.filteredUsers,
  });

  @override
  List<Object?> get props => [users, filteredUsers];
}

class UserManagementError extends UserManagementState {
  final String message;

  const UserManagementError({required this.message});

  @override
  List<Object?> get props => [message];
}

class UserCreated extends UserManagementState {
  final User user;

  const UserCreated({required this.user});

  @override
  List<Object?> get props => [user];
}

class UserUpdated extends UserManagementState {
  final User user;

  const UserUpdated({required this.user});

  @override
  List<Object?> get props => [user];
}

class UserDeleted extends UserManagementState {
  final String userId;

  const UserDeleted({required this.userId});

  @override
  List<Object?> get props => [userId];
} 