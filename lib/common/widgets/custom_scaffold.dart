import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:syathiby/core/constants/color_constants.dart';
import 'package:syathiby/common/widgets/gradient_header.dart';

class CustomScaffold extends StatefulWidget {
  final String title;
  final List<Widget> children;
  final Future<void> Function()? onRefresh;
  final Widget? trailing;
  final Color? navigationBarBackgroundColor;
  final bool automaticallyImplyLeading;
  final EdgeInsetsDirectional? navigationBarPadding;
  final ScrollController? scrollController;

  const CustomScaffold({
    super.key,
    required this.title,
    required this.children,
    this.onRefresh,
    this.trailing,
    this.navigationBarBackgroundColor = Colors.transparent,
    this.automaticallyImplyLeading = true,
    this.navigationBarPadding,
    this.scrollController,
  });

  @override
  State<CustomScaffold> createState() => _CustomScaffoldState();
}

class _CustomScaffoldState extends State<CustomScaffold> {
  late final ScrollController _effectiveScrollController;

  @override
  void initState() {
    super.initState();
    _effectiveScrollController = widget.scrollController ?? ScrollController();
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      _effectiveScrollController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        body: Column(
          children: [
            GradientHeader(
              title: widget.title.tr(),
              trailing: widget.trailing,
            ),
            Expanded(
              child: widget.onRefresh != null
                  ? RefreshIndicator(
                      onRefresh: widget.onRefresh!,
                      color: ColorConstants.darkPrimaryIcon,
                      child: _buildScrollView(),
                    )
                  : _buildScrollView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScrollView() {
    return SingleChildScrollView(
      controller: _effectiveScrollController,
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            ...widget.children,
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
