import 'package:flutter/material.dart';
import 'package:syathiby/core/constants/color_constants.dart';
import 'package:syathiby/common/widgets/glow_card.dart';
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
    return GlowCard(
      margin: const EdgeInsets.only(bottom: 12),
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
                        color: ColorConstants.whiteText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Code: ${cartItem.productCode}',
                      style: const TextStyle(
                        color: ColorConstants.grayText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: ColorConstants.redError),
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
        Text(priceLabel, style: const TextStyle(color: ColorConstants.grayText)),
        Text(
          'Rp ${_formatNumber(cartItem.selectedPrice)}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: ColorConstants.greenPrice,
          ),
        ),
      ],
    );
  }

  Widget _buildQuantityRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Qty:', style: TextStyle(color: ColorConstants.grayText)),
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: ColorConstants.darkTextField,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: ColorConstants.glassBorder),
              ),
              child: IconButton(
                icon: const Icon(Icons.remove, size: 18, color: ColorConstants.darkPrimaryIcon),
                onPressed: cartItem.quantity > 1
                    ? () => onUpdate(
                          cartItem.quantity - 1,
                          cartItem.priceMode == PriceMode.retail ? 'retail' : 'grosir',
                          cartItem.selectedPriceArea?.name,
                          cartItem.manualPrice,
                        )
                    : null,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _formatNumber(cartItem.quantity.toString()),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ColorConstants.whiteText,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: ColorConstants.darkTextField,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: ColorConstants.glassBorder),
              ),
              child: IconButton(
                icon: const Icon(Icons.add, size: 18, color: ColorConstants.darkPrimaryIcon),
                onPressed: () => onUpdate(
                  cartItem.quantity + 1,
                  cartItem.priceMode == PriceMode.retail ? 'retail' : 'grosir',
                  cartItem.selectedPriceArea?.name,
                  cartItem.manualPrice,
                ),
              ),
            ),
          ],
        ),
        Text(
          'Rp ${_formatNumber(cartItem.subtotal.toStringAsFixed(0))}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: ColorConstants.whiteText,
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
