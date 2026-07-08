import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:syathiby/core/constants/color_constants.dart';
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
            backgroundColor: ColorConstants.darkBackground,
            body: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 120,
                  backgroundColor: ColorConstants.blueAccent,
                  flexibleSpace: FlexibleSpaceBar(
                    title: const Text(
                      'Struk',
                      style: TextStyle(color: ColorConstants.whiteText, fontWeight: FontWeight.bold),
                    ),
                    centerTitle: true,
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [ColorConstants.blueAccent, ColorConstants.cyanAccent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: ColorConstants.greenAccent,
                            size: 80,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Transaksi Berhasil!',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: ColorConstants.whiteText,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No. Transaksi: ${state.sale?.saleCode ?? transactionId ?? '-'}',
                            style: const TextStyle(color: ColorConstants.grayText),
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton.icon(
                            onPressed: () => _printReceipt(context, state.printUrl),
                            icon: const Icon(Icons.print),
                            label: const Text('Cetak Struk'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorConstants.orangeAccent,
                              foregroundColor: ColorConstants.whiteText,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () => _newTransaction(context),
                            child: const Text(
                              'Transaksi Baru',
                              style: TextStyle(color: ColorConstants.blueAccent),
                            ),
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
        return Scaffold(
          backgroundColor: ColorConstants.darkBackground,
          appBar: AppBar(
            title: const Text('Struk', style: TextStyle(color: ColorConstants.whiteText)),
            backgroundColor: ColorConstants.blueAccent,
          ),
          body: const Center(
            child: Text('Data tidak tersedia', style: TextStyle(color: ColorConstants.grayText)),
          ),
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
          const SnackBar(
            content: Text('Tidak dapat membuka URL cetak'),
            backgroundColor: ColorConstants.redAccent,
          ),
        );
      }
    }
  }

  void _newTransaction(BuildContext context) {
    context.read<SaleBloc>().add(const ClearCartEvent());
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}