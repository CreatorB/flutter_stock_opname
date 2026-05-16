import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syathiby/features/sale/models/cart_item_model.dart';

class PriceSelectorWidget extends StatefulWidget {
  final CartItemModel cartItem;
  final Function(int quantity, String priceMode, String? priceArea, String? manualPrice)
      onUpdate;

  const PriceSelectorWidget({
    super.key,
    required this.cartItem,
    required this.onUpdate,
  });

  @override
  State<PriceSelectorWidget> createState() => _PriceSelectorWidgetState();
}

class _PriceSelectorWidgetState extends State<PriceSelectorWidget> {
  late TextEditingController _manualPriceController;
  late TextEditingController _qtyController;

  @override
  void initState() {
    super.initState();
    _manualPriceController =
        TextEditingController(text: widget.cartItem.manualPrice ?? '');
    _qtyController =
        TextEditingController(text: widget.cartItem.quantity.toString());
  }

  @override
  void dispose() {
    _manualPriceController.dispose();
    _qtyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'retail', label: Text('Retail')),
                  ButtonSegment(value: 'grosir', label: Text('Grosir')),
                ],
                selected: {
                  widget.cartItem.priceMode == PriceMode.retail
                      ? 'retail'
                      : 'grosir'
                },
                onSelectionChanged: (selection) {
                  widget.onUpdate(
                    widget.cartItem.quantity,
                    selection.first,
                    null,
                    null,
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (widget.cartItem.priceMode == PriceMode.retail)
          _buildRetailSelector()
        else
          _buildGrosirInput(),
        const SizedBox(height: 12),
        _buildQuantityInput(),
      ],
    );
  }

  Widget _buildRetailSelector() {
    return DropdownButtonFormField<String>(
      value: widget.cartItem.selectedPriceArea?.name ?? 'area1',
      decoration: const InputDecoration(
        labelText: 'Pilih Harga',
        border: OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem(value: 'area1', child: Text('Harga 1')),
        DropdownMenuItem(value: 'area2', child: Text('Harga 2')),
        DropdownMenuItem(value: 'area3', child: Text('Harga 3')),
      ],
      onChanged: (value) {
        if (value != null) {
          widget.onUpdate(
            widget.cartItem.quantity,
            'retail',
            value,
            null,
          );
        }
      },
    );
  }

  Widget _buildGrosirInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _manualPriceController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            labelText: 'Harga Grosir',
            border: const OutlineInputBorder(),
            errorText: _validateGrosirPrice(),
          ),
          onChanged: (value) {
            widget.onUpdate(
              widget.cartItem.quantity,
              'grosir',
              null,
              value,
            );
          },
        ),
        const SizedBox(height: 4),
        Text(
          'Min: Rp ${_formatNumber(widget.cartItem.buyPriceDouble.toStringAsFixed(0))}',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  String? _validateGrosirPrice() {
    if (_manualPriceController.text.isEmpty) return null;
    final price = double.tryParse(_manualPriceController.text);
    if (price != null && price < widget.cartItem.buyPriceDouble) {
      return 'Harga tidak boleh di bawah HPP';
    }
    return null;
  }

  Widget _buildQuantityInput() {
    return TextFormField(
      controller: _qtyController,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(4),
      ],
      decoration: const InputDecoration(
        labelText: 'Qty',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        final qty = int.tryParse(value ?? '');
        if (qty == null || qty < 1) return 'Min 1';
        if (qty > 9999) return 'Max 9999';
        return null;
      },
      onChanged: (value) {
        final qty = int.tryParse(value) ?? 1;
        widget.onUpdate(
          qty,
          widget.cartItem.priceMode == PriceMode.retail ? 'retail' : 'grosir',
          widget.cartItem.selectedPriceArea?.name,
          widget.cartItem.manualPrice,
        );
      },
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