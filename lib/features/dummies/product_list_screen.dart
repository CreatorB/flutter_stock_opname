import 'package:flutter/material.dart';
import 'package:syathiby/features/dummies/cart_screen.dart';

import 'scanner_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _allProducts = List.generate(
    20,
    (index) => {
      "id": index + 1,
      "name": "Produk #${index + 1}",
      "description": "Deskripsi singkat produk",
      "stock": 10 + index,
    },
  );

  late List<Map<String, dynamic>> _filteredProducts;

  @override
  void initState() {
    super.initState();
    _filteredProducts = _allProducts;
    _searchController.addListener(_filterProducts);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterProducts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProducts = _allProducts.where((product) {
        return product['name'].toLowerCase().contains(query);
      }).toList();
    });
  }

  void _openScanner() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ScannerScreen()),
    );
  }

  AppBar _buildAppBar() {
    if (_isSearching) {
      return AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              _isSearching = false;
              _searchController.clear();
            });
          },
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Cari produk...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white70),
          ),
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      );
    } else {
      return AppBar(
        title: const Text('Daftar Produk'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Pencarian',
            onPressed: () {
              setState(() {
                _isSearching = true;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: 'Pindai Barcode',
            onPressed: _openScanner,
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.only(bottom: 80.0),
          itemCount: _filteredProducts.length,
          itemBuilder: (context, index) {
            final product = _filteredProducts[index];
            return ListTile(
              leading: const Icon(Icons.inventory_2_outlined),
              title: Text(product['name']),
              subtitle: Text(product['description']),
              trailing: Text('Stok: ${product['stock']}'),
              onTap: () {},
            );
          },
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 50.0),
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CartScreen()),
            );
          },
          label: const Text('Keranjang (3)'),
          icon: const Icon(Icons.shopping_cart),
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}
