import 'package:flutter/material.dart';

class LaporanScreen extends StatelessWidget {
  const LaporanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, 
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Laporan'),
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.print),
              tooltip: 'Print / Export',
              onPressed: () {},
            ),
          ],
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'PENJUALAN'),
              Tab(text: 'STOK OPNAME'),
              Tab(text: 'SETORAN'),
            ],
          ),
        ),
        body: TabBarView(
          children: [

            _buildLaporanPenjualan(),

            const Center(child: Text('Riwayat Stok Opname akan ditampilkan di sini')),

            const Center(child: Text('Riwayat Setoran akan ditampilkan di sini')),
          ],
        ),
      ),
    );
  }

  Widget _buildLaporanPenjualan() {
    return Column(
      children: [

        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Periode: '),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Minggu Ini'),
              )
            ],
          ),
        ),

        Card(
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildRingkasanLaporan('Omzet', 'Rp 9.850.000'),
                _buildRingkasanLaporan('Transaksi', '152'),
              ],
            ),
          ),
        ),

        Expanded(
          child: ListView.builder(
            itemCount: 10, 
            itemBuilder: (context, index) {
              return ListTile(
                leading: CircleAvatar(child: Text('${index + 1}')),
                title: Text('Transaksi #TRX00${index + 1}'),
                subtitle: Text('25 Agu 2025, 09:${30+index}'),
                trailing: const Text('Rp 65.000'),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRingkasanLaporan(String title, String value) {
    return Column(
      children: [
        Text(title, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }
}