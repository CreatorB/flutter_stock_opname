import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
class ScannerScreen extends StatelessWidget {
  const ScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pindai Kode'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: MobileScanner(
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          if (barcodes.isNotEmpty) {
            final String code = barcodes.first.rawValue ?? "Tidak dapat membaca kode";

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Kode terdeteksi: $code'),
              ),
            );

            Navigator.pop(context);
          }
        },
      ),
    );
  }
}