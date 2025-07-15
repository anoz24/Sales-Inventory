import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/responsive_grid_utils.dart';
import '../../../../domain/entities/user.dart';
import '../../../../injection_container.dart' as di;
import '../../../auth/bloc/auth_bloc.dart';
import '../../../auth/bloc/auth_event.dart';
import '../../../auth/bloc/auth_state.dart';
import '../../../user_management/bloc/user_management_bloc.dart';
import '../../../user_management/view/pages/user_management_page.dart';
import '../components/dashboard_card.dart';
import '../components/full_width_card.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.brown[700],
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.brown[700],
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        actions: [
          _buildUserMenu(context),
        ],
      ),
      body: Container(
        color: Colors.grey[100],
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthAuthenticated) {
                return _buildDashboardContent(context, state.user);
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ),
    );
  }

  Widget _buildUserMenu(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          return PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _showLogoutDialog(context);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                enabled: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.user.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      state.user.role.displayName,
                      style: TextStyle(
                        color: state.user.isAdmin ? Colors.red : Colors.green,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor:
                        state.user.isAdmin ? Colors.red[100] : Colors.blue[100],
                    child: Icon(
                      state.user.isAdmin
                          ? Icons.admin_panel_settings
                          : Icons.person,
                      color: state.user.isAdmin
                          ? Colors.red[700]
                          : Colors.blue[700],
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.arrow_drop_down, color: Colors.white),
                ],
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildDashboardContent(BuildContext context, User user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Welcome Message
        _buildWelcomeSection(user),
        const SizedBox(height: 24),

        // Feature Cards
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final config = ResponsiveGridUtils.getGridConfig(constraints.maxWidth);
              
              return GridView.count(
                crossAxisCount: config.crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: config.childAspectRatio,
                children: _buildFeatureCards(context, user),
              );
            },
          ),
        ),

        // Sales History (available to all users)
        FullWidthCard(
          title: 'Sales History',
          subtitle: 'View all past transactions',
          icon: Icons.history,
          color: Colors.teal,
          onTap: () => _navigateToSalesHistory(context),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildWelcomeSection(User user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.brown[600]!, Colors.brown[400]!],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Icon(
              user.isAdmin ? Icons.admin_panel_settings : Icons.person,
              color: user.isAdmin ? Colors.red[700] : Colors.blue[700],
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back,',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
                Text(
                  user.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: user.isAdmin ? Colors.red : Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    user.role.displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFeatureCards(BuildContext context, User user) {
    List<Widget> cards = [];

    // Inventory (available to both admin and sales)
    cards.add(
      DashboardCard(
        title: 'Inventory',
        icon: Icons.inventory_2,
        color: Colors.blue,
        onTap: () => _navigateToInventory(context),
      ),
    );

    // Sales features (available to both admin and sales)
    if (user.role.canAccessSales) {
      cards.addAll([
        DashboardCard(
          title: 'Scan Item',
          icon: Icons.qr_code_scanner,
          color: Colors.orange,
          onTap: () => _navigateToScanItem(context),
        ),
        DashboardCard(
          title: 'Ticket Sales',
          icon: Icons.receipt_long,
          color: Colors.purple,
          onTap: () => _navigateToTicketSales(context),
        ),
      ]);
    }

    // Admin-only features
    if (user.role.canAccessAdmin) {
      cards.addAll([
        DashboardCard(
          title: 'Add Product',
          icon: Icons.add_box,
          color: Colors.green,
          onTap: () => _navigateToAddProduct(context),
        ),
        DashboardCard(
          title: 'Manage Users',
          icon: Icons.people,
          color: Colors.red,
          onTap: () => _navigateToUserManagement(context),
        ),
      ]);
    }

    return cards;
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AuthBloc>().add(AuthLogoutRequested());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _navigateToAddProduct(BuildContext context) {
    Navigator.pushNamed(context, '/add-product');
  }

  void _navigateToInventory(BuildContext context) {
    Navigator.pushNamed(context, '/inventory');
  }

  void _navigateToScanItem(BuildContext context) {
    Navigator.pushNamed(context, '/scan-item');
  }

  void _navigateToTicketSales(BuildContext context) {
    Navigator.pushNamed(context, '/ticket-sales');
  }

  void _navigateToSalesHistory(BuildContext context) {
    Navigator.pushNamed(context, '/sales-history');
  }

  void _navigateToUserManagement(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => di.sl<UserManagementBloc>(),
          child: const UserManagementPage(),
        ),
      ),
    );
  }
}
