import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syathiby/core/di/injection.dart';
import 'package:syathiby/core/constants/color_constants.dart';
import 'package:syathiby/common/widgets/gradient_header.dart';
import 'package:syathiby/common/widgets/glow_card.dart';
import 'package:syathiby/features/dummies/laporan_screen.dart';
import 'package:syathiby/features/dummies/setoran_screen.dart';
import 'package:syathiby/features/opname/bloc/opname_bloc.dart';
import 'package:syathiby/features/opname/bloc/opname_event.dart';
import 'package:syathiby/features/opname/view/opname_view.dart';
import 'package:syathiby/features/product/view/product_list_view.dart';
import 'package:syathiby/features/sale/view/sale_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            GradientHeader(
              title: 'Dashboard',
              subtitle: 'Kelola bisnis Anda dengan mudah',
              showWave: true,
              leading: null,
              trailing: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: IconButton(
                  icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 22),
                  onPressed: () {},
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildMenuCard(
                          context: context,
                          icon: Icons.shopping_cart_outlined,
                          iconColor: ColorConstants.darkPrimaryIcon,
                          glowColor: ColorConstants.darkPrimaryIcon,
                          label: 'PENJUALAN',
                          desc: 'Kelola transaksi penjualan harian',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SaleView(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMenuCard(
                          context: context,
                          icon: Icons.inventory_2_outlined,
                          iconColor: ColorConstants.secondaryBlue,
                          glowColor: ColorConstants.secondaryBlue,
                          label: 'OPNAME',
                          desc: 'Lakukan pengecekan stok barang',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BlocProvider(
                                  create: (_) => sl<OpnameBloc>()
                                    ..add(const GetOpnameProductsEvent()),
                                  child: const OpnameView(),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMenuCard(
                          context: context,
                          icon: Icons.savings_outlined,
                          iconColor: ColorConstants.secondaryBlue,
                          glowColor: ColorConstants.secondaryBlue,
                          label: 'SETORAN',
                          desc: 'Catat dan kelola setoran kas',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SetoranScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMenuCard(
                          context: context,
                          icon: Icons.bar_chart_outlined,
                          iconColor: ColorConstants.darkPrimaryIcon,
                          glowColor: ColorConstants.darkPrimaryIcon,
                          label: 'LAPORAN',
                          desc: 'Lihat laporan dan analisis data',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LaporanScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildMenuCard(
                    context: context,
                    icon: Icons.list_alt_outlined,
                    iconColor: const Color(0xFF00bcd4),
                    glowColor: const Color(0xFF00bcd4),
                    label: 'PRODUK',
                    desc: 'Kelola data produk & stok',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProductListView(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  GlowCard(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: ColorConstants.darkPrimaryIcon.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.trending_up,
                            color: ColorConstants.darkPrimaryIcon,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ringkasan Hari Ini',
                                style: TextStyle(
                                  color: ColorConstants.whiteText,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Pantau perkembangan bisnis Anda secara real-time',
                                style: TextStyle(
                                  color: ColorConstants.grayText,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right,
                          color: ColorConstants.darkPrimaryIcon,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required Color glowColor,
    required String label,
    required String desc,
    required VoidCallback onTap,
  }) {
    return GlowCard(
      glowColor: glowColor,
      borderColor: glowColor.withOpacity(0.3),
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      glowColor,
                      glowColor.withOpacity(0.6),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: glowColor.withOpacity(0.4),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 26),
              ),
              const Spacer(),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: glowColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.chevron_right,
                  color: glowColor,
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              color: ColorConstants.whiteText,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            desc,
            style: const TextStyle(
              color: ColorConstants.grayText,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
