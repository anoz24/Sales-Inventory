import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../presentation/add_product/bloc/add_product_bloc.dart';
import '../../presentation/add_product/view/pages/add_product_page.dart';
import '../../presentation/auth/bloc/auth_bloc.dart';
import '../../presentation/auth/view/pages/login_page.dart';
import '../../presentation/dashboard/view/pages/dashboard_page.dart';
import '../../presentation/inventory/bloc/products_bloc.dart';
import '../../presentation/inventory/view/pages/inventory_page.dart';
import '../../presentation/sales/view/pages/ticket_sales_page.dart';
import '../../presentation/sales_history/view/pages/sales_history_page.dart';
import '../../presentation/scanner/view/pages/scan_item_page.dart';
import '../../injection_container.dart' as di;

class AppRoutes {
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String addProduct = '/add-product';
  static const String inventory = '/inventory';
  static const String scanItem = '/scan-item';
  static const String ticketSales = '/ticket-sales';
  static const String salesHistory = '/sales-history';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      login: (context) => BlocProvider(
            create: (context) => di.sl<AuthBloc>(),
            child: const LoginPage(),
          ),
      dashboard: (context) => const SafeArea(child: DashboardPage()),
      addProduct: (context) => BlocProvider(
            create: (context) => di.sl<AddProductBloc>(),
            child: const AddProductPage(),
          ),
      inventory: (context) => BlocProvider(
            create: (context) => di.sl<ProductsBloc>(),
            child: const InventoryPage(),
          ),
      scanItem: (context) => const ScanItemPage(),
      ticketSales: (context) => const TicketSalesPage(),
      salesHistory: (context) => const SalesHistoryPage(),
    };
  }

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (context) => di.sl<AuthBloc>(),
            child: const LoginPage(),
          ),
        );
      case dashboard:
        return MaterialPageRoute(builder: (context) => const SafeArea(child: DashboardPage()));
      case addProduct:
        return MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (context) => di.sl<AddProductBloc>(),
            child: const AddProductPage(),
          ),
        );
      case inventory:
        return MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (context) => di.sl<ProductsBloc>(),
            child: const InventoryPage(),
          ),
        );
      case scanItem:
        return MaterialPageRoute(builder: (context) => const ScanItemPage());
      case ticketSales:
        return MaterialPageRoute(builder: (context) => const TicketSalesPage());
      case salesHistory:
        return MaterialPageRoute(builder: (context) => const SalesHistoryPage());
      default:
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: const Text('Page Not Found')),
            body: const Center(
              child: Text('404 - Page Not Found'),
            ),
          ),
        );
    }
  }
} 