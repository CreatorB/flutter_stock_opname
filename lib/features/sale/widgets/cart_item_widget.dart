import 'package:flutter/material.dart';
import 'package:syathiby/features/sale/models/cart_item_model.dart';

class CartItemWidget extends StatelessWidget {
  final CartItemModel cartItem;
  final Function(int quantity, String priceMode, String? priceArea, String? manualPrice)
      onUpdate;
  final VoidCallback onRemove;

  const CartItemWidget({
    super.key,
    required this.cartItem,
    required this.onUpdate,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cartItem.productName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Code: ${cartItem.productCode}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: onRemove,
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildPriceInfo(),
            const SizedBox(height: 8),
            _buildQuantityRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceInfo() {
    String priceLabel;
    if (cartItem.priceMode == PriceMode.retail) {
      priceLabel = 'Harga ${cartItem.selectedPriceArea?.name.replaceAll('area', '') ?? '1'}';
    } else {
      priceLabel = 'Harga Grosir';
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(priceLabel),
        Text(
          'Rp ${_formatNumber(cartItem.selectedPrice)}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildQuantityRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Qty:'),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: cartItem.quantity > 1
                  ? () => onUpdate(
                        cartItem.quantity - 1,
                        cartItem.priceMode == PriceMode.retail ? 'retail' : 'grosir',
                        cartItem.selectedPriceArea?.name,
                        cartItem.manualPrice,
                      )
                  : null,
            ),
            Text(
              _formatNumber(cartItem.quantity.toString()),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () => onUpdate(
                cartItem.quantity + 1,
                cartItem.priceMode == PriceMode.retail ? 'retail' : 'grosir',
                cartItem.selectedPriceArea?.name,
                cartItem.manualPrice,
              ),
            ),
          ],
        ),
        Text(
          'Subtotal: Rp ${_formatNumber(cartItem.subtotal.toStringAsFixed(0))}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
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