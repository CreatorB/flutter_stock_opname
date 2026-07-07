import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syathiby/core/constants/color_constants.dart';
import 'package:syathiby/common/widgets/gradient_header.dart';
import 'package:syathiby/common/widgets/glow_card.dart';
import 'package:syathiby/common/widgets/gradient_button.dart';
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
          body: Column(
            children: [
              const GradientHeader(title: 'Keranjang'),
              const Center(
                child: Text(
                  'Keranjang kosong',
                  style: TextStyle(color: ColorConstants.whiteText),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCartContent(BuildContext context, SaleInProgress state) {
    if (state.cartItems.isEmpty) {
      return Scaffold(
        body: Column(
          children: [
            const GradientHeader(title: 'Keranjang'),
            const Center(
              child: Text(
                'Keranjang kosong',
                style: TextStyle(color: ColorConstants.whiteText),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          GradientHeader(
            title: 'Keranjang',
            trailing: TextButton(
              onPressed: () => _showClearConfirmation(context),
              child: const Text(
                'Hapus Semua',
                style: TextStyle(color: ColorConstants.redError),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                    context
                        .read<SaleBloc>()
                        .add(RemoveFromCartEvent(item.productId));
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
    return GlowCard(
      padding: const EdgeInsets.all(16),
      borderColor: ColorConstants.greenPrice.withOpacity(0.3),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ColorConstants.whiteText,
                ),
              ),
              Text(
                'Rp ${_formatNumber(totalAmount.toStringAsFixed(0))}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: ColorConstants.greenPrice,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GradientButton(
            text: 'BAYAR',
            onPressed: () => _navigateToPayment(context),
            gradientColors: [ColorConstants.greenPrice, ColorConstants.greenPrice],
            borderRadius: 12,
          ),
        ],
      ),
    );
  }

  void _showClearConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ColorConstants.glassCardSolid,
        title: const Text(
          'Hapus Semua?',
          style: TextStyle(color: ColorConstants.whiteText),
        ),
        content: const Text(
          'Semua item di keranjang akan dihapus.',
          style: TextStyle(color: ColorConstants.grayText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                const Text('Batal', style: TextStyle(color: ColorConstants.grayText)),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<SaleBloc>().add(const ClearCartEvent());
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: ColorConstants.redError),
            child:
                const Text('Hapus', style: TextStyle(color: Colors.white)),
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
