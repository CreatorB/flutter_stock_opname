import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart'; 

class SetoranScreen extends StatefulWidget {
  const SetoranScreen({super.key});

  @override
  State<SetoranScreen> createState() => _SetoranScreenState();
}

class _SetoranScreenState extends State<SetoranScreen> {
  final TextEditingController _setoranController = TextEditingController();
  double _selisih = 0.0;

  final double _penjualanTunai = 1250000.0;
  final double _penjualanEdc = 750000.0;

  @override
  void initState() {
    super.initState();
    _selisih = -_penjualanTunai;
    _setoranController.addListener(_hitungSelisih);
  }

  void _hitungSelisih() {
    final double jumlahDisetor =
        double.tryParse(_setoranController.text) ?? 0.0;
    setState(() {
      _selisih = jumlahDisetor - _penjualanTunai;
    });
  }

  @override
  void dispose() {
    _setoranController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setoran'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            Text(
              'Setoran untuk Tanggal: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Ringkasan Sistem',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const Divider(),
                    _buildRingkasanRow('Total Penjualan Tunai:',
                        'Rp ${_penjualanTunai.toStringAsFixed(0)}'),
                    _buildRingkasanRow('Total Penjualan EDC:',
                        'Rp ${_penjualanEdc.toStringAsFixed(0)}'),
                    const Divider(),
                    _buildRingkasanRow('Total Pemasukan:',
                        'Rp ${(_penjualanTunai + _penjualanEdc).toStringAsFixed(0)}',
                        isTotal: true),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _setoranController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Jumlah yang Disetor (Tunai)',
                border: OutlineInputBorder(),
                prefixText: 'Rp ',
              ),
            ),
            const SizedBox(height: 16),
            _buildSelisihRow(
                'Selisih:', 'Rp ${_selisih.toStringAsFixed(0)}', _selisih),
            const SizedBox(height: 32),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
              ),
              onPressed: () {

                Fluttertoast.showToast(
                  msg: "Setoran berhasil disimpan!",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  backgroundColor: Colors.green,
                  textColor: Colors.white,
                  fontSize: 16.0
                );
              },
              child: const Text('SIMPAN SETORAN'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRingkasanRow(String title, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: TextStyle(
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
          Text(value,
              style: TextStyle(
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  Widget _buildSelisihRow(String title, String value, double selisihValue) {
    Color selisihColor = Colors.grey;
    if (_setoranController.text.isNotEmpty) {
      if (selisihValue == 0) {
        selisihColor = Colors.green;
      } else {
        selisihColor = Colors.red;
      }
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(value,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: selisihColor)),
        ],
      ),
    );
  }
}