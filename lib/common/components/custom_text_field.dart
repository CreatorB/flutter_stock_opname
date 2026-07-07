import 'package:flutter/material.dart';
import 'package:syathiby/core/constants/color_constants.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController textEditingController;
  final bool enabled;
  final Widget? suffix;
  final String? placeholder;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final IconData? prefixIcon;
  final bool obscureText;
  final void Function(String)? onSubmitted;
  const CustomTextField({
    super.key,
    required this.textEditingController,
    this.enabled = true,
    this.suffix,
    this.placeholder,
    this.keyboardType,
    this.textInputAction = TextInputAction.next,
    this.prefixIcon,
    this.obscureText = false,
    this.onSubmitted,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool isObscureText = false;
  @override
  void initState() {
    isObscureText = widget.obscureText;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ColorConstants.darkTextField,
        border: Border.all(color: ColorConstants.glassBorder, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: widget.textEditingController,
        onSubmitted: widget.onSubmitted,
        obscureText: isObscureText,
        textInputAction: widget.textInputAction,
        keyboardType: widget.keyboardType,
        enabled: widget.enabled,
        style: const TextStyle(color: ColorConstants.whiteText),
        cursorColor: ColorConstants.darkPrimaryIcon,
        decoration: InputDecoration(
          hintText: widget.placeholder,
          hintStyle: const TextStyle(color: ColorConstants.grayText),
          prefixIcon: widget.prefixIcon != null
              ? Icon(widget.prefixIcon, color: ColorConstants.darkPrimaryIcon)
              : null,
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              widget.suffix ?? const SizedBox(),
              if (widget.obscureText)
                IconButton(
                  icon: Icon(
                    isObscureText ? Icons.visibility_off : Icons.visibility,
                    color: ColorConstants.darkSecondaryIcon,
                  ),
                  onPressed: () => setState(() => isObscureText = !isObscureText),
                ),
            ],
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
