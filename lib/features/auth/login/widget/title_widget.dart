import 'package:flutter/material.dart';
import 'package:syathiby/core/constants/color_constants.dart';

class TitleWidget extends StatelessWidget {
  const TitleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          'assets/images/ic_launcher.png',
          width: 120,
          height: 120,
        ),
        const SizedBox(height: 16),
        const Text(
          'Mobile',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: ColorConstants.darkPrimaryIcon,
          ),
        ),
        const Text(
          ' Store',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: ColorConstants.secondaryBlue,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Kelola lebih mudah, bisnis lebih maju',
          style: TextStyle(
            fontSize: 14,
            color: ColorConstants.grayText,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
