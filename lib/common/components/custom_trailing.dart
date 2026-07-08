import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:syathiby/core/constants/color_constants.dart';

class CustomTrailing extends StatelessWidget {
  final String text;
  final bool isLoading;
  final bool showLoadingIndicator;
  final void Function()? onPressed;
  const CustomTrailing({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.showLoadingIndicator = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        (isLoading && showLoadingIndicator)
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(ColorConstants.darkPrimaryIcon),
                ),
              )
            : TextButton(
                onPressed: isLoading ? null : onPressed,
                child: Text(
                  text.tr(),
                  style: TextStyle(
                    color: isLoading ? ColorConstants.darkInactive : ColorConstants.darkPrimaryIcon,
                  ),
                ),
              ),
      ],
    );
  }
}
