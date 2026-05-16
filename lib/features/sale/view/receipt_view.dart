import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:syathiby/features/sale/bloc/sale_bloc.dart';
import 'package:syathiby/features/sale/bloc/sale_event.dart';
import 'package:syathiby/features/sale/bloc/sale_state.dart';

class ReceiptView extends StatelessWidget {
  final String printUrl;
  final String? transactionId;

  const ReceiptView({
    super.key,
    required this.printUrl,
    this.transactionId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SaleBloc, SaleState>(
      builder: (context, state) {
        if (state is SaleSuccess) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Struk'),
              automaticallyImplyLeading: false,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 80,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Transaksi Berhasil!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No. Transaksi: ${state.sale?.saleCode ?? transactionId ?? '-'}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () => _printReceipt(context, state.printUrl),
                    icon: const Icon(Icons.print),
                    label: const Text('Cetak Struk'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => _newTransaction(context),
                    child: const Text('Transaksi Baru'),
                  ),
                ],
              ),
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(title: const Text('Struk')),
          body: const Center(child: Text('Data tidak tersedia')),
        );
      },
    );
  }

  void _printReceipt(BuildContext context, String printUrl) async {
    final url = Uri.parse(printUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka URL cetak')),
        );
      }
    }
  }

  void _newTransaction(BuildContext context) {
    context.read<SaleBloc>().add(const ClearCartEvent());
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}