import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syathiby/core/constants/color_constants.dart';
import 'package:syathiby/common/widgets/gradient_header.dart';
import 'package:syathiby/common/widgets/glow_card.dart';
import 'package:syathiby/common/widgets/gradient_button.dart';
import 'package:syathiby/features/payment/bloc/payment_bloc.dart';
import 'package:syathiby/features/payment/bloc/payment_state.dart';
import 'package:syathiby/features/sale/bloc/sale_bloc.dart';
import 'package:syathiby/features/sale/bloc/sale_state.dart';
import 'package:syathiby/features/sale/view/cash_payment_view.dart';
import 'package:syathiby/features/sale/view/edc_payment_view.dart';

class PaymentMethodView extends StatelessWidget {
  const PaymentMethodView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SaleBloc, SaleState>(
      builder: (context, saleState) {
        final total =
            saleState is SaleInProgress ? saleState.totalAmount : 0.0;

        return Scaffold(
          body: Column(
            children: [
              const GradientHeader(title: 'Metode Pembayaran'),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      GlowCard(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            const Text(
                              'Total Bayar',
                              style: TextStyle(
                                fontSize: 16,
                                color: ColorConstants.grayText,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Rp ${_formatNumber(total.toStringAsFixed(0))}',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: ColorConstants.greenPrice,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Pilih Metode Pembayaran',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: ColorConstants.whiteText,
                        ),
                      ),
                      const SizedBox(height: 16),
                      GlowCard(
                        glowColor: ColorConstants.darkPrimaryIcon,
                        borderColor: ColorConstants.darkPrimaryIcon.withOpacity(0.3),
                        onTap: () => _navigateToCashPayment(context, total),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    ColorConstants.darkPrimaryIcon,
                                    ColorConstants.darkPrimaryIcon.withOpacity(0.6),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.money,
                                color: Colors.white,
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Text(
                              'TUNAI',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: ColorConstants.whiteText,
                              ),
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.chevron_right,
                              color: ColorConstants.darkPrimaryIcon,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      GlowCard(
                        glowColor: ColorConstants.secondaryBlue,
                        borderColor: ColorConstants.secondaryBlue.withOpacity(0.3),
                        onTap: () => _navigateToEdcPayment(context, total),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    ColorConstants.secondaryBlue,
                                    ColorConstants.secondaryBlue.withOpacity(0.6),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.credit_card,
                                color: Colors.white,
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Text(
                              'EDC',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: ColorConstants.whiteText,
                              ),
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.chevron_right,
                              color: ColorConstants.secondaryBlue,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _navigateToCashPayment(BuildContext context, double total) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CashPaymentView(total: total)),
    );
  }

  void _navigateToEdcPayment(BuildContext context, double total) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EdcPaymentView(total: total)),
    );
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
