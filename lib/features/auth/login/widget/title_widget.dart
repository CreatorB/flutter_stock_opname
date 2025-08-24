import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:syathiby/core/constants/color_constants.dart';
import 'package:syathiby/generated/locale_keys.g.dart';

class TitleWidget extends StatelessWidget {
  const TitleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      LocaleKeys.app_name.tr(),
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: ColorConstants.lightPrimaryText, 
      ),
    );
  }
}
