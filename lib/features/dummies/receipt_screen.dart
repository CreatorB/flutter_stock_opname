import 'package:flutter/material.dart';
import 'package:syathiby/features/home/view/home_view.dart';

class ReceiptScreen extends StatelessWidget {
  const ReceiptScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaksi Berhasil'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.green, size: 100),
              const SizedBox(height: 24),
              const Text(
                'Pembayaran Berhasil!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 48),

              ElevatedButton(
                onPressed: () {},
                child: const Text('View Struk'),
              ),
              const SizedBox(height: 16),

              OutlinedButton(
                onPressed: () {},
                child: const Text('PRINT'),
              ),
              const SizedBox(height: 32),
              TextButton(
                onPressed: () {
                   Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeView()),
                    (Route<dynamic> route) => false,
                  );
                },
                child: const Text('Kembali ke Dashboard'),
              )
            ],
          ),
        ),
      ),
    );
  }
}