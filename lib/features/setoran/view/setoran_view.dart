import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syathiby/common/widgets/gradient_button.dart';
import 'package:syathiby/common/widgets/gradient_header.dart';
import 'package:syathiby/common/widgets/glow_card.dart';
import 'package:syathiby/core/constants/color_constants.dart';
import 'package:syathiby/features/setoran/bloc/setoran_bloc.dart';
import 'package:syathiby/features/setoran/bloc/setoran_event.dart';
import 'package:syathiby/features/setoran/bloc/setoran_state.dart';
import 'package:syathiby/features/setoran/models/setoran_model.dart';

class SetoranView extends StatefulWidget {
  const SetoranView({super.key});

  @override
  State<SetoranView> createState() => _SetoranViewState();
}

class _SetoranViewState extends State<SetoranView> {
  final TextEditingController _amountController = TextEditingController();
  SetoranBloc? _bloc;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_onAmountControllerChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_bloc == null) {
      _bloc = context.read<SetoranBloc>();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _onAmountControllerChanged() {
    final raw = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final formatted = _formatNumber(raw);
    if (formatted != _amountController.text) {
      final cursorAfterRaw = _amountController.text
          .substring(0, _amountController.selection.baseOffset)
          .replaceAll(RegExp(r'[^0-9]'), '')
          .length;
      _amountController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(
          offset: _mapRawCursorToFormatted(raw, cursorAfterRaw),
        ),
      );
      return;
    }
    _bloc?.add(SetoranAmountChangedEvent(raw));
  }

  int _mapRawCursorToFormatted(String raw, int rawCursor) {
    if (raw.isEmpty) return 0;
    final digits = raw.substring(0, rawCursor.clamp(0, raw.length));
    final formatted = _formatNumber(digits);
    return formatted.length;
  }

  String _formatNumber(String number) {
    if (number.isEmpty) return '';
    final n = int.tryParse(number);
    if (n == null) return number;
    return n.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
  }

  String _formatRupiah(double value) {
    if (value == 0) return 'Rp 0';
    final formatted = _formatNumber(value.toStringAsFixed(0));
    return 'Rp $formatted';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<SetoranBloc, SetoranState>(
        listenWhen: (prev, curr) => curr is SetoranError || curr is SetoranSuccess,
        listener: (context, state) {
          if (state is SetoranError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: ColorConstants.redError,
              ),
            );
          } else if (state is SetoranSuccess) {
            _amountController.clear();
            showDialog<void>(
              context: context,
              barrierDismissible: false,
              builder: (ctx) => AlertDialog(
                backgroundColor: ColorConstants.glassCardSolid,
                title: const Text(
                  'Setoran Berhasil',
                  style: TextStyle(color: ColorConstants.whiteText),
                ),
                content: Text(
                  state.response.msg?.isNotEmpty == true
                      ? state.response.msg!
                      : 'Setoran telah disimpan.',
                  style: const TextStyle(color: ColorConstants.grayText),
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorConstants.greenPrice,
                    ),
                    child: const Text('OK',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              GradientHeader(
                title: 'Setoran',
                subtitle: _subtitleForState(state),
              ),
              Expanded(
                child: _buildBody(context, state),
              ),
            ],
          );
        },
      ),
    );
  }

  String _subtitleForState(SetoranState state) {
    final now = DateTime.now();
    final dateStr =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
    if (state is SetoranExistingLoaded) {
      return 'Setoran $dateStr (sudah diinput)';
    }
    return 'Setoran untuk $dateStr';
  }

  Widget _buildBody(BuildContext context, SetoranState state) {
    if (state is SetoranLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: ColorConstants.darkPrimaryIcon,
        ),
      );
    }
    if (state is SetoranError) {
      return _buildErrorView(context, state);
    }
    if (state is SetoranExistingLoaded) {
      return _buildExistingView(context, state);
    }
    if (state is SetoranReadyForInput) {
      return _buildInputView(context, state);
    }
    if (state is SetoranSubmitting) {
      return _buildInputView(
        context,
        const SetoranReadyForInput(summary: SetoranTrxSummaryModel()),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildErrorView(BuildContext context, SetoranError state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: ColorConstants.redError,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              state.message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: ColorConstants.whiteText),
            ),
            const SizedBox(height: 24),
            GradientButton(
              text: 'COBA LAGI',
              onPressed: () =>
                  _bloc?.add(const SetoranCheckDepositEvent()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExistingView(BuildContext context, SetoranExistingLoaded state) {
    final e = state.existing;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GlowCard(
            glowColor: ColorConstants.greenPrice,
            borderColor: ColorConstants.greenPrice.withOpacity(0.3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: ColorConstants.greenPrice,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Setoran Hari Ini Sudah Diinput',
                      style: TextStyle(
                        color: ColorConstants.whiteText,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (e.deId != null)
                  _buildInfoRow('ID Setoran', e.deId!),
                if (e.statusPaid != null)
                  _buildInfoRow(
                    'Status',
                    e.isPaid ? 'PAID' : 'UNPAID',
                    valueColor: e.isPaid
                        ? ColorConstants.greenPrice
                        : ColorConstants.darkWarningColor,
                  ),
                if (e.createdAt != null)
                  _buildInfoRow('Tanggal', e.createdAt!),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlowCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ringkasan Sistem',
                  style: TextStyle(
                    color: ColorConstants.whiteText,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(color: ColorConstants.glassBorder),
                _buildSummaryRow(
                  'Total Penjualan Tunai',
                  _formatRupiah(e.tunaiAmountDouble),
                ),
                _buildSummaryRow(
                  'Total Penjualan EDC',
                  _formatRupiah(e.edcAmountDouble),
                ),
                _buildSummaryRow(
                  'Total Tunai + EDC',
                  _formatRupiah(e.tunaiedcAmountDouble),
                ),
                const Divider(color: ColorConstants.glassBorder),
                _buildSummaryRow(
                  'Jumlah Disetor',
                  _formatRupiah(e.amountDouble),
                  isTotal: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputView(BuildContext context, SetoranReadyForInput state) {
    if (state.summary.tunaiDouble == 0 &&
        state.summary.edcDouble == 0 &&
        state.summary.tunaiedcDouble == 0) {
      return _buildInputContent(context, state, isPlaceholder: true);
    }
    return _buildInputContent(context, state);
  }

  Widget _buildInputContent(
    BuildContext context,
    SetoranReadyForInput state, {
    bool isPlaceholder = false,
  }) {
    final isReady = !isPlaceholder;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GlowCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ringkasan Sistem',
                  style: TextStyle(
                    color: ColorConstants.whiteText,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(color: ColorConstants.glassBorder),
                _buildSummaryRow(
                  'Total Penjualan Tunai',
                  _formatRupiah(state.summary.tunaiDouble),
                  enabled: isReady,
                ),
                _buildSummaryRow(
                  'Total Penjualan EDC',
                  _formatRupiah(state.summary.edcDouble),
                  enabled: isReady,
                ),
                _buildSummaryRow(
                  'Total Tunai + EDC',
                  _formatRupiah(state.summary.tunaiedcDouble),
                  enabled: isReady,
                ),
                const Divider(color: ColorConstants.glassBorder),
                _buildSummaryRow(
                  'Total Pemasukan',
                  _formatRupiah(state.summary.total),
                  isTotal: true,
                  enabled: isReady,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            enabled: isReady,
            style: const TextStyle(
              color: ColorConstants.whiteText,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            cursorColor: ColorConstants.darkPrimaryIcon,
            decoration: InputDecoration(
              labelText: 'Jumlah yang Disetor (Tunai)',
              labelStyle: const TextStyle(color: ColorConstants.grayText),
              prefixText: 'Rp ',
              prefixStyle: const TextStyle(
                color: ColorConstants.darkPrimaryIcon,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              filled: true,
              fillColor: ColorConstants.darkTextField,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: ColorConstants.glassBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: ColorConstants.glassBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: ColorConstants.darkPrimaryIcon,
                  width: 2,
                ),
              ),
              hintText: '0',
              hintStyle: const TextStyle(color: ColorConstants.grayText),
            ),
          ),
          const SizedBox(height: 16),
          _buildSelisihRow(state, isReady),
          const SizedBox(height: 32),
          GradientButton(
            text: 'SIMPAN SETORAN',
            isLoading: _bloc?.state is SetoranSubmitting,
            onPressed: isReady
                ? () => _bloc?.add(const SetoranSaveDepositEvent())
                : null,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSelisihRow(SetoranReadyForInput state, bool enabled) {
    final diff = enabled ? state.difference : -state.summary.tunaiDouble;
    Color color = ColorConstants.grayText;
    if (enabled && state.amountInput.isNotEmpty) {
      if (diff == 0) {
        color = ColorConstants.greenPrice;
      } else if (diff > 0) {
        color = ColorConstants.darkPrimaryIcon;
      } else {
        color = ColorConstants.redError;
      }
    } else if (!enabled) {
      color = ColorConstants.grayText;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Selisih',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: ColorConstants.whiteText,
            ),
          ),
          Text(
            _formatRupiah(diff),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String title,
    String value, {
    bool isTotal = false,
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: enabled
                  ? ColorConstants.grayText
                  : ColorConstants.darkInactive,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: ColorConstants.whiteText,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: ColorConstants.grayText),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? ColorConstants.whiteText,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
