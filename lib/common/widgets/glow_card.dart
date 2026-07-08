import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:syathiby/core/constants/color_constants.dart';

class GlowCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? glowColor;
  final Color? borderColor;
  final Color? backgroundColor;

  const GlowCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.borderRadius = 20,
    this.glowColor,
    this.borderColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveGlow = glowColor ?? ColorConstants.secondaryBlue;
    final effectiveBorder = borderColor ?? ColorConstants.glassBorder;
    final effectiveBg = backgroundColor ?? ColorConstants.glassCardSolid;

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        color: effectiveBg,
        border: Border.all(color: effectiveBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: effectiveGlow.withOpacity(0.15),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(borderRadius),
              child: Padding(
                padding: padding ?? const EdgeInsets.all(20),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
