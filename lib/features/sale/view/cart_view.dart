import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syathiby/features/payment/view/payment_method_view.dart';
import 'package:syathiby/features/sale/bloc/sale_bloc.dart';
import 'package:syathiby/features/sale/bloc/sale_event.dart';
import 'package:syathiby/features/sale/bloc/sale_state.dart';
import 'package:syathiby/features/sale/widgets/cart_item_widget.dart';
import 'package:syathiby/features/sale/widgets/price_selector_widget.dart';

class CartView extends StatelessWidget {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SaleBloc, SaleState>(
      builder: (context, state) {
        if (state is SaleInProgress) {
          return _buildCartContent(context, state);
        }
        return Scaffold(
          appBar: AppBar(title: const Text('Keranjang')),
          body: const Center(child: Text('Keranjang kosong')),
        );
      },
    );
  }

  Widget _buildCartContent(BuildContext context, SaleInProgress state) {
    if (state.cartItems.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Keranjang')),
        body: const Center(child: Text('Keranjang kosong')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Keranjang'),
        actions: [
          TextButton(
            onPressed: () => _showClearConfirmation(context),
            child: const Text('Hapus Semua'),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: state.cartItems.length,
              itemBuilder: (context, index) {
                final item = state.cartItems[index];
                return CartItemWidget(
                  cartItem: item,
                  onUpdate: (qty, priceMode, priceArea, manualPrice) {
                    context.read<SaleBloc>().add(UpdateCartItemEvent(
                          productId: item.productId,
                          quantity: qty,
                          priceMode: priceMode,
                          selectedPriceArea: priceArea,
                          manualPrice: manualPrice,
                        ));
                  },
                  onRemove: () {
                    context.read<SaleBloc>().add(RemoveFromCartEvent(item.productId));
                  },
                );
              },
            ),
          ),
          _buildBottomBar(context, state.totalAmount),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, double totalAmount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(50),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Rp ${_formatNumber(totalAmount.toStringAsFixed(0))}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _navigateToPayment(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('BAYAR'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Semua?'),
        content: const Text('Semua item di keranjang akan dihapus.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<SaleBloc>().add(const ClearCartEvent());
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _navigateToPayment(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PaymentMethodView()),
    );
  }

  String _formatNumber(String number) {
    final num = double.tryParse(number);
    if (num == null) return number;
    return num.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }
}