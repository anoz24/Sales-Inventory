import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/utils/responsive_grid_utils.dart';
import '../../../../domain/entities/product.dart';
import '../../bloc/products_bloc.dart';
import '../../bloc/products_event.dart';
import '../../bloc/products_state.dart';
import '../widgets/product_grid_item.dart';
import 'edit_product_page.dart';
import '../../../../injection_container.dart' as di;

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final TextEditingController _searchController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    context.read<ProductsBloc>().add(GetProductsEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (query.trim().isNotEmpty) {
      context.read<ProductsBloc>().add(SearchProductsEvent(query.trim()));
    } else {
      context.read<ProductsBloc>().add(GetProductsEvent());
    }
  }

  void _editProduct(BuildContext context, Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => di.sl<ProductsBloc>(),
          child: EditProductPage(product: product),
        ),
      ),
    );
  }

  void _deleteProduct(BuildContext context, Product product) {
    context.read<ProductsBloc>().add(DeleteProductEvent(product.id));
    
    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} deleted successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search products...',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: _onSearchChanged,
                autofocus: true,
              )
            : const Text('Inventory'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.blue[700],
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  context.read<ProductsBloc>().add(GetProductsEvent());
                }
              });
            },
          ),
          if (!_isSearching)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context.read<ProductsBloc>().add(GetProductsEvent());
              },
            ),
        ],
      ),
      body: BlocBuilder<ProductsBloc, ProductsState>(
        builder: (context, state) {
          if (state is ProductsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ProductsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${state.message}',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ProductsBloc>().add(GetProductsEvent());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (state is ProductsLoaded) {
            if (state.products.isEmpty) {
              return _buildEmptyState();
            }
            
            return Column(
              children: [
                // Search results info
                if (state.isSearchResult)
                  Container(
                    padding: const EdgeInsets.all(12),
                    color: Colors.blue.withOpacity(0.1),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: Colors.blue[700], size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Found ${state.products.length} result(s) for "${state.searchQuery}"',
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isSearching = false;
                              _searchController.clear();
                            });
                            context.read<ProductsBloc>().add(GetProductsEvent());
                          },
                          child: const Text('Clear'),
                        ),
                      ],
                    ),
                  ),
                
                // Summary Section (only show for non-search results)
                if (!state.isSearchResult)
                  _buildSummarySection(state.products),
                
                // Products Grid
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      context.read<ProductsBloc>().add(GetProductsEvent());
                    },
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final config = ResponsiveGridUtils.getGridConfig(
                          constraints.maxWidth, 
                          isProductGrid: true
                        );
                        
                        return GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: config.crossAxisCount,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: config.childAspectRatio,
                          ),
                          itemCount: state.products.length,
                          itemBuilder: (context, index) {
                            final product = state.products[index];
                            final isAdmin = _authService.canAccessAdmin;
                            return ProductGridItem(
                              product: product,
                              onEdit: isAdmin ? () => _editProduct(context, product) : null,
                              onDelete: isAdmin ? () => _deleteProduct(context, product) : null,
                              isInteractive: isAdmin,
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          }
          
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: _authService.canAccessAdmin
          ? FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.pushNamed(context, '/add-product');
                if (result == true) {
                  // Refresh the list when a product is added
                  context.read<ProductsBloc>().add(GetProductsEvent());
                }
              },
              backgroundColor: Colors.blue,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildSummarySection(List products) {
    final totalItems = products.length;
    final lowStockItems = products.where((p) => p.stockQuantity < 10).length;
    final totalValue = products.fold<double>(0.0, (sum, p) => sum + (p.price * p.stockQuantity));
    
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.blue.withOpacity(0.1),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              title: 'Total Items',
              value: totalItems.toString(),
              icon: Icons.inventory,
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildSummaryCard(
              title: 'Low Stock',
              value: lowStockItems.toString(),
              icon: Icons.warning,
              color: lowStockItems > 0 ? Colors.orange : Colors.green,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildSummaryCard(
              title: 'Total Value',
              value: '\$${totalValue.toStringAsFixed(0)}',
              icon: Icons.attach_money,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No products found',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first product to get started',
            style: TextStyle(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () async {
              final result = await Navigator.pushNamed(context, '/add-product');
              if (result == true) {
                context.read<ProductsBloc>().add(GetProductsEvent());
              }
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Product'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
} 