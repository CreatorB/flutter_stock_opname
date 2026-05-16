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

class _OpnameViewState extends State<OpnameView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<OpnameBloc>().add(const GetOpnameProductsEvent());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
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
          _buildRackDropdown(),
          IconButton(
            icon: const Icon(Icons.photo_library),
            onPressed: () => _pickImage(context),
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

  Widget _buildRackDropdown() {
    return BlocBuilder<OpnameBloc, OpnameState>(
      builder: (context, state) {
        if (state is OpnameInProgress && state.racks.isNotEmpty) {
          final selectedRack = state.racks.firstWhere(
            (r) => r.raId == state.selectedRaId,
            orElse: () => state.racks.first,
          );
          return PopupMenuButton<RackModel>(
            icon: const Icon(Icons.inventory_2),
            onSelected: (rack) {
              context.read<OpnameBloc>().add(ChangeRackEvent(rack.raId));
            },
            itemBuilder: (context) => state.racks.map((rack) {
              return PopupMenuItem<RackModel>(
                value: rack,
                child: Row(
                  children: [
                    if (rack.raId == state.selectedRaId)
                      const Icon(Icons.check, size: 18)
                    else
                      const SizedBox(width: 18),
                    const SizedBox(width: 8),
                    Text(rack.raName),
                  ],
                ),
              );
            }).toList(),
          );
        }
        return const SizedBox.shrink();
      },
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
                      Text(state.message),
                      ElevatedButton(
                        onPressed: () => context
                            .read<OpnameBloc>()
                            .add(const GetOpnameProductsEvent()),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }
              if (state is OpnameInProgress) {
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
                  onPressed: () => context
                      .read<OpnameBloc>()
                      .add(const GetOpnameProductsEvent()),
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
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Scan atau cari produk...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onSubmitted: (value) {
                context.read<OpnameBloc>().add(GetOpnameProductsEvent(
                  searchValue: value,
                ));
              },
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(_isScanning ? Icons.close : Icons.qr_code_scanner),
            onPressed: () => _toggleScanner(context),
          ),
        ],
      ),
    );
  }

  Widget _buildOpnameList(BuildContext context, List<OpnameItemModel> items) {
    if (items.isEmpty) {
      return const Center(child: Text('Produk tidak ditemukan'));
    }

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return OpnameItemWidget(
          item: item,
          onActualStockChanged: (value) {
            context.read<OpnameBloc>().add(UpdateActualStockEvent(
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
                  context.read<OpnameBloc>().add(
                      GetOpnameProductsEvent(searchValue: barcode.rawValue!));
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

  Future<void> _pickImage(BuildContext context) async {
    // Implement image picker here using image_picker package
    // For now, show a message that gallery scanning is not implemented
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gallery scanning not implemented yet')),
    );
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
              context.read<OpnameBloc>().add(const SubmitOpnameEvent());
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
