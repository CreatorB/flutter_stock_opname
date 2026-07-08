import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:syathiby/core/services/shared_preferences_service.dart';
import 'package:syathiby/core/utils/logger_util.dart';
import 'package:syathiby/core/utils/router/routes.dart';
import 'package:syathiby/features/auth/login/bloc/login_bloc.dart';
import 'package:syathiby/features/auth/login/bloc/login_event.dart';
import 'package:syathiby/features/auth/login/bloc/login_state.dart';
import 'package:syathiby/features/auth/register/bloc/register_state.dart';
import 'package:syathiby/features/profile/bloc/profile_bloc.dart';
import 'package:syathiby/features/profile/bloc/profile_event.dart';
import 'package:syathiby/core/constants/color_constants.dart';
import 'package:syathiby/locale_keys.g.dart';
import 'package:syathiby/common/helpers/app_helper.dart';
import 'package:syathiby/core/models/http_response_model.dart';
import 'package:syathiby/features/auth/password/view/forgot_password_view.dart';
import 'package:syathiby/features/auth/login/widget/background_widget.dart';
import 'package:syathiby/features/auth/login/widget/login_button.dart';
import 'package:syathiby/features/auth/login/widget/title_widget.dart';

import 'package:syathiby/features/auth/login/widget/config_view.dart';

part "login_view_mixin.dart";

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> with LoginViewMixin {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final LoginBloc loginBloc = BlocProvider.of<LoginBloc>(context);
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        body: Stack(
          children: [
            const BackgroundWidget(),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: ColorConstants.glassCard,
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(color: ColorConstants.glassBorder),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.settings, color: ColorConstants.grayText, size: 22),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) => const ConfigView()),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const TitleWidget(),
                    const SizedBox(height: 40),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: ColorConstants.glassCardSolid,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: ColorConstants.glassBorder, width: 1),
                      ),
                      child: BlocListener<LoginBloc, LoginState>(
                        listener: (context, state) {
                          _listener(state);
                        },
                        child: BlocBuilder<LoginBloc, LoginState>(
                          builder: (context, state) {
                            return Column(
                              children: [
                                _buildNewTextField(
                                  controller: _usernameTextEditingController,
                                  placeholder: "Username",
                                  icon: Icons.person_outline,
                                  enabled: !state.isLoading,
                                ),
                                const SizedBox(height: 12),
                                _buildNewTextField(
                                  controller: _passwordTextEditingController,
                                  placeholder: LocaleKeys.password.tr(),
                                  icon: Icons.lock_outline,
                                  obscureText: _obscurePassword,
                                  enabled: !state.isLoading,
                                  textInputAction: TextInputAction.done,
                                  onSubmitted: (value) => _submit(loginBloc),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                      color: ColorConstants.secondaryBlue,
                                    ),
                                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Checkbox(
                                      value: _rememberMe,
                                      onChanged: (bool? value) {
                                        setState(() => _rememberMe = value ?? false);
                                      },
                                      activeColor: ColorConstants.darkPrimaryColor,
                                      checkColor: Colors.white,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      LocaleKeys.remember_me.tr(),
                                      style: const TextStyle(color: ColorConstants.grayText),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                LoginButton(
                                  isLoading: state.isLoading,
                                  onPressed: () => _submit(loginBloc),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: _showForgotPasswordModalPopup,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.headset, color: ColorConstants.secondaryBlue, size: 20),
                          const SizedBox(width: 6),
                          Text(
                            'Butuh bantuan?',
                            style: TextStyle(color: ColorConstants.secondaryBlue, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewTextField({
    required TextEditingController controller,
    required String placeholder,
    required IconData icon,
    bool obscureText = false,
    bool enabled = true,
    TextInputAction? textInputAction,
    void Function(String)? onSubmitted,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: ColorConstants.darkTextField,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorConstants.glassBorder, width: 1),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        enabled: enabled,
        textInputAction: textInputAction,
        onSubmitted: onSubmitted,
        style: const TextStyle(color: ColorConstants.whiteText),
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: const TextStyle(color: ColorConstants.grayText),
          prefixIcon: Icon(icon, color: ColorConstants.darkPrimaryIcon),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}
