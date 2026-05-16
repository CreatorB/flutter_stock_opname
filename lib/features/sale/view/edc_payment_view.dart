import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syathiby/core/constants/app_constants.dart';
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

  @override
  void initState() {
    super.initState();
    _calculateMdr();
  }

  void _calculateMdr() {
    setState(() {
      _mdr = widget.total * AppConstants.mdrRate;
      _finalAmount = widget.total + _mdr;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pembayaran EDC'),
        ),
        body: BlocListener<SaleBloc, SaleState>(
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
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: Builder(
            builder: (context) => Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Text('Total Belanja'),
                          Text(
                            'Rp ${_formatNumber(widget.total.toStringAsFixed(0))}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    color: Colors.orange.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('MDR (${(AppConstants.mdrRate * 100).toStringAsFixed(1)}%)'),
                              Text(
                                'Rp ${_formatNumber(_mdr.toStringAsFixed(0))}',
                                style: TextStyle(
                                  color: Colors.orange.shade700,
                                ),
                              ),
                            ],
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total + MDR',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Rp ${_formatNumber(_finalAmount.toStringAsFixed(0))}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange.shade700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : () => _processPayment(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('BAYAR EDC', style: TextStyle(fontSize: 18)),
                  ),
                ],
              ),
            ),
          ),
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