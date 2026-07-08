import 'package:flutter/material.dart';
import 'package:syathiby/core/constants/color_constants.dart';
import 'package:syathiby/common/widgets/glow_card.dart';

class UnauthenticatedUserWidget extends StatelessWidget {
  const UnauthenticatedUserWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GlowCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(
            Icons.person_outline,
            size: 48,
            color: ColorConstants.darkPrimaryIcon,
          ),
          const SizedBox(height: 12),
          const Text(
            'Tidak ada pengguna terdaftar',
            style: TextStyle(
              color: ColorConstants.whiteText,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Silakan login untuk mengakses fitur ini',
            style: TextStyle(color: ColorConstants.grayText),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
