import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:syathiby/features/home/service/rack_model.dart';
import 'package:syathiby/features/opname/bloc/opname_bloc.dart';
import 'package:syathiby/features/opname/bloc/opname_event.dart';
import 'package:syathiby/features/opname/bloc/opname_state.dart';
import 'package:syathiby/features/opname/widgets/opname_item_widget.dart';

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
      appBar: AppBar(
        title: const Text('Stock Opname'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.qr_code_scanner), text: 'Manual'),
            Tab(icon: Icon(Icons.list), text: 'List'),
          ],
        ),
        actions: [
          _buildRackAction(),
          IconButton(
            icon: Icon(_isScanning ? Icons.close : Icons.qr_code_scanner),
            onPressed: () => _toggleScanner(context),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildManualTab(context),
          _buildListTab(context),
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
        return TextButton.icon(
          onPressed: () => _showRackPicker(context, state),
          icon: const Icon(Icons.inventory_2, color: Colors.white),
          label: Text(
            selected.raName,
            style: const TextStyle(color: Colors.white),
            overflow: TextOverflow.ellipsis,
          ),
        );
      },
    );
  }

  void _showRackPicker(BuildContext context, OpnameInProgress state) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Pilih Rak',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(height: 1),
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
                      color: selected ? Colors.blue : Colors.grey,
                    ),
                    title: Text(rack.raName),
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
        _buildSearchBar(),
        Expanded(
          child: BlocBuilder<OpnameBloc, OpnameState>(
            builder: (context, state) {
              if (state is OpnameLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is OpnameError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(state.message, textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => _opnameBloc
                            ?.add(const GetOpnameProductsEvent()),
                        child: const Text('Retry'),
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
                    ),
                  );
                }
                return _buildOpnameList(context, state.items);
              }
              return const Center(child: Text('Mulai stock opname'));
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
          return const Center(child: CircularProgressIndicator());
        }
        if (state is OpnameError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(state.message),
                ElevatedButton(
                  onPressed: () =>
                      _opnameBloc?.add(const GetOpnameProductsEvent()),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        if (state is OpnameInProgress) {
          return _buildOpnameList(context, state.items);
        }
        return const Center(child: Text('Pilih rak untuk memulai'));
      },
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Scan atau cari produk...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _clearSearch,
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onSubmitted: (value) {
          _searchDebounce?.cancel();
          _opnameBloc?.add(GetOpnameProductsEvent(searchValue: value.trim()));
        },
      ),
    );
  }

  Widget _buildOpnameList(BuildContext context, List<OpnameItemModel> items) {
    return ListView.builder(
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(50),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _showSubmitConfirmation(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('SUBMIT OPNAME'),
          ),
        ),
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
        title: const Text('Submit Opname?'),
        content: const Text('Pastikan semua data stock sudah benar.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _opnameBloc?.add(const SubmitOpnameEvent());
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}