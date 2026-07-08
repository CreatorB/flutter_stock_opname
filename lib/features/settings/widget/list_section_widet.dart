import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syathiby/core/constants/color_constants.dart';
import 'package:syathiby/features/theme/bloc/theme_bloc.dart';
import 'package:syathiby/features/theme/bloc/theme_state.dart';

class ListSectionWidget extends StatelessWidget {
  final List<Widget>? children;
  final double dividerMargin;
  final bool hasLeading;
  const ListSectionWidget({
    super.key,
    this.children,
    this.dividerMargin = 14,
    this.hasLeading = true,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            child: Material(
              color: ColorConstants.glassCardSolid,
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              child: Column(
                children: children ?? [],
              ),
            ),
          ),
        );
      },
    );
  }
}
