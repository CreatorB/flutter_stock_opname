import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:syathiby/core/constants/color_constants.dart';
import 'package:syathiby/locale_keys.g.dart';
import 'package:syathiby/features/home/view/home_view.dart';
import 'package:syathiby/features/settings/view/settings_view.dart';

class NavigationView extends StatefulWidget {
  const NavigationView({super.key});

  @override
  State<NavigationView> createState() => _NavigationViewState();
}

class _NavigationViewState extends State<NavigationView> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          HomeView(),
          SettingsView(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: ColorConstants.bottomNavBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Icons.home,
                  label: LocaleKeys.home.tr(),
                  index: 0,
                ),
                _buildNavItem(
                  icon: Icons.settings,
                  label: LocaleKeys.settings.tr(),
                  index: 1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? ColorConstants.darkPrimaryIcon : ColorConstants.grayText,
            size: 26,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? ColorConstants.darkPrimaryIcon : ColorConstants.grayText,
              fontSize: 12,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          if (isActive)
            Container(
              width: 20,
              height: 3,
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                color: ColorConstants.darkPrimaryIcon,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
        ],
      ),
    );
  }
}
