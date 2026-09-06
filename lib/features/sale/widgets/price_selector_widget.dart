import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syathiby/core/constants/color_constants.dart';
import 'package:syathiby/core/di/injection.dart';
import 'package:syathiby/core/services/shared_preferences_service.dart';
import 'package:syathiby/features/product/models/price_list_model.dart';
import 'package:syathiby/features/product/service/product_service.dart';
import 'package:syathiby/features/sale/models/cart_item_model.dart';

class PriceSelectorWidget extends StatefulWidget {
  final CartItemModel cartItem;
  final Function(
    int quantity,
    String priceMode,
    String? priceArea,
    int? priceListIndex,
    String? manualPrice,
  ) onUpdate;

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

  bool _loadingRetail = false;
  bool _loadingGrosir = false;
  String? _loadError;
  PriceListModel? _retailPriceList;
  PriceListModel? _grosirPriceList;
  int? _selectedPriceListIndex;

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
    _retailPriceList = widget.cartItem.retailPriceList;
    _grosirPriceList = widget.cartItem.grosirPriceList;
    _selectedPriceListIndex = widget.cartItem.selectedPriceListIndex;
    _qtyController.addListener(_onQtyChanged);
    _qtyDisplayController.addListener(_onQtyDisplayChanged);
    _loadPriceLists();
  }

  @override
  void didUpdateWidget(covariant PriceSelectorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cartItem.productId != widget.cartItem.productId) {
      _retailPriceList = widget.cartItem.retailPriceList;
      _grosirPriceList = widget.cartItem.grosirPriceList;
      _selectedPriceListIndex = widget.cartItem.selectedPriceListIndex;
      _loadPriceLists();
    }
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

  Future<void> _loadPriceLists() async {
    final productId = widget.cartItem.productId;
    if (productId.isEmpty) return;
    final brId = SharedPreferencesService.instance
        .getData<String>(PreferenceKey.branchId);
    if (brId == null || brId.isEmpty) {
      setState(() {
        _loadError = 'Branch ID tidak ditemukan';
      });
      return;
    }
    final service = sl<ProductService>();
    await _fetchOne(service, brId, productId, 0, isRetail: true);
    if (!mounted) return;
    await _fetchOne(service, brId, productId, 1, isRetail: false);
  }

  Future<void> _fetchOne(
    ProductService service,
    String brId,
    String pId,
    int isGrosir, {
    required bool isRetail,
  }) async {
    if (isRetail) {
      setState(() => _loadingRetail = true);
    } else {
      setState(() => _loadingGrosir = true);
    }
    try {
      final response = await service.getPriceList(
        brId: brId,
        pId: pId,
        isGrosir: isGrosir,
      );
      if (!mounted) return;
      if (response.statusCode == 200 && response.data != null) {
        setState(() {
          if (isRetail) {
            _retailPriceList = response.data;
          } else {
            _grosirPriceList = response.data;
          }
          _loadError = null;
          if (_selectedPriceListIndex == null) {
            _selectedPriceListIndex = 0;
          }
        });
      } else {
        setState(() {
          _loadError = response.message ?? 'Gagal memuat daftar harga';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = 'Error: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          if (isRetail) {
            _loadingRetail = false;
          } else {
            _loadingGrosir = false;
          }
        });
      }
    }
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
                  foregroundColor: const MaterialStatePropertyAll(Colors.white),
                  shape: MaterialStatePropertyAll(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                onSelectionChanged: (selection) {
                  setState(() {
                    _selectedPriceListIndex = 0;
                  });
                  widget.onUpdate(
                    widget.cartItem.quantity,
                    selection.first,
                    null,
                    0,
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
          _buildGrosirSelector(),
        if (_loadError != null) ...[
          const SizedBox(height: 8),
          Text(
            _loadError!,
            style: const TextStyle(
              fontSize: 12,
              color: ColorConstants.redError,
            ),
          ),
        ],
        const SizedBox(height: 12),
        _buildQuantityInput(),
      ],
    );
  }

  Widget _buildRetailSelector() {
    final items = _retailPriceList?.retailDisplay ?? const [];
    final loading = _loadingRetail;

    if (items.isEmpty) {
      return _buildPriceDropdownFallback(
        label: 'Pilih Harga',
        isLoading: loading,
        emptyText: 'Daftar harga retail tidak tersedia',
      );
    }

    return _buildPriceDropdown(
      label: 'Pilih Harga',
      items: items,
      isLoading: loading,
    );
  }

  Widget _buildGrosirSelector() {
    final items = _grosirPriceList?.grosirDisplay ?? const [];
    final loading = _loadingGrosir;

    if (items.isEmpty) {
      return _buildPriceDropdownFallback(
        label: 'Harga Grosir',
        isLoading: loading,
        emptyText: 'Daftar harga grosir tidak tersedia',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPriceDropdown(
          label: 'Harga Grosir',
          items: items,
          isLoading: loading,
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

  Widget _buildPriceDropdown({
    required String label,
    required List<PriceListItem> items,
    required bool isLoading,
  }) {
    final selectedIdx =
        _selectedPriceListIndex != null && _selectedPriceListIndex! < items.length
            ? _selectedPriceListIndex!
            : 0;
    final isGrosir = widget.cartItem.priceMode == PriceMode.grosir;

    return Container(
      decoration: BoxDecoration(
        color: ColorConstants.darkTextField,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ColorConstants.glassBorder),
      ),
      child: DropdownButtonFormField<int>(
        value: selectedIdx,
        style: const TextStyle(color: ColorConstants.whiteText),
        dropdownColor: ColorConstants.glassCardSolid,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: ColorConstants.grayText),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          suffixIcon: isLoading
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: ColorConstants.darkPrimaryIcon,
                    ),
                  ),
                )
              : null,
        ),
        items: List.generate(items.length, (index) {
          final item = items[index];
          final priceText = _formatNumber(item.price ?? '0');
          final qtyText = item.qtyInt > 0 ? ' (min ${item.qtyInt})' : '';
          final labelNum = isGrosir ? (items.length - index) : (index + 1);
          return DropdownMenuItem<int>(
            value: index,
            child: Text('Harga $labelNum - Rp $priceText$qtyText'),
          );
        }),
        onChanged: isLoading
            ? null
            : (value) {
                if (value == null) return;
                setState(() {
                  _selectedPriceListIndex = value;
                });
                final mode =
                    widget.cartItem.priceMode == PriceMode.grosir
                        ? 'grosir'
                        : 'retail';
                widget.onUpdate(
                  widget.cartItem.quantity,
                  mode,
                  null,
                  value,
                  null,
                );
              },
      ),
    );
  }

  Widget _buildPriceDropdownFallback({
    required String label,
    required bool isLoading,
    required String emptyText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: ColorConstants.darkTextField,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: ColorConstants.glassBorder),
          ),
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  isLoading ? 'Memuat daftar harga...' : emptyText,
                  style: const TextStyle(
                    color: ColorConstants.grayText,
                    fontSize: 14,
                  ),
                ),
              ),
              if (isLoading)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: ColorConstants.darkPrimaryIcon,
                  ),
                )
              else
                IconButton(
                  tooltip: 'Refresh',
                  icon: const Icon(
                    Icons.refresh,
                    color: ColorConstants.darkPrimaryIcon,
                    size: 20,
                  ),
                  onPressed: _loadPriceLists,
                ),
            ],
          ),
        ),
        if (widget.cartItem.priceMode == PriceMode.grosir) ...[
          const SizedBox(height: 4),
          Text(
            'Min: Rp ${_formatNumber(widget.cartItem.buyPriceDouble.toStringAsFixed(0))}',
            style: const TextStyle(
              fontSize: 12,
              color: ColorConstants.grayText,
            ),
          ),
        ],
      ],
    );
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
          final mode = widget.cartItem.priceMode == PriceMode.grosir
              ? 'grosir'
              : 'retail';
          widget.onUpdate(
            qty,
            mode,
            null,
            _selectedPriceListIndex,
            null,
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
