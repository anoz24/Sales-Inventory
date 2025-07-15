import 'package:bloc/bloc.dart';
import '../../../core/services/auth_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService authService;
  
  AuthBloc({required this.authService}) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthLoginWithUserRequested>(_onAuthLoginWithUserRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
  }
  
  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    await Future.delayed(const Duration(milliseconds: 100)); // Small delay to ensure proper state transition
    if (authService.isLoggedIn && authService.currentUser != null) {
      emit(AuthAuthenticated(user: authService.currentUser!));
    } else {
      emit(AuthUnauthenticated());
    }
  }
  
  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    final result = await authService.login(event.userId, event.password);
    
    if (result.isSuccess && result.user != null) {
      emit(AuthAuthenticated(user: result.user!));
    } else {
      emit(AuthError(message: result.errorMessage ?? 'Login failed'));
    }
  }
  
  Future<void> _onAuthLoginWithUserRequested(
    AuthLoginWithUserRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    final result = await authService.loginWithUser(event.user);
    
    if (result.isSuccess && result.user != null) {
      emit(AuthAuthenticated(user: result.user!));
    } else {
      emit(AuthError(message: result.errorMessage ?? 'Login failed'));
    }
  }
  
  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    await authService.logout();
    emit(AuthUnauthenticated());
  }
} 