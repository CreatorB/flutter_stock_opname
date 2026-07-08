import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:syathiby/core/di/injection.dart';
import 'package:syathiby/core/constants/color_constants.dart';
import 'package:syathiby/common/widgets/gradient_header.dart';
import 'package:syathiby/common/widgets/glow_card.dart';
import 'package:syathiby/features/product/bloc/product_bloc.dart';
import 'package:syathiby/features/product/bloc/product_event.dart';
import 'package:syathiby/features/product/bloc/product_state.dart';
import 'package:syathiby/features/sale/bloc/sale_bloc.dart';
import 'package:syathiby/features/sale/bloc/sale_event.dart';
import 'package:syathiby/features/sale/bloc/sale_state.dart';
import 'package:syathiby/features/sale/models/cart_item_model.dart';
import 'package:syathiby/features/sale/view/cart_view.dart';
import 'package:syathiby/features/sale/widgets/price_selector_widget.dart';

class SaleView extends StatefulWidget {
  const SaleView({super.key});

  @override
  State<SaleView> createState() => _SaleViewState();
}

class _SaleViewState extends State<SaleView> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;
  bool _isScanning = false;
  ProductBloc? _productBloc;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      if (!mounted) return;
      setState(() {});
      _onSearchChanged(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      _productBloc?.add(GetProductsEvent(searchValue: value.trim()));
    });
  }

  void _clearSearch() {
    _searchDebounce?.cancel();
    _searchController.clear();
    _productBloc?.add(const GetProductsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final bloc = sl<ProductBloc>()..add(const GetProductsEvent());
        _productBloc = bloc;
        return bloc;
      },
      child: Scaffold(
        body: Column(
          children: [
            GradientHeader(
              title: 'Penjualan',
              subtitle: 'Kelola transaksi penjualan',
              trailing: BlocBuilder<SaleBloc, SaleState>(
                builder: (context, state) {
                  if (state is SaleInProgress && state.cartItems.isNotEmpty) {
                    return Stack(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
                          onPressed: () => _navigateToCart(context),
                        ),
                        Positioned(
                          right: 6,
                          top: 6,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: ColorConstants.redError,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${state.cartItems.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                  return IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white70),
                    onPressed: null,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: ColorConstants.darkTextField,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: ColorConstants.glassBorder),
                      ),
                      child: TextField(
                        controller: _searchController,
                        textInputAction: TextInputAction.search,
                        style: const TextStyle(color: ColorConstants.whiteText),
                        cursorColor: ColorConstants.darkPrimaryIcon,
                        decoration: InputDecoration(
                          hintText: 'Cari produk...',
                          hintStyle: const TextStyle(color: ColorConstants.grayText),
                          prefixIcon: const Icon(Icons.search, color: ColorConstants.darkPrimaryIcon),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, color: ColorConstants.darkPrimaryIcon),
                                  onPressed: _clearSearch,
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                        onSubmitted: (value) {
                          _searchDebounce?.cancel();
                          _productBloc?.add(GetProductsEvent(searchValue: value.trim()));
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: ColorConstants.darkPrimaryIcon.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: ColorConstants.darkPrimaryIcon),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.filter_list, color: ColorConstants.darkPrimaryIcon),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<ProductBloc, ProductState>(
                builder: (context, state) {
                  if (state is ProductLoading) {
                    return const Center(
                      child: CircularProgressIndicator(color: ColorConstants.darkPrimaryIcon),
                    );
                  }
                  if (state is ProductError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            state.message,
                            style: const TextStyle(color: ColorConstants.whiteText),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => context
                                .read<ProductBloc>()
                                .add(const GetProductsEvent()),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorConstants.darkPrimaryIcon,
                            ),
                            child: const Text(
                              'Retry',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  if (state is ProductLoaded) {
                    return _buildProductList(context, state.products);
                  }
                  return const Center(
                    child: Text(
                      'No data',
                      style: TextStyle(color: ColorConstants.whiteText),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: Container(
          decoration: BoxDecoration(
            color: ColorConstants.darkPrimaryIcon,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: ColorConstants.darkPrimaryIcon.withOpacity(0.4),
                blurRadius: 12,
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(
              _isScanning ? Icons.close : Icons.qr_code_scanner,
              color: Colors.white,
            ),
            onPressed: () => _toggleScanner(context),
          ),
        ),
      ),
    );
  }

  Widget _buildProductList(BuildContext context, List products) {
    if (products.isEmpty) {
      return const Center(
        child: Text(
          'Produk tidak ditemukan',
          style: TextStyle(color: ColorConstants.whiteText),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return _buildProductItem(context, product);
      },
    );
  }

  Widget _buildProductItem(BuildContext context, dynamic product) {
    final price = double.tryParse(product.priceArea1 ?? '0') ?? 0;
    final stock = int.tryParse(product.stock ?? '0') ?? 0;

    return GlowCard(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 12),
      onTap: () => _showPriceSelector(context, product),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: ColorConstants.darkTextField,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              color: ColorConstants.darkPrimaryIcon,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.pName ?? 'Unknown',
                  style: const TextStyle(
                    color: ColorConstants.whiteText,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: ColorConstants.secondaryBlue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    product.pCode ?? '-',
                    style: const TextStyle(
                      color: ColorConstants.secondaryBlue,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Rp ${_formatNumber(price.toString())}',
                      style: const TextStyle(
                        color: ColorConstants.darkPrimaryIcon,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: stock > 0
                            ? ColorConstants.greenStockBadge
                            : ColorConstants.redStockBadge,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Stock: $stock',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: ColorConstants.secondaryBlue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.add_shopping_cart,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () => _addToCart(context, product),
            ),
          ),
        ],
      ),
    );
  }

  void _addToCart(BuildContext context, dynamic product) {
    context.read<SaleBloc>().add(AddToCartEvent(
          productId: product.id ?? '',
          productCode: product.pCode ?? '',
          productName: product.pName ?? '',
          priceArea1: product.priceArea1,
          priceArea2: product.priceArea2,
          priceArea3: product.priceArea3,
          buyPrice: product.buyPrice,
        ));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.pName} ditambahkan'),
        backgroundColor: ColorConstants.greenPrice,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _showPriceSelector(BuildContext context, dynamic product) {
    CartItemModel cartItem = CartItemModel(
      productId: product.id ?? '',
      productCode: product.pCode ?? '',
      productName: product.pName ?? '',
      priceArea1: product.priceArea1,
      priceArea2: product.priceArea2,
      priceArea3: product.priceArea3,
      buyPrice: product.buyPrice,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: ColorConstants.glassCardSolid,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.pName ?? '',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ColorConstants.whiteText,
              ),
            ),
            const SizedBox(height: 16),
            StatefulBuilder(
              builder: (ctx, setModalState) {
                return PriceSelectorWidget(
                  cartItem: cartItem,
                  onUpdate: (qty, priceMode, priceArea, manualPrice) {
                    cartItem = cartItem.copyWith(
                      priceMode:
                          priceMode == 'grosir' ? PriceMode.grosir : PriceMode.retail,
                      selectedPriceArea: priceArea != null
                          ? PriceArea.values.firstWhere(
                              (e) => e.name == priceArea,
                              orElse: () => PriceArea.area1,
                            )
                          : null,
                      manualPrice: manualPrice,
                      quantity: qty,
                    );
                    setModalState(() {});
                    context.read<SaleBloc>().add(UpdateCartItemEvent(
                      productId: product.id ?? '',
                      quantity: qty,
                      priceMode: priceMode,
                      selectedPriceArea: priceArea,
                      manualPrice: manualPrice,
                    ));
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _addToCartWithDetails(
                    ctx,
                    product: product,
                    priceMode: cartItem.priceMode,
                    selectedPriceArea: cartItem.selectedPriceArea,
                    manualPrice: cartItem.manualPrice,
                    quantity: cartItem.quantity,
                  );
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorConstants.darkPrimaryIcon,
                ),
                child: const Text(
                  'Tambah ke Keranjang',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _addToCartWithDetails(
    BuildContext context, {
    required dynamic product,
    required PriceMode priceMode,
    required PriceArea? selectedPriceArea,
    required String? manualPrice,
    required int quantity,
  }) {
    String? priceArea;
    String? priceValue;

    if (priceMode == PriceMode.retail) {
      switch (selectedPriceArea) {
        case PriceArea.area1:
          priceArea = 'area1';
          priceValue = product.priceArea1;
          break;
        case PriceArea.area2:
          priceArea = 'area2';
          priceValue = product.priceArea2;
          break;
        case PriceArea.area3:
          priceArea = 'area3';
          priceValue = product.priceArea3;
          break;
        default:
          priceArea = 'area1';
          priceValue = product.priceArea1;
      }
    } else {
      priceArea = 'grosir';
      priceValue = manualPrice ?? '0';
    }

    final state = context.read<SaleBloc>().state;
    final existingIndex = state is SaleInProgress
        ? state.cartItems.indexWhere(
            (item) => item.productId == (product.id ?? ''),
          )
        : -1;

    if (existingIndex < 0) {
      context.read<SaleBloc>().add(AddToCartEvent(
        productId: product.id ?? '',
        productCode: product.pCode ?? '',
        productName: product.pName ?? '',
        priceArea1: product.priceArea1,
        priceArea2: product.priceArea2,
        priceArea3: product.priceArea3,
        buyPrice: product.buyPrice,
      ));
    }

    context.read<SaleBloc>().add(UpdateCartItemEvent(
      productId: product.id ?? '',
      quantity: quantity,
      priceMode: priceMode == PriceMode.grosir ? 'grosir' : 'retail',
      selectedPriceArea: priceArea,
      manualPrice: priceMode == PriceMode.grosir ? priceValue : null,
    ));
  }

  void _toggleScanner(BuildContext context) {
    setState(() {
      _isScanning = !_isScanning;
    });

    if (_isScanning) {
      showDialog(
        context: context,
        builder: (ctx) => Dialog(
          backgroundColor: ColorConstants.glassCardSolid,
          child: SizedBox(
            width: 300,
            height: 400,
            child: MobileScanner(
              onDetect: (capture) {
                final barcode = capture.barcodes.firstOrNull;
                if (barcode?.rawValue != null) {
                  _searchController.text = barcode!.rawValue!;
                  _productBloc?.add(
                    GetProductsEvent(searchValue: barcode.rawValue!),
                  );
                  Navigator.pop(ctx);
                  setState(() => _isScanning = false);
                }
              },
            ),
          ),
        ),
      );
    }
  }

  void _navigateToCart(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CartView()),
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
