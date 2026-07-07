import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syathiby/core/constants/color_constants.dart';
import 'package:syathiby/features/theme/bloc/theme_bloc.dart';
import 'package:syathiby/features/theme/bloc/theme_state.dart';

class ListTileWidget extends StatelessWidget {
  final String title;
  final IconData? leadingIcon;
  final Color? leadingColor;
  final FutureOr<void> Function()? onTap;
  final TextStyle? titleTextStyle;
  const ListTileWidget({
    super.key,
    required this.title,
    this.leadingIcon,
    this.leadingColor = Colors.blue,
    this.onTap,
    this.titleTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  if (leadingIcon != null) ...[
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: leadingColor?.withOpacity(0.2),
                        borderRadius: const BorderRadius.all(Radius.circular(5)),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        leadingIcon,
                        color: leadingColor,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Text(
                      title,
                      style: titleTextStyle ??
                          const TextStyle(
                            color: ColorConstants.whiteText,
                            fontSize: 16,
                          ),
                    ),
                  ),
                  if (onTap != null)
                    Icon(
                      Icons.chevron_right,
                      color: ColorConstants.darkSecondaryIcon,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
