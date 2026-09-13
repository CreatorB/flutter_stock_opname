import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syathiby/core/constants/color_constants.dart';
import 'package:syathiby/common/widgets/glow_card.dart';
import 'package:syathiby/features/opname/bloc/opname_state.dart';

class OpnameItemWidget extends StatefulWidget {
  final OpnameItemModel item;
  final Function(String) onActualStockChanged;

  const OpnameItemWidget({
    super.key,
    required this.item,
    required this.onActualStockChanged,
  });

  @override
  State<OpnameItemWidget> createState() => _OpnameItemWidgetState();
}

class _OpnameItemWidgetState extends State<OpnameItemWidget> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.item.actualStock);
  }

  @override
  void didUpdateWidget(covariant OpnameItemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Qty bisa berubah dari luar (mis. hasil scan atau daftar dimuat ulang
    // setelah pencarian). Jangan timpa saat user sedang mengetik.
    if (widget.item.actualStock != _controller.text && !_focusNode.hasFocus) {
      _controller.text = widget.item.actualStock;
      _controller.selection =
          TextSelection.collapsed(offset: _controller.text.length);
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

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
                      widget.item.productName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: ColorConstants.whiteText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Code: ${widget.item.productCode}',
                      style: const TextStyle(
                        color: ColorConstants.grayText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Stock Sistem',
                      style: TextStyle(
                        color: ColorConstants.grayText,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      widget.item.systemStock,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: ColorConstants.whiteText,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Stock Actual',
                      style: TextStyle(
                        color: ColorConstants.grayText,
                        fontSize: 12,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: ColorConstants.darkTextField,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: ColorConstants.glassBorder),
                      ),
                      child: TextFormField(
                        controller: _controller,
                        focusNode: _focusNode,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
                        ],
                        style: const TextStyle(color: ColorConstants.whiteText),
                        cursorColor: ColorConstants.darkPrimaryIcon,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: '0',
                          hintStyle: TextStyle(color: ColorConstants.grayText),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        onChanged: widget.onActualStockChanged,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Selisih',
                      style: TextStyle(
                        color: ColorConstants.grayText,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      _getDifferenceText(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _getDifferenceColor(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getDifferenceText() {
    final diff = widget.item.difference;
    if (diff == 0) return '0';
    return diff > 0 ? '+$diff' : '$diff';
  }

  Color _getDifferenceColor() {
    final diff = widget.item.difference;
    if (diff == 0) return ColorConstants.grayText;
    return diff > 0 ? ColorConstants.greenPrice : ColorConstants.redError;
  }
}
