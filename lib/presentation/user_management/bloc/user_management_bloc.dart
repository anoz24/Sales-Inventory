import 'package:bloc/bloc.dart';
import '../../../domain/usecases/get_users.dart';
import '../../../domain/usecases/create_user.dart';
import '../../../domain/usecases/update_user.dart';
import '../../../domain/usecases/delete_user.dart';
import '../../../domain/usecases/search_users.dart';
import '../../../core/usecases/usecase.dart';
import 'user_management_event.dart';
import 'user_management_state.dart';

class UserManagementBloc extends Bloc<UserManagementEvent, UserManagementState> {
  final GetUsers getUsers;
  final CreateUser createUser;
  final UpdateUser updateUser;
  final DeleteUser deleteUser;
  final SearchUsers searchUsers;

  UserManagementBloc({
    required this.getUsers,
    required this.createUser,
    required this.updateUser,
    required this.deleteUser,
    required this.searchUsers,
  }) : super(UserManagementInitial()) {
    on<LoadUsers>(_onLoadUsers);
    on<CreateUserEvent>(_onCreateUser);
    on<UpdateUserEvent>(_onUpdateUser);
    on<DeleteUserEvent>(_onDeleteUser);
    on<SearchUsersEvent>(_onSearchUsers);
  }

  Future<void> _onLoadUsers(
    LoadUsers event,
    Emitter<UserManagementState> emit,
  ) async {
    emit(UserManagementLoading());
    
    final result = await getUsers(NoParams());
    
    result.fold(
      (failure) => emit(UserManagementError(message: failure.message)),
      (users) => emit(UserManagementLoaded(
        users: users,
        filteredUsers: users,
      )),
    );
  }

  Future<void> _onCreateUser(
    CreateUserEvent event,
    Emitter<UserManagementState> emit,
  ) async {
    emit(UserManagementLoading());
    
    final result = await createUser(CreateUserParams(
      name: event.name,
      role: event.role,
      requiresPassword: event.requiresPassword,
      password: event.password,
      avatarUrl: event.avatarUrl,
    ));
    
    result.fold(
      (failure) => emit(UserManagementError(message: failure.message)),
      (user) {
        emit(UserCreated(user: user));
        add(LoadUsers()); // Reload users after creation
      },
    );
  }

  Future<void> _onUpdateUser(
    UpdateUserEvent event,
    Emitter<UserManagementState> emit,
  ) async {
    emit(UserManagementLoading());
    
    final result = await updateUser(UpdateUserParams(user: event.user));
    
    result.fold(
      (failure) => emit(UserManagementError(message: failure.message)),
      (success) {
        if (success) {
          emit(UserUpdated(user: event.user));
          add(LoadUsers()); // Reload users after update
        } else {
          emit(UserManagementError(message: 'Failed to update user'));
        }
      },
    );
  }

  Future<void> _onDeleteUser(
    DeleteUserEvent event,
    Emitter<UserManagementState> emit,
  ) async {
    emit(UserManagementLoading());
    
    final result = await deleteUser(DeleteUserParams(id: event.userId));
    
    result.fold(
      (failure) => emit(UserManagementError(message: failure.message)),
      (success) {
        if (success) {
          emit(UserDeleted(userId: event.userId));
          add(LoadUsers()); // Reload users after deletion
        } else {
          emit(UserManagementError(message: 'Failed to delete user'));
        }
      },
    );
  }

  Future<void> _onSearchUsers(
    SearchUsersEvent event,
    Emitter<UserManagementState> emit,
  ) async {
    // Get all users first
    final getAllResult = await getUsers(NoParams());
    
    getAllResult.fold(
      (failure) => emit(UserManagementError(message: failure.message)),
      (allUsers) async {
        // Then search/filter users
        final searchResult = await searchUsers(SearchUsersParams(query: event.query));
        searchResult.fold(
          (failure) => emit(UserManagementError(message: failure.message)),
          (filteredUsers) => emit(UserManagementLoaded(
            users: allUsers,
            filteredUsers: filteredUsers,
          )),
        );
      },
    );
  }
} 