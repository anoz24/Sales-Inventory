import 'package:get_it/get_it.dart';

import 'core/services/hive_storage_service.dart';
import 'core/services/auth_service.dart';
import 'presentation/add_product/bloc/add_product_bloc.dart';
import 'presentation/inventory/bloc/products_bloc.dart';
import 'presentation/auth/bloc/auth_bloc.dart';
import 'presentation/sales/bloc/sales_bloc.dart';
import 'presentation/user_management/bloc/user_management_bloc.dart';
import 'data/datasources/product_local_datasource.dart';
import 'data/datasources/user_local_datasource.dart';
import 'data/repositories/product_repository_impl.dart';
import 'data/repositories/user_repository_impl.dart';
import 'domain/repositories/product_repository.dart';
import 'domain/repositories/user_repository.dart';
import 'domain/usecases/create_product.dart';
import 'domain/usecases/get_products.dart';
import 'domain/usecases/search_products.dart';
import 'domain/usecases/update_product.dart';
import 'domain/usecases/delete_product.dart';
import 'domain/usecases/get_users.dart';
import 'domain/usecases/create_user.dart';
import 'domain/usecases/update_user.dart';
import 'domain/usecases/delete_user.dart';
import 'domain/usecases/search_users.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Features - Authentication
  // Bloc
  sl.registerFactory(() => AuthBloc(authService: sl()));
  
  // Features - Products
  // Bloc
  sl.registerFactory(() => ProductsBloc(
        getProducts: sl(),
        searchProducts: sl(),
        updateProduct: sl(),
        deleteProduct: sl(),
      ));
  sl.registerFactory(() => AddProductBloc(createProduct: sl()));
  
  // Features - Sales
  // Bloc
  sl.registerFactory(() => SalesBloc(
        getProducts: sl(),
        searchProducts: sl(),
      ));
  
  // Features - User Management
  // Bloc
  sl.registerFactory<UserManagementBloc>(() => UserManagementBloc(
        getUsers: sl<GetUsers>(),
        createUser: sl<CreateUser>(),
        updateUser: sl<UpdateUser>(),
        deleteUser: sl<DeleteUser>(),
        searchUsers: sl<SearchUsers>(),
      ));
  
  // Use cases - Products
  sl.registerLazySingleton(() => GetProducts(sl()));
  sl.registerLazySingleton(() => CreateProduct(sl()));
  sl.registerLazySingleton(() => SearchProducts(sl()));
  sl.registerLazySingleton(() => UpdateProduct(sl()));
  sl.registerLazySingleton(() => DeleteProduct(sl()));
  
  // Use cases - Users
  sl.registerLazySingleton<GetUsers>(() => GetUsers(sl()));
  sl.registerLazySingleton<CreateUser>(() => CreateUser(sl()));
  sl.registerLazySingleton<UpdateUser>(() => UpdateUser(sl()));
  sl.registerLazySingleton<DeleteUser>(() => DeleteUser(sl()));
  sl.registerLazySingleton<SearchUsers>(() => SearchUsers(sl()));
  
  // Repository
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(
      localDataSource: sl(),
    ),
  );
  
  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(
      localDataSource: sl(),
    ),
  );
  
  // Data sources
  sl.registerLazySingleton<ProductLocalDataSource>(
    () => ProductLocalDataSourceImpl(
      hiveStorage: sl(),
    ),
  );
  
  sl.registerLazySingleton<UserLocalDataSource>(
    () => UserLocalDataSourceImpl(
      hiveStorage: sl(),
    ),
  );
  
  // Core Services
  sl.registerLazySingleton<HiveStorageService>(() => HiveStorageService());
  sl.registerLazySingleton<AuthService>(() {
    final authService = AuthService();
    authService.initialize(sl<UserRepository>());
    return authService;
  });
} 