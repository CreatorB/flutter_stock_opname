import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:syathiby/core/constants/color_constants.dart';
import 'package:syathiby/common/widgets/gradient_header.dart';
import 'package:syathiby/common/widgets/glow_card.dart';
import 'package:syathiby/common/widgets/gradient_button.dart';
import 'package:syathiby/features/home/service/rack_model.dart';
import 'package:syathiby/features/opname/bloc/opname_bloc.dart';
import 'package:syathiby/features/opname/bloc/opname_event.dart';
import 'package:syathiby/features/opname/bloc/opname_state.dart';
import 'package:syathiby/features/opname/widgets/opname_item_widget.dart';
import 'dart:async';

class OpnameView extends StatefulWidget {
  const OpnameView({super.key});

  @override
  State<OpnameView> createState() => _OpnameViewState();
}

class _OpnameViewState extends State<OpnameView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;
  OpnameBloc? _opnameBloc;
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_opnameBloc == null) {
      _opnameBloc = context.read<OpnameBloc>();
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final text = _searchController.text;
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      _opnameBloc?.add(GetOpnameProductsEvent(searchValue: text.trim()));
    });
  }

  void _clearSearch() {
    _searchDebounce?.cancel();
    _searchController.clear();
    _opnameBloc?.add(const GetOpnameProductsEvent(searchValue: ''));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          GradientHeader(
            title: 'Stock Opname',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildRackAction(),
                Container(
                  decoration: BoxDecoration(
                    color: ColorConstants.darkPrimaryIcon,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    icon: Icon(
                      _isScanning ? Icons.close : Icons.qr_code_scanner,
                      color: Colors.white,
                    ),
                    onPressed: () => _toggleScanner(context),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: ColorConstants.darkTextField,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: ColorConstants.glassBorder),
              ),
              child: Row(
                children: [
                  _buildTabButton('Manual', 0),
                  _buildTabButton('List', 1),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildManualTab(context),
                _buildListTab(context),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BlocBuilder<OpnameBloc, OpnameState>(
        builder: (context, state) {
          if (state is OpnameInProgress && _hasModifiedItems(state)) {
            return _buildSubmitBar(context, state);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildTabButton(String label, int index) {
    final isActive = _tabController.index == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => _tabController.animateTo(index),
        child: Container(
          decoration: BoxDecoration(
            color: isActive ? ColorConstants.darkPrimaryIcon : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : ColorConstants.grayText,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRackAction() {
    return BlocBuilder<OpnameBloc, OpnameState>(
      builder: (context, state) {
        if (state is! OpnameInProgress || state.racks.isEmpty) {
          return const SizedBox.shrink();
        }
        final selected = state.racks.firstWhere(
          (r) => r.raId == state.selectedRaId,
          orElse: () => state.racks.first,
        );
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: TextButton(
            onPressed: () => _showRackPicker(context, state),
            child: Text(
              selected.raName,
              style: const TextStyle(color: Colors.white),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );
      },
    );
  }

  void _showRackPicker(BuildContext context, OpnameInProgress state) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: ColorConstants.glassCardSolid,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Pilih Rak',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ColorConstants.whiteText,
                ),
              ),
            ),
            const Divider(height: 1, color: ColorConstants.glassBorder),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: state.racks.length,
                itemBuilder: (_, i) {
                  final rack = state.racks[i];
                  final selected = rack.raId == state.selectedRaId;
                  return ListTile(
                    leading: Icon(
                      selected ? Icons.check_circle : Icons.inventory_2,
                      color: selected
                          ? ColorConstants.darkPrimaryIcon
                          : ColorConstants.grayText,
                    ),
                    title: Text(
                      rack.raName,
                      style: TextStyle(
                        color: selected
                            ? ColorConstants.whiteText
                            : ColorConstants.grayText,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      _opnameBloc?.add(ChangeRackEvent(rack.raId));
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManualTab(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
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
                hintText: 'Scan atau cari produk...',
                hintStyle: const TextStyle(color: ColorConstants.grayText),
                prefixIcon:
                    const Icon(Icons.search, color: ColorConstants.darkPrimaryIcon),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: ColorConstants.darkPrimaryIcon),
                        onPressed: _clearSearch,
                      )
                    : null,
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              onSubmitted: (value) {
                _searchDebounce?.cancel();
                _opnameBloc?.add(
                    GetOpnameProductsEvent(searchValue: value.trim()));
              },
            ),
          ),
        ),
        Expanded(
          child: BlocBuilder<OpnameBloc, OpnameState>(
            builder: (context, state) {
              if (state is OpnameLoading) {
                return const Center(
                    child: CircularProgressIndicator(
                        color: ColorConstants.darkPrimaryIcon));
              }
              if (state is OpnameError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: ColorConstants.whiteText),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => _opnameBloc
                            ?.add(const GetOpnameProductsEvent()),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: ColorConstants.darkPrimaryIcon),
                        child: const Text(
                            'Retry', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );
              }
              if (state is OpnameInProgress) {
                if (state.items.isEmpty) {
                  return const Center(
                    child: Text(
                      'Produk tidak ditemukan.\nCoba ketik di search bar (mis. "a")',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: ColorConstants.whiteText),
                    ),
                  );
                }
                return _buildOpnameList(context, state.items);
              }
              return const Center(
                  child: Text('Mulai stock opname',
                      style: TextStyle(color: ColorConstants.whiteText)));
            },
          ),
        ),
      ],
    );
  }

  Widget _buildListTab(BuildContext context) {
    return BlocBuilder<OpnameBloc, OpnameState>(
      builder: (context, state) {
        if (state is OpnameLoading) {
          return const Center(
              child: CircularProgressIndicator(
                  color: ColorConstants.darkPrimaryIcon));
        }
        if (state is OpnameError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  state.message,
                  style: const TextStyle(color: ColorConstants.whiteText),
                ),
                ElevatedButton(
                  onPressed: () =>
                      _opnameBloc?.add(const GetOpnameProductsEvent()),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: ColorConstants.darkPrimaryIcon),
                  child:
                      const Text('Retry', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
        }
        if (state is OpnameInProgress) {
          return _buildOpnameList(context, state.items);
        }
        return const Center(
            child: Text('Pilih rak untuk memulai',
                style: TextStyle(color: ColorConstants.whiteText)));
      },
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
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
            hintText: 'Scan atau cari produk...',
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
            _opnameBloc?.add(GetOpnameProductsEvent(searchValue: value.trim()));
          },
        ),
      ),
    );
  }

  Widget _buildOpnameList(BuildContext context, List<OpnameItemModel> items) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return OpnameItemWidget(
          item: item,
          onActualStockChanged: (value) {
            _opnameBloc?.add(UpdateActualStockEvent(
              productId: item.productId,
              actualStock: value,
            ));
          },
        );
      },
    );
  }

  Widget _buildSubmitBar(BuildContext context, OpnameInProgress state) {
    return GlowCard(
      padding: const EdgeInsets.all(16),
      borderColor: ColorConstants.greenPrice.withOpacity(0.3),
      child: GradientButton(
        text: 'SUBMIT OPNAME',
        onPressed: () => _showSubmitConfirmation(context),
        gradientColors: [ColorConstants.greenPrice, ColorConstants.secondaryBlue],
      ),
    );
  }

  bool _hasModifiedItems(OpnameInProgress state) {
    return state.items.any((item) => item.actualStockInt > 0);
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

  void _showSubmitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ColorConstants.glassCardSolid,
        title: const Text(
          'Submit Opname?',
          style: TextStyle(color: ColorConstants.whiteText),
        ),
        content: const Text(
          'Pastikan semua data stock sudah benar.',
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
              Navigator.pop(ctx);
              _opnameBloc?.add(const SubmitOpnameEvent());
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: ColorConstants.darkPrimaryIcon),
            child:
                const Text('Submit', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
