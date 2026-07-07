import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:syathiby/core/utils/router/routes.dart';
import 'package:syathiby/features/auth/login/bloc/login_bloc.dart';
import 'package:syathiby/features/auth/login/bloc/login_event.dart';
import 'package:syathiby/features/auth/login/bloc/login_state.dart';
import 'package:syathiby/features/profile/bloc/profile_bloc.dart';
import 'package:syathiby/features/profile/bloc/profile_state.dart';
import 'package:syathiby/features/theme/bloc/theme_bloc.dart';
import 'package:syathiby/features/theme/bloc/theme_event.dart';
import 'package:syathiby/features/theme/bloc/theme_state.dart';
import 'package:syathiby/core/constants/app_constants.dart';
import 'package:syathiby/core/constants/color_constants.dart';
import 'package:syathiby/core/constants/supported_locales.dart';
import 'package:syathiby/locale_keys.g.dart';
import 'package:syathiby/common/helpers/ui_helper.dart';
import 'package:syathiby/common/widgets/gradient_header.dart';
import 'package:syathiby/common/widgets/glow_card.dart';
import 'package:syathiby/features/profile/widget/profile_photo_widget.dart';
import 'package:syathiby/common/widgets/unauthenticated_user_widget.dart';
import 'package:package_info_plus/package_info_plus.dart';
part "settings_view_mixin.dart";

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> with SettingsViewMixin {
  String _appVersion = "Loading...";

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = "v${packageInfo.version}";
    });
  }

  @override
  Widget build(BuildContext context) {
    final LoginBloc loginBloc = BlocProvider.of<LoginBloc>(context);
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, loginState) {
        return BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, profileState) {
            return Scaffold(
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    const GradientHeader(title: 'Pengaturan'),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          profileState.user != null
                              ? GlowCard(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    children: [
                                      ListTile(
                                        onTap: () {
                                          context.push(Routes.profile.path);
                                        },
                                        contentPadding: EdgeInsets.zero,
                                        leading: SizedBox(
                                          width: UIHelper.deviceWidth * 0.12,
                                          child: ProfilePhotoWidget(
                                              imageUrl: profileState.user!.photoUrl),
                                        ),
                                        title: Text(
                                          "${profileState.user?.name}",
                                          style: const TextStyle(
                                            color: ColorConstants.whiteText,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 18,
                                          ),
                                        ),
                                        subtitle: Text(
                                          profileState.user!.email,
                                          style: const TextStyle(
                                            color: ColorConstants.grayText,
                                          ),
                                        ),
                                        trailing: const Icon(
                                          CupertinoIcons.forward,
                                          color: ColorConstants.grayText,
                                        ),
                                      ),
                                      Divider(height: 1, color: ColorConstants.glassBorder),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Text(
                                          "${LocaleKeys.you_joined_on_prefix.tr()}${AppConstants.dateformat.format(profileState.user!.createdAt)}${LocaleKeys.you_joined_on_suffix.tr()} ($_appVersion)",
                                          style: const TextStyle(
                                            color: ColorConstants.grayText,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : const UnauthenticatedUserWidget(),
                          const SizedBox(height: 12),
                          _buildSettingsTile(
                            title: LocaleKeys.theme.tr(),
                            icon: CupertinoIcons.sun_min_fill,
                            iconColor: CupertinoColors.systemBlue,
                            onTap: () => _showSelectThemeSheet(context),
                          ),
                          const SizedBox(height: 8),
                          _buildSettingsTile(
                            title: LocaleKeys.language.tr(),
                            icon: CupertinoIcons.globe,
                            iconColor: CupertinoColors.systemGreen,
                            onTap: () => _showSelectLanguageSheet(context),
                          ),
                          const SizedBox(height: 8),
                          _buildSettingsTile(
                            title: LocaleKeys.logout.tr(),
                            icon: CupertinoIcons.square_arrow_left_fill,
                            iconColor: CupertinoColors.systemRed,
                            onTap: () => _showLogOutDialog(context, loginBloc),
                          ),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSettingsTile({
    required String title,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GlowCard(
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              color: ColorConstants.whiteText,
              fontSize: 16,
            ),
          ),
          const Spacer(),
          const Icon(
            CupertinoIcons.forward,
            color: ColorConstants.grayText,
          ),
        ],
      ),
    );
  }
}
