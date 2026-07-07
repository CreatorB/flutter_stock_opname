import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syathiby/core/constants/app_constants.dart';
import 'package:syathiby/core/constants/color_constants.dart';
import 'package:syathiby/features/sale/bloc/sale_bloc.dart';
import 'package:syathiby/features/sale/bloc/sale_event.dart';
import 'package:syathiby/features/sale/bloc/sale_state.dart';
import 'package:syathiby/features/sale/view/receipt_view.dart';

class EdcPaymentView extends StatefulWidget {
  final double total;

  const EdcPaymentView({super.key, required this.total});

  @override
  State<EdcPaymentView> createState() => _EdcPaymentViewState();
}

class _EdcPaymentViewState extends State<EdcPaymentView> {
  late double _mdr;
  late double _finalAmount;
  bool _isSubmitting = false;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  final TextEditingController _mdrController = TextEditingController();
  String? _mdrError;

  @override
  void initState() {
    super.initState();
    final initialMdrRate = (AppConstants.mdrRate * 100).toStringAsFixed(1);
    _mdrController.text = initialMdrRate;
    _calculateMdr();
  }

  @override
  void dispose() {
    _mdrController.dispose();
    super.dispose();
  }

  void _calculateMdr() {
    final mdrRate = double.tryParse(_mdrController.text) ?? 0;
    if (mdrRate > 2) {
      setState(() {
        _mdrError = 'Maksimal 2%';
      });
      return;
    }
    setState(() {
      _mdrError = null;
      _mdr = widget.total * (mdrRate / 100);
      _finalAmount = widget.total + _mdr;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        backgroundColor: ColorConstants.darkBackground,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 120,
              backgroundColor: ColorConstants.secondaryBlue,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text(
                  'Pembayaran EDC',
                  style: TextStyle(color: ColorConstants.whiteText, fontWeight: FontWeight.bold),
                ),
                centerTitle: true,
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [ColorConstants.secondaryBlue, ColorConstants.secondaryBlueDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: BlocListener<SaleBloc, SaleState>(
                listener: (context, state) {
                  debugPrint('EdcPaymentView BlocListener state: $state');
                  if (state is SaleSuccess) {
                    debugPrint('SaleSuccess, navigating to ReceiptView');
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReceiptView(printUrl: state.printUrl),
                      ),
                      (route) => route.isFirst,
                    );
                  } else if (state is SaleError) {
                    debugPrint('SaleError: ${state.message}');
                    setState(() => _isSubmitting = false);
                    _scaffoldMessengerKey.currentState?.showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: ColorConstants.redError,
                      ),
                    );
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: ColorConstants.glassCard,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: ColorConstants.glassBorder),
                        ),
                        child: Column(
                          children: [
                            const Text('Total Belanja', style: TextStyle(color: ColorConstants.grayText)),
                            Text(
                              'Rp ${_formatNumber(widget.total.toStringAsFixed(0))}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: ColorConstants.whiteText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: ColorConstants.darkPrimaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: ColorConstants.darkPrimaryColor.withOpacity(0.3)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: 100,
                                  child: TextField(
                                    controller: _mdrController,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    style: const TextStyle(color: ColorConstants.whiteText),
                                    decoration: InputDecoration(
                                      labelText: 'MDR (%)',
                                      errorText: _mdrError,
                                      labelStyle: const TextStyle(color: ColorConstants.grayText),
                                      errorStyle: const TextStyle(color: ColorConstants.redError),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(color: ColorConstants.glassBorder),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(color: ColorConstants.glassBorder),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(color: ColorConstants.darkPrimaryColor),
                                      ),
                                      isDense: true,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                      filled: true,
                                      fillColor: ColorConstants.glassCard,
                                    ),
                                    onChanged: (_) => _calculateMdr(),
                                  ),
                                ),
                                Text(
                                  'Rp ${_formatNumber(_mdr.toStringAsFixed(0))}',
                                  style: const TextStyle(
                                    color: ColorConstants.darkPrimaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(color: ColorConstants.glassBorder),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total + MDR',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: ColorConstants.grayText),
                                ),
                                Text(
                                  'Rp ${_formatNumber(_finalAmount.toStringAsFixed(0))}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: ColorConstants.darkPrimaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _isSubmitting ? null : () => _processPayment(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorConstants.darkPrimaryColor,
                          foregroundColor: ColorConstants.whiteText,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: _isSubmitting
                            ? const CircularProgressIndicator(color: ColorConstants.whiteText)
                            : const Text('BAYAR EDC', style: TextStyle(fontSize: 18)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _processPayment(BuildContext context) {
    debugPrint('_processPayment called, total: ${widget.total}, mdr: $_mdr');
    setState(() => _isSubmitting = true);
    context.read<SaleBloc>().add(SubmitSaleEvent(
      paymentMethod: 'edc',
      mdr: _mdr.toString(),
    ));
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