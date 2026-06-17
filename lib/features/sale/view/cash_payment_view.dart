import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
      appBar: AppBar(
        title: const Text('Pembayaran Tunai'),
      ),
      body: BlocListener<SaleBloc, SaleState>(
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
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text('Total Bayar'),
                      Text(
                        'Rp ${_formatNumber(widget.total.toStringAsFixed(0))}',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _cashDisplayController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Jumlah Uang Diterima',
                  prefixText: 'Rp ',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              if (_hasValidPayment) ...[
                Card(
                  color: Colors.green.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text('Kembalian'),
                        Text(
                          'Rp ${_formatNumber(_change.toStringAsFixed(0))}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const Spacer(),
              ElevatedButton(
                onPressed: _isSubmitting ? null : () => _processPayment(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('BAYAR', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _processPayment(BuildContext context) {
    final cash = double.tryParse(_cashController.text) ?? 0;
    if (cash < widget.total) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Jumlah uang tidak cukup'),
          backgroundColor: Colors.red,
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