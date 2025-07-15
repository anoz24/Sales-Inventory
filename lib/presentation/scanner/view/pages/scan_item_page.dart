import 'package:flutter/material.dart';

class ScanItemPage extends StatefulWidget {
  const ScanItemPage({super.key});

  @override
  State<ScanItemPage> createState() => _ScanItemPageState();
}

class _ScanItemPageState extends State<ScanItemPage> {
  bool _isScanning = false;
  String? _lastScannedCode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Item'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () {
              // TODO: Toggle flash
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Scanner Area
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.orange, width: 2),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.qr_code_scanner,
                    size: 120,
                    color: Colors.orange.withOpacity(0.7),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _isScanning ? 'Scanning...' : 'Point camera at barcode/QR code',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (_lastScannedCode != null) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green),
                      ),
                      child: Text(
                        'Last scanned: $_lastScannedCode',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          // Controls Section
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Scan Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _toggleScanning,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isScanning ? Colors.red : Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(_isScanning ? Icons.stop : Icons.qr_code_scanner),
                          const SizedBox(width: 8),
                          Text(
                            _isScanning ? 'Stop Scanning' : 'Start Scanning',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Manual Entry
                  OutlinedButton(
                    onPressed: _showManualEntryDialog,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.orange,
                      side: const BorderSide(color: Colors.orange),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.keyboard),
                        SizedBox(width: 8),
                        Text('Enter Code Manually'),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Recent Scans
                  if (_lastScannedCode != null)
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.history, color: Colors.orange),
                        title: const Text('Recent Scans'),
                        subtitle: const Text('Tap to view scan history'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: _showScanHistory,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleScanning() {
    setState(() {
      _isScanning = !_isScanning;
    });

    if (_isScanning) {
      // Simulate scanning delay
      Future.delayed(const Duration(seconds: 3), () {
        if (_isScanning) {
          setState(() {
            _isScanning = false;
            _lastScannedCode = '1234567890123';
          });
          _showProductFound();
        }
      });
    }
  }

  void _showManualEntryDialog() {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Code Manually'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Barcode/QR Code',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() {
                  _lastScannedCode = controller.text;
                });
                Navigator.pop(context);
                _showProductFound();
              }
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  void _showProductFound() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Product Found!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Code: $_lastScannedCode'),
            const SizedBox(height: 8),
            const Text('Product: Sample Product'),
            const Text('Price: \$99.99'),
            const Text('Stock: 15 units'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Navigate to product details or add to cart
            },
            child: const Text('View Product'),
          ),
        ],
      ),
    );
  }

  void _showScanHistory() {
    // TODO: Show scan history page
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Scan history coming soon!')),
    );
  }
} 