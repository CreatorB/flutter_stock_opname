import 'package:flutter/material.dart';

class BaseTabPage extends StatelessWidget {
  final Widget child;
  final bool showPadding;
  final EdgeInsets padding;

  const BaseTabPage({
    super.key,
    required this.child,
    this.showPadding = true,
    this.padding = const EdgeInsets.only(left: 20, right: 20),
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: showPadding
          ? Padding(
              padding: padding,
              child: child,
            )
          : child,
    );
  }
}