import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:syathiby/core/di/injection.dart';
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
  bool _isScanning = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ProductBloc>()..add(const GetProductsEvent()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Penjualan'),
          actions: [
            BlocBuilder<SaleBloc, SaleState>(
              builder: (context, state) {
                if (state is SaleInProgress && state.cartItems.isNotEmpty) {
                  return Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.shopping_cart),
                        onPressed: () => _navigateToCart(context),
                      ),
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${state.cartItems.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }
                return IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  onPressed: null,
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            _buildSearchBar(),
            Expanded(
              child: BlocBuilder<ProductBloc, ProductState>(
                builder: (context, state) {
                  if (state is ProductLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is ProductError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(state.message),
                          ElevatedButton(
                            onPressed: () => context
                                .read<ProductBloc>()
                                .add(const GetProductsEvent()),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }
                  if (state is ProductLoaded) {
                    return _buildProductList(context, state.products);
                  }
                  return const Center(child: Text('No data'));
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _toggleScanner(context),
          child: Icon(_isScanning ? Icons.close : Icons.qr_code_scanner),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Cari produk...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    context
                        .read<ProductBloc>()
                        .add(const GetProductsEvent());
                  },
                )
              : null,
        ),
        onSubmitted: (value) {
          context.read<ProductBloc>().add(GetProductsEvent(searchValue: value));
        },
      ),
    );
  }

  Widget _buildProductList(BuildContext context, List products) {
    if (products.isEmpty) {
      return const Center(child: Text('Produk tidak ditemukan'));
    }

    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return _buildProductItem(context, product);
      },
    );
  }

  Widget _buildProductItem(BuildContext context, dynamic product) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: const Icon(Icons.inventory_2),
        title: Text(product.pName ?? 'Unknown'),
        subtitle: Text(
          'Rp ${_formatNumber((product.priceArea1 ?? '0').toString())}',
          style: const TextStyle(color: Colors.green),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.add_shopping_cart),
          onPressed: () => _addToCart(context, product),
        ),
        onTap: () => _showPriceSelector(context, product),
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
              ),
            ),
            const SizedBox(height: 16),
            StatefulBuilder(
              builder: (ctx, setModalState) {
                return PriceSelectorWidget(
                  cartItem: cartItem,
                  onUpdate: (qty, priceMode, priceArea, manualPrice) {
                    cartItem = cartItem.copyWith(
                      priceMode: priceMode == 'grosir' ? PriceMode.grosir : PriceMode.retail,
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
                child: const Text('Tambah ke Keranjang'),
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
        ? state.cartItems.indexWhere((item) => item.productId == (product.id ?? ''))
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
          child: SizedBox(
            width: 300,
            height: 400,
            child: MobileScanner(
              onDetect: (capture) {
                final barcode = capture.barcodes.firstOrNull;
                if (barcode?.rawValue != null) {
                  _searchController.text = barcode!.rawValue!;
                  context
                      .read<ProductBloc>()
                      .add(GetProductsEvent(searchValue: barcode.rawValue!));
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