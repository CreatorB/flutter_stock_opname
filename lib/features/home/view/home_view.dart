import 'package:flutter/material.dart';
import 'package:syathiby/features/dummies/laporan_screen.dart';
import 'package:syathiby/features/dummies/product_list_screen.dart';
import 'package:syathiby/features/dummies/setoran_screen.dart';
import 'package:syathiby/features/product/view/product_list_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(24.0),
        crossAxisCount: 2,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        children: [
          _buildMenuCard(
            context: context,
            icon: Icons.point_of_sale,
            label: 'PENJUALAN',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ProductListScreen()),
              );
            },
          ),
          _buildMenuCard(
            context: context,
            icon: Icons.inventory,
            label: 'OPNAME',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ProductListScreen()),
              );
            },
          ),
          _buildMenuCard(
            context: context,
            icon: Icons.savings,
            label: 'SETORAN',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SetoranScreen()),
              );
            },
          ),
          _buildMenuCard(
            context: context,
            icon: Icons.bar_chart,
            label: 'LAPORAN',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LaporanScreen()),
              );
            },
          ),
          _buildMenuCard(
            context: context,
            icon: Icons.list_alt,
            label: 'PRODUK',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProductListView()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.blueAccent),
            const SizedBox(height: 16.0),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
