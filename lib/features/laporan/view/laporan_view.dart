import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:syathiby/common/widgets/gradient_button.dart';
import 'package:syathiby/common/widgets/gradient_header.dart';
import 'package:syathiby/common/widgets/glow_card.dart';
import 'package:syathiby/core/constants/color_constants.dart';
import 'package:syathiby/features/laporan/bloc/laporan_bloc.dart';
import 'package:syathiby/features/laporan/bloc/laporan_event.dart';
import 'package:syathiby/features/laporan/bloc/laporan_state.dart';
import 'package:syathiby/features/laporan/models/laporan_model.dart';

class LaporanView extends StatefulWidget {
  const LaporanView({super.key});

  @override
  State<LaporanView> createState() => _LaporanViewState();
}

class _LaporanViewState extends State<LaporanView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  LaporanBloc? _bloc;
  bool _initialLoadDispatched = false;

  static const _tabs = [
    LaporanTab.penjualan,
    LaporanTab.opname,
    LaporanTab.setoran,
  ];

  static const _tabLabels = ['PENJUALAN', 'STOK OPNAME', 'SETORAN'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_bloc == null) {
      _bloc = context.read<LaporanBloc>();
      if (!_initialLoadDispatched) {
        _initialLoadDispatched = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _bloc?.add(const LaporanRefreshEvent());
          }
        });
      }
    }
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) return;
    final bloc = _bloc;
    if (bloc == null) return;
    final tab = _tabs[_tabController.index];
    if (tab != bloc.state.activeTab) {
      bloc.add(LaporanTabChangedEvent(tab));
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _pickDateRange() async {
    final bloc = _bloc;
    if (bloc == null) return;
    final initial = DateTimeRange(
      start: bloc.state.startDate ?? DateTime.now().subtract(const Duration(days: 7)),
      end: bloc.state.endDate ?? DateTime.now(),
    );
    final result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      initialDateRange: initial,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: ColorConstants.darkPrimaryIcon,
            onPrimary: Colors.white,
            surface: ColorConstants.glassCardSolid,
            onSurface: ColorConstants.whiteText,
          ),
        ),
        child: child ?? const SizedBox.shrink(),
      ),
    );

    if (result != null) {
      bloc.add(LaporanDateRangeChangedEvent(
        startDate: result.start,
        endDate: result.end,
      ));
    }
  }

  String _formatRange() {
    final fmt = DateFormat('dd MMM yyyy');
    final bloc = _bloc;
    final start = bloc?.state.startDate;
    final end = bloc?.state.endDate;
    if (start == null && end == null) return 'Semua Periode';
    if (start != null && end != null) {
      return '${fmt.format(start)} - ${fmt.format(end)}';
    }
    if (start != null) return 'Dari ${fmt.format(start)}';
    return 'Sampai ${fmt.format(end!)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<LaporanBloc, LaporanState>(
        listenWhen: (prev, curr) =>
            prev.errorMessage != curr.errorMessage && curr.errorMessage != null,
        listener: (context, state) {
          ScaffoldMessenger.maybeOf(context)?.showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Error'),
              backgroundColor: ColorConstants.redError,
            ),
          );
        },
        child: BlocBuilder<LaporanBloc, LaporanState>(
          builder: (context, state) {
          return Column(
            children: [
              GradientHeader(
                title: 'Laporan',
                subtitle: _formatRange(),
                trailing: IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: () => _bloc?.add(const LaporanRefreshEvent()),
                ),
              ),
              Container(
                color: ColorConstants.darkBackground,
                child: TabBar(
                  controller: _tabController,
                  labelColor: ColorConstants.darkPrimaryIcon,
                  unselectedLabelColor: ColorConstants.grayText,
                  indicatorColor: ColorConstants.darkPrimaryIcon,
                  indicatorWeight: 3,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  tabs: _tabLabels
                      .map((label) => Tab(text: label))
                      .toList(growable: false),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: GradientButton(
                        text: 'Pilih Periode',
                        onPressed: _pickDateRange,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPenjualanTab(state),
                    _buildOpnameTab(state),
                    _buildSetoranTab(state),
                  ],
                ),
              ),
            ],
        );
      },
        ),
      ),
    );
  }

  Widget _buildPenjualanTab(LaporanState state) {
    return _buildReportBody(
      isLoading: state.penjualanLoading,
      isEmpty: state.penjualan?.items.isEmpty ?? true,
      onRetry: () => _bloc?.add(const LaporanRefreshEvent()),
      summary: state.penjualan?.summary,
      summaryBuilder: (summary) => _buildSummaryRow('Omzet', _formatRupiah(summary.total)),
      listBuilder: () => ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: state.penjualan!.items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final item = state.penjualan!.items[index];
          return GlowCard(
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: ColorConstants.darkPrimaryIcon.withOpacity(0.2),
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: ColorConstants.darkPrimaryIcon,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.trxNumber ?? 'TRX #${item.trxId ?? '-'}',
                        style: const TextStyle(
                          color: ColorConstants.whiteText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        [
                          if (item.date != null) item.date!,
                          if (item.paymentMethod != null) item.paymentMethod!,
                          if (item.itemCount > 0) '${item.itemCount.toInt()} item',
                        ].join(' • '),
                        style: const TextStyle(
                          color: ColorConstants.grayText,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  _formatRupiah(item.grandTotal),
                  style: const TextStyle(
                    color: ColorConstants.darkPrimaryIcon,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOpnameTab(LaporanState state) {
    return _buildReportBody(
      isLoading: state.opnameLoading,
      isEmpty: state.opname?.items.isEmpty ?? true,
      onRetry: () => _bloc?.add(const LaporanRefreshEvent()),
      summary: state.opname?.summary,
      summaryBuilder: (summary) => _buildSummaryRow(
        'Total Opname',
        '${summary.count.toInt()} item',
      ),
      listBuilder: () => ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: state.opname!.items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final item = state.opname!.items[index];
          return GlowCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.inventory_2_outlined,
                        color: ColorConstants.darkPrimaryIcon),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.productName ?? 'Produk #${item.opnameId ?? '-'}',
                        style: const TextStyle(
                          color: ColorConstants.whiteText,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  [
                    if (item.opnameCode != null) item.opnameCode!,
                    if (item.raCode != null) 'Rak ${item.raCode}',
                    if (item.opDate != null) item.opDate!,
                  ].join(' • '),
                  style: const TextStyle(
                    color: ColorConstants.grayText,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Sistem: ${item.qtySystem.toInt()}',
                      style: const TextStyle(
                        color: ColorConstants.grayText,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      'Aktual: ${item.qtyOpname.toInt()}',
                      style: const TextStyle(
                        color: ColorConstants.whiteText,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      'Selisih: ${item.selisih > 0 ? '+' : ''}${item.selisih.toInt()}',
                      style: TextStyle(
                        color: item.selisih == 0
                            ? ColorConstants.grayText
                            : item.selisih > 0
                                ? ColorConstants.greenPrice
                                : ColorConstants.redError,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSetoranTab(LaporanState state) {
    return _buildReportBody(
      isLoading: state.setoranLoading,
      isEmpty: state.setoran?.items.isEmpty ?? true,
      onRetry: () => _bloc?.add(const LaporanRefreshEvent()),
      summary: state.setoran?.summary,
      summaryBuilder: (summary) => _buildSummaryRow(
        'Total Setoran',
        _formatRupiah(summary.total),
      ),
      listBuilder: () => ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: state.setoran!.items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final item = state.setoran!.items[index];
          return GlowCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Setoran #${item.deId ?? '-'}',
                        style: const TextStyle(
                          color: ColorConstants.whiteText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (item.statusPaid != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: (item.statusPaid == '1' ||
                                  item.statusPaid!.toLowerCase() == 'paid')
                              ? ColorConstants.greenPrice.withOpacity(0.2)
                              : ColorConstants.darkWarningColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          (item.statusPaid == '1' ||
                                  item.statusPaid!.toLowerCase() == 'paid')
                              ? 'PAID'
                              : 'UNPAID',
                          style: TextStyle(
                            color: (item.statusPaid == '1' ||
                                    item.statusPaid!.toLowerCase() == 'paid')
                                ? ColorConstants.greenPrice
                                : ColorConstants.darkWarningColor,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                if (item.date != null)
                  Text(
                    item.date!,
                    style: const TextStyle(
                      color: ColorConstants.grayText,
                      fontSize: 12,
                    ),
                  ),
                const SizedBox(height: 8),
                _buildSummaryRow('Tunai', _formatRupiah(item.tunaiAmount)),
                _buildSummaryRow('EDC', _formatRupiah(item.edcAmount)),
                _buildSummaryRow(
                    'Tunai + EDC', _formatRupiah(item.tunaiedcAmount)),
                const Divider(color: ColorConstants.glassBorder),
                _buildSummaryRow('Disetor', _formatRupiah(item.amount),
                    isTotal: true),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildReportBody({
    required bool isLoading,
    required bool isEmpty,
    required VoidCallback onRetry,
    required LaporanSummaryModel? summary,
    required Widget Function(LaporanSummaryModel) summaryBuilder,
    required Widget Function() listBuilder,
  }) {
    if (isLoading && summary == null) {
      return const Center(
        child: CircularProgressIndicator(
          color: ColorConstants.darkPrimaryIcon,
        ),
      );
    }
    if (summary == null && isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.bar_chart_outlined,
                color: ColorConstants.grayText,
                size: 64,
              ),
              const SizedBox(height: 16),
              const Text(
                'Belum ada data laporan untuk periode ini.',
                textAlign: TextAlign.center,
                style: TextStyle(color: ColorConstants.grayText),
              ),
              const SizedBox(height: 24),
              GradientButton(text: 'COBA LAGI', onPressed: onRetry),
            ],
          ),
        ),
      );
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: GlowCard(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: summaryBuilder(summary ?? const LaporanSummaryModel()),
            ),
          ),
        ),
        Expanded(
          child: isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Tidak ada data untuk filter saat ini.',
                      style: const TextStyle(color: ColorConstants.grayText),
                    ),
                  ),
                )
              : listBuilder(),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(
    String title,
    String value, {
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isTotal
                  ? ColorConstants.whiteText
                  : ColorConstants.grayText,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isTotal
                  ? ColorConstants.darkPrimaryIcon
                  : ColorConstants.whiteText,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }

  String _formatRupiah(double value) {
    if (value == 0) return 'Rp 0';
    final formatted = value
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (m) => '${m[1]}.');
    return 'Rp $formatted';
  }
}