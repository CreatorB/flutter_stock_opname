import 'package:flutter/material.dart';
import 'receipt_screen.dart';

class CashPaymentScreen extends StatelessWidget {
  const CashPaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembayaran Tunai'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'TOTAL',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Rp 65.000',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 32, color: Colors.blueAccent),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16)),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ReceiptScreen()),
                  (Route<dynamic> route) => false,
                );
              },
              child: const Text('BAYAR'),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16)),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('KEMBALI'),
            )
          ],
        ),
      ),
    );
  }
}
