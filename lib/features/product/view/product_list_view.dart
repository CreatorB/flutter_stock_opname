import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syathiby/core/constants/color_constants.dart';
import 'package:syathiby/common/widgets/gradient_header.dart';
import 'package:syathiby/common/widgets/glow_card.dart';
import 'package:syathiby/features/product/bloc/product_bloc.dart';
import 'package:syathiby/features/product/bloc/product_event.dart';
import 'package:syathiby/features/product/bloc/product_state.dart';
import 'package:syathiby/features/product/view/product_detail_view.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class ProductListView extends StatefulWidget {
  const ProductListView({super.key});

  @override
  State<ProductListView> createState() => _ProductListViewState();
}

class _ProductListViewState extends State<ProductListView> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(const GetProductsEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<ProductBloc>().add(GetProductsEvent(searchValue: query));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          GradientHeader(title: 'Produk', subtitle: 'Kelola data produk & stok'),
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
                      onChanged: _onSearchChanged,
                      style: const TextStyle(color: ColorConstants.whiteText),
                      cursorColor: ColorConstants.darkPrimaryIcon,
                      decoration: InputDecoration(
                        hintText: 'Cari produk...',
                        hintStyle: const TextStyle(color: ColorConstants.grayText),
                        prefixIcon:
                            const Icon(Icons.search, color: ColorConstants.darkPrimaryIcon),
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: ColorConstants.darkPrimaryIcon,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.add, color: Colors.white),
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
                    child: CircularProgressIndicator(
                      color: ColorConstants.darkPrimaryIcon,
                    ),
                  );
                } else if (state is ProductError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: ColorConstants.redError,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          state.message,
                          style:
                              const TextStyle(color: ColorConstants.whiteText),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<ProductBloc>().add(
                                  GetProductsEvent(
                                    searchValue: _searchController.text,
                                  ),
                                );
                          },
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
                } else if (state is ProductLoaded) {
                  if (state.products.isEmpty) {
                    return const Center(
                      child: Text(
                        'No products found',
                        style: TextStyle(color: ColorConstants.whiteText),
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<ProductBloc>().add(
                            GetProductsEvent(
                              searchValue: _searchController.text,
                            ),
                          );
                    },
                    color: ColorConstants.darkPrimaryIcon,
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: state.products.length,
                      itemBuilder: (context, index) {
                        final product = state.products[index];
                        return _buildProductItem(product);
                      },
                    ),
                  );
                }
                return const Center(
                  child: Text(
                    'Start searching...',
                    style: TextStyle(color: ColorConstants.whiteText),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductItem(dynamic product) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    final stock = int.tryParse(product.stock ?? '0') ?? 0;
    final price = double.tryParse(product.priceArea1 ?? '0') ?? 0;

    return GlowCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailView(product: product),
          ),
        );
      },
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
                  product.pName ?? 'Unknown Product',
                  style: const TextStyle(
                    color: ColorConstants.whiteText,
                    fontSize: 14,
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
                      fontSize: 11,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      currencyFormat.format(price),
                      style: const TextStyle(
                        color: ColorConstants.darkPrimaryIcon,
                        fontSize: 14,
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
          const Icon(Icons.chevron_right, color: ColorConstants.secondaryBlue),
        ],
      ),
    );
  }
}
