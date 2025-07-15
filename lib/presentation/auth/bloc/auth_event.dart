import 'package:equatable/equatable.dart';
import '../../../domain/entities/user.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  
  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String userId;
  final String? password;
  
  const AuthLoginRequested({
    required this.userId,
    this.password,
  });
  
  @override
  List<Object?> get props => [userId, password];
}

class AuthLoginWithUserRequested extends AuthEvent {
  final User user;
  
  const AuthLoginWithUserRequested({required this.user});
  
  @override
  List<Object?> get props => [user];
}

class AuthLogoutRequested extends AuthEvent {} 