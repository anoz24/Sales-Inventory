import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entities/cart_item.dart';
import '../../../../domain/entities/product.dart';
import '../../../../injection_container.dart' as di;
import '../../bloc/sales_bloc.dart';
import '../../bloc/sales_event.dart';
import '../../bloc/sales_state.dart';

class TicketSalesPage extends StatefulWidget {
  const TicketSalesPage({super.key});

  @override
  State<TicketSalesPage> createState() => _TicketSalesPageState();
}

class _TicketSalesPageState extends State<TicketSalesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('New Sale'),
          backgroundColor: Colors.brown[700],
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.history),
              onPressed: () {
                Navigator.pushNamed(context, '/sales-history');
              },
            ),
          ],
        ),
        body: BlocConsumer<SalesBloc, SalesState>(
          listener: (context, state) {
            if (state is CartItemAdded) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${state.product.name} added to cart'),
                  backgroundColor: Colors.brown[600],
                ),
              );
            } else if (state is CartItemRemoved) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${state.product.name} removed from cart'),
                  backgroundColor: Colors.brown[600],
                ),
              );
            } else if (state is StockError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Cannot add ${state.requestedQuantity} ${state.product.name}. Only ${state.availableStock} in stock. Item removed from cart.',
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (state is SalesError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${state.message}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is SalesLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (state is SalesLoaded) {
              return Column(
                children: [
                  // Customer Section
                  _buildCustomerSection(),
                  
                  // Cart Items
                  Expanded(
                    child: state.cartItems.isEmpty
                        ? _buildEmptyCart()
                        : ListView.builder(
                            itemCount: state.cartItems.length,
                            itemBuilder: (context, index) {
                              final item = state.cartItems[index];
                              return _buildCartItem(item, index);
                            },
                          ),
                  ),
                  
                  // Add Item Section
                  _buildAddItemSection(),
                  
                  // Total Section
                  if (state.cartItems.isNotEmpty) _buildTotalSection(state),
                ],
              );
            }
            
            return const Center(child: Text('Something went wrong'));
          },
        ),
      );
  }

  Widget _buildCustomerSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[50],
      child: Row(
        children: [
          const Icon(Icons.person, color: Colors.brown),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Customer',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Walk-in Customer',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: _selectCustomer,
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No items in cart',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add products to start a sale',
            style: TextStyle(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(CartItem item, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Product Image
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: item.product.imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        item.product.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.image_not_supported),
                      ),
                    )
                  : const Icon(Icons.shopping_bag, color: Colors.grey),
            ),
            const SizedBox(width: 12),
            
            // Product Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '\$${item.unitPrice.toStringAsFixed(2)}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            
            // Quantity Controls
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () => context.read<SalesBloc>().add(
                    UpdateCartQuantityEvent(
                      cartIndex: index,
                      newQuantity: item.quantity - 1,
                    ),
                  ),
                  icon: const Icon(Icons.remove_circle_outline),
                  color: Colors.red,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    item.quantity.toString(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  onPressed: () => context.read<SalesBloc>().add(
                    UpdateCartQuantityEvent(
                      cartIndex: index,
                      newQuantity: item.quantity + 1,
                    ),
                  ),
                  icon: const Icon(Icons.add_circle_outline),
                  color: Colors.brown[600],
                ),
              ],
            ),
            
            // Total Price
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${item.totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                IconButton(
                  onPressed: () => context.read<SalesBloc>().add(
                    RemoveFromCartEvent(index),
                  ),
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddItemSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _showProductSelectionBottomSheet,
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text('Add Products'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown[600],
                foregroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: _addItemByScan,
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('Scan'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.brown[500],
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalSection(SalesLoaded state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal:'),
              Text('\$${state.subtotal.toStringAsFixed(2)}'),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tax (8%):'),
              Text('\$${state.tax.toStringAsFixed(2)}'),
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '\$${state.total.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _processPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Process Payment',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showProductSelectionBottomSheet() {
    final salesBloc = context.read<SalesBloc>();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => BlocProvider.value(
        value: salesBloc,
        child: DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          builder: (context, scrollController) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Handle
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    children: [
                      const Text(
                        'Select Products',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      BlocBuilder<SalesBloc, SalesState>(
                        buildWhen: (previous, current) {
                          // Always rebuild when state changes
                          return true;
                        },
                        builder: (context, state) {
                          if (state is SalesLoaded) {
                            final totalSelected = state.selectedQuantities.values
                                .where((quantity) => quantity > 0)
                                .length;
                            return ElevatedButton(
                              onPressed: totalSelected > 0 
                                  ? () => _addAllSelectedToCart(context, state)
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.brown[600],
                                foregroundColor: Colors.white,
                              ),
                              child: Text('Add to Cart ($totalSelected)'),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                ),
                
                // Products List
                Expanded(
                  child: BlocConsumer<SalesBloc, SalesState>(
                    listener: (context, state) {
                      // Handle stock errors
                      if (state is StockError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Cannot add ${state.requestedQuantity} ${state.product.name}. Only ${state.availableStock} in stock. Item removed from cart.',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    buildWhen: (previous, current) {
                      // Always rebuild when state changes
                      return true;
                    },
                    builder: (context, state) {
                      if (state is SalesLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      
                      if (state is SalesError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline, size: 48, color: Colors.red),
                              const SizedBox(height: 16),
                              Text('Error: ${state.message}'),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => context.read<SalesBloc>().add(LoadProductsEvent()),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        );
                      }
                      
                      if (state is SalesLoaded) {
                        if (state.products.isEmpty) {
                          return const Center(
                            child: Text('No products available'),
                          );
                        }
                        
                        return GridView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.all(16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.75,
                          ),
                          itemCount: state.products.length,
                          itemBuilder: (context, index) {
                            final product = state.products[index];
                            return _buildProductSelectionItem(product, state.selectedQuantities);
                          },
                        );
                      }
                      
                      return const Center(child: Text('No products found'));
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
    );
  }

  Widget _buildProductSelectionItem(Product product, Map<String, int> selectedQuantities) {
    final selectedQuantity = selectedQuantities[product.id] ?? 0;
    final isOutOfStock = product.stockQuantity == 0;
    
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: product.imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          product.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.image_not_supported, size: 40),
                        ),
                      )
                    : const Icon(Icons.shopping_bag, color: Colors.grey, size: 40),
              ),
            ),
            const SizedBox(height: 8),
            
            // Product Info
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Colors.brown[600],
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Stock: ${product.stockQuantity}',
                    style: TextStyle(
                      color: isOutOfStock ? Colors.red : Colors.green,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            
            // Quantity Controls
            if (!isOutOfStock) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: selectedQuantity > 0 
                        ? () => context.read<SalesBloc>().add(
                            UpdateSelectedQuantityEvent(
                              productId: product.id,
                              quantity: selectedQuantity - 1,
                            ),
                          )
                        : null,
                    icon: const Icon(Icons.remove_circle_outline),
                    color: Colors.red,
                    iconSize: 20,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      selectedQuantity.toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    onPressed: selectedQuantity < product.stockQuantity
                        ? () => context.read<SalesBloc>().add(
                            UpdateSelectedQuantityEvent(
                              productId: product.id,
                              quantity: selectedQuantity + 1,
                            ),
                          )
                        : null,
                    icon: const Icon(Icons.add_circle_outline),
                    color: selectedQuantity < product.stockQuantity ? Colors.brown[600] : Colors.grey,
                    iconSize: 20,
                  ),
                ],
              ),
            ] else ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Out of Stock',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _selectCustomer() {
    // TODO: Implement customer selection
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Customer selection not implemented yet')),
    );
  }

  void _addItemByScan() {
    Navigator.pushNamed(context, '/scan-item');
  }

  void _processPayment() {
    final salesBloc = context.read<SalesBloc>();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Process Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Total: \$${salesBloc.total.toStringAsFixed(2)}'),
            const SizedBox(height: 16),
            const Text('Select payment method:'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _completeSale();
            },
            child: const Text('Cash'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _completeSale();
            },
            child: const Text('Card'),
          ),
        ],
      ),
    );
  }

  void _completeSale() {
    context.read<SalesBloc>().add(ClearCartEvent());
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sale completed successfully!'),
        backgroundColor: Colors.brown,
      ),
    );
  }

  void _addAllSelectedToCart(BuildContext context, SalesLoaded state) {
    // Add all selected products to cart
    for (final entry in state.selectedQuantities.entries) {
      final productId = entry.key;
      final quantity = entry.value;
      
      if (quantity > 0) {
        try {
          final product = state.products.firstWhere((p) => p.id == productId);
          context.read<SalesBloc>().add(
            AddToCartEvent(
              product: product,
              quantity: quantity,
            ),
          );
        } catch (e) {
          // Product not found, skip it
          print('Product with ID $productId not found');
        }
      }
    }
    
    // Clear all selected quantities
    final keysToRemove = List.from(state.selectedQuantities.keys);
    for (final productId in keysToRemove) {
      context.read<SalesBloc>().add(
        UpdateSelectedQuantityEvent(
          productId: productId,
          quantity: 0,
        ),
      );
    }
    
    Navigator.pop(context);
  }
} 