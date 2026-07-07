import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syathiby/core/constants/color_constants.dart';
import 'package:syathiby/features/payment/bloc/payment_bloc.dart';
import 'package:syathiby/features/sale/bloc/sale_bloc.dart';
import 'package:syathiby/features/sale/bloc/sale_event.dart';
import 'package:syathiby/features/sale/bloc/sale_state.dart';
import 'package:syathiby/features/sale/view/receipt_view.dart';

class CashPaymentView extends StatefulWidget {
  final double total;

  const CashPaymentView({super.key, required this.total});

  @override
  State<CashPaymentView> createState() => _CashPaymentViewState();
}

class _CashPaymentViewState extends State<CashPaymentView> {
  final TextEditingController _cashController = TextEditingController();
  final TextEditingController _cashDisplayController = TextEditingController();
  double _change = 0;
  bool _hasValidPayment = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _cashController.addListener(_onCashChanged);
    _cashDisplayController.addListener(_onDisplayChanged);
  }

  void _onCashChanged() {
    final rawValue = _cashController.text.replaceAll('.', '');
    final cash = double.tryParse(rawValue) ?? 0;
    _cashDisplayController.text = _formatNumber(rawValue);
    _cashDisplayController.selection = TextSelection.fromPosition(
      TextPosition(offset: _cashDisplayController.text.length),
    );
    setState(() {
      _change = cash - widget.total;
      _hasValidPayment = cash >= widget.total;
    });
  }

  void _onDisplayChanged() {
    final cursorPos = _cashDisplayController.selection.baseOffset;
    final rawValue = _cashDisplayController.text.replaceAll('.', '');
    _cashController.text = rawValue;
    if (cursorPos <= _cashDisplayController.text.length) {
      _cashDisplayController.selection = TextSelection.fromPosition(
        TextPosition(offset: cursorPos),
      );
    }
  }

  @override
  void dispose() {
    _cashController.dispose();
    _cashDisplayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.darkBackground,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            backgroundColor: ColorConstants.secondaryBlue,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Pembayaran Tunai',
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
                if (state is SaleSuccess) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReceiptView(printUrl: state.printUrl),
                    ),
                    (route) => route.isFirst,
                  );
                } else if (state is SaleError) {
                  setState(() => _isSubmitting = false);
                  ScaffoldMessenger.of(context).showSnackBar(
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
                          const Text('Total Bayar', style: TextStyle(color: ColorConstants.grayText)),
                          Text(
                            'Rp ${_formatNumber(widget.total.toStringAsFixed(0))}',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                                color: ColorConstants.greenPrice,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _cashDisplayController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: ColorConstants.whiteText),
                      decoration: InputDecoration(
                        labelText: 'Jumlah Uang Diterima',
                        prefixText: 'Rp ',
                        labelStyle: const TextStyle(color: ColorConstants.grayText),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: ColorConstants.glassBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: ColorConstants.darkPrimaryColor),
                        ),
                        filled: true,
                        fillColor: ColorConstants.glassCard,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_hasValidPayment) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: ColorConstants.greenPrice.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: ColorConstants.greenPrice.withOpacity(0.3)),
                        ),
                        child: Column(
                          children: [
                            const Text('Kembalian', style: TextStyle(color: ColorConstants.grayText)),
                            Text(
                              'Rp ${_formatNumber(_change.toStringAsFixed(0))}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              color: ColorConstants.greenPrice,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
                          : const Text('BAYAR', style: TextStyle(fontSize: 18)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _processPayment(BuildContext context) {
    final cash = double.tryParse(_cashController.text) ?? 0;
    if (cash < widget.total) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Jumlah uang tidak cukup'),
          backgroundColor: ColorConstants.redError,
        ),
      );
      return;
    }
    setState(() => _isSubmitting = true);
    context.read<SaleBloc>().add(SubmitSaleEvent(
      paymentMethod: 'tunai',
      cashReceived: _cashController.text,
      mdr: null,
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