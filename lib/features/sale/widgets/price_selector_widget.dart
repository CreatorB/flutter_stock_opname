import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syathiby/core/constants/color_constants.dart';
import 'package:syathiby/common/widgets/glow_card.dart';
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
  late TextEditingController _qtyDisplayController;

  @override
  void initState() {
    super.initState();
    _manualPriceController =
        TextEditingController(text: widget.cartItem.manualPrice ?? '');
    _qtyController =
        TextEditingController(text: widget.cartItem.quantity.toString());
    _qtyDisplayController = TextEditingController(
      text: _formatNumber(widget.cartItem.quantity.toString()),
    );
    _qtyController.addListener(_onQtyChanged);
    _qtyDisplayController.addListener(_onQtyDisplayChanged);
  }

  void _onQtyChanged() {
    final rawValue = _qtyController.text;
    final formatted = _formatNumber(rawValue);
    if (_qtyDisplayController.text != formatted) {
      _qtyDisplayController.text = formatted;
      _qtyDisplayController.selection = TextSelection.fromPosition(
        TextPosition(offset: _qtyDisplayController.text.length),
      );
    }
  }

  void _onQtyDisplayChanged() {
    final cursorPos = _qtyDisplayController.selection.baseOffset;
    final rawValue = _qtyDisplayController.text.replaceAll('.', '');
    if (_qtyController.text != rawValue) {
      _qtyController.text = rawValue;
      if (cursorPos <= _qtyDisplayController.text.length) {
        _qtyDisplayController.selection = TextSelection.fromPosition(
          TextPosition(offset: cursorPos),
        );
      }
    }
  }

  @override
  void dispose() {
    _qtyController.removeListener(_onQtyChanged);
    _qtyDisplayController.removeListener(_onQtyDisplayChanged);
    _manualPriceController.dispose();
    _qtyController.dispose();
    _qtyDisplayController.dispose();
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
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith((states) {
                    if (states.contains(MaterialState.selected)) {
                      return ColorConstants.darkPrimaryIcon;
                    }
                    return ColorConstants.darkTextField;
                  }),
                  foregroundColor: MaterialStatePropertyAll(Colors.white),
                  shape: MaterialStatePropertyAll(
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
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
    return Container(
      decoration: BoxDecoration(
        color: ColorConstants.darkTextField,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ColorConstants.glassBorder),
      ),
      child: DropdownButtonFormField<String>(
        value: widget.cartItem.selectedPriceArea?.name ?? 'area1',
        style: const TextStyle(color: ColorConstants.whiteText),
        dropdownColor: ColorConstants.glassCardSolid,
        decoration: const InputDecoration(
          labelText: 'Pilih Harga',
          labelStyle: TextStyle(color: ColorConstants.grayText),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      ),
    );
  }

  Widget _buildGrosirInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: ColorConstants.darkTextField,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: ColorConstants.glassBorder),
          ),
          child: TextFormField(
            controller: _manualPriceController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(color: ColorConstants.whiteText),
            cursorColor: ColorConstants.darkPrimaryIcon,
            decoration: InputDecoration(
              labelText: 'Harga Grosir',
              labelStyle: const TextStyle(color: ColorConstants.grayText),
              errorText: _validateGrosirPrice(),
              errorStyle: const TextStyle(color: ColorConstants.redError),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
        ),
        const SizedBox(height: 4),
        Text(
          'Min: Rp ${_formatNumber(widget.cartItem.buyPriceDouble.toStringAsFixed(0))}',
          style: const TextStyle(
            fontSize: 12,
            color: ColorConstants.grayText,
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
    return Container(
      decoration: BoxDecoration(
        color: ColorConstants.darkTextField,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ColorConstants.glassBorder),
      ),
      child: TextFormField(
        controller: _qtyDisplayController,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(7),
        ],
        style: const TextStyle(color: ColorConstants.whiteText),
        cursorColor: ColorConstants.darkPrimaryIcon,
        decoration: const InputDecoration(
          labelText: 'Qty',
          labelStyle: TextStyle(color: ColorConstants.grayText),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        validator: (value) {
          final raw = (value ?? '').replaceAll('.', '');
          final qty = int.tryParse(raw);
          if (qty == null || qty < 1) return 'Min 1';
          if (qty > 9999) return 'Max 9999';
          return null;
        },
        onChanged: (value) {
          final raw = value.replaceAll('.', '');
          final qty = int.tryParse(raw) ?? 1;
          widget.onUpdate(
            qty,
            widget.cartItem.priceMode == PriceMode.retail ? 'retail' : 'grosir',
            widget.cartItem.selectedPriceArea?.name,
            widget.cartItem.manualPrice,
          );
        },
      ),
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
