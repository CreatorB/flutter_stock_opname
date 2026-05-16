part of "login_view.dart";

mixin LoginViewMixin on State<LoginView> {
  late TextEditingController _usernameTextEditingController;
  late TextEditingController _passwordTextEditingController;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _usernameTextEditingController = TextEditingController();
    _passwordTextEditingController = TextEditingController();
    _loadSavedCredentials();
  }

  void _loadSavedCredentials() {
    final rememberMe = SharedPreferencesService.instance
            .getData<bool>(PreferenceKey.rememberMe) ??
        false;
    if (rememberMe) {
      final savedUsername = SharedPreferencesService.instance
              .getData<String>(PreferenceKey.savedEmail) ?? // Reusing savedEmail key for username for now
          '';
      final savedPassword = SharedPreferencesService.instance
              .getData<String>(PreferenceKey.savedPassword) ??
          '';

      setState(() {
        _rememberMe = rememberMe;
        _usernameTextEditingController.text = savedUsername;
        _passwordTextEditingController.text = savedPassword;
      });
    }
  }

  Future<void> _saveCredentials() async {
    await SharedPreferencesService.instance
        .setData(PreferenceKey.rememberMe, _rememberMe);

    if (_rememberMe) {
      await SharedPreferencesService.instance
          .setData(PreferenceKey.savedEmail, _usernameTextEditingController.text); // Reusing key
      await SharedPreferencesService.instance.setData(
          PreferenceKey.savedPassword, _passwordTextEditingController.text);
    } else {
      await SharedPreferencesService.instance
          .removeData(PreferenceKey.savedEmail);
      await SharedPreferencesService.instance
          .removeData(PreferenceKey.savedPassword);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _usernameTextEditingController.dispose();
    _passwordTextEditingController.dispose();
  }

  void _showForgotPasswordModalPopup() {
    // Forgot password might still need email or username, leaving as is for now but passing username controller if needed
    // However, the View expects email controller. I should probably change variable name in View too.
    // But since this is a mixin, I can just expose _usernameTextEditingController via getters or just access it.
    showCupertinoModalPopup(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return ForgotPasswordView(
          textEditingController: _usernameTextEditingController,
          forgotPasswordListener: _forgotPasswordListener,
        );
      },
    );
  }

  void _forgotPasswordListener(RegisterState state) {
    if (state is ForgotPasswordCheckSuccess) {
      if (state.data != null && state.data!) {
        if (state.verificationCode != null) {
          context.go(Routes.verify.path);
        }
      }
    } else if (state is ForgotPasswordCheckFailed) {
      AppHelper.showErrorMessage(
          context: context, content: LocaleKeys.non_existent_user_message.tr());
    } else if (state is CheckFailed) {
      AppHelper.showErrorMessage(
          context: context, content: LocaleKeys.something_went_wrong.tr());
    }
  }

  void _listener(LoginState state) {
    if (state is LoginSuccess) {
      LoggerUtil.debug('Login Success, redirecting to home...');
      final ProfileBloc profileBloc = BlocProvider.of<ProfileBloc>(context);
      profileBloc.add(SetUser(user: state.user));

      Future.microtask(() {
        if (mounted) context.go(Routes.navigation.path);
      });
    } else if (state is LoginFailed) {
      if (state.statusCode == 401) {
        AppHelper.showErrorMessage(
            context: context,
            content: state.message ?? LocaleKeys.check_your_information.tr());
      } else {
        AppHelper.showErrorMessage(
            context: context,
            content: state.message ?? LocaleKeys.something_went_wrong.tr());
      }
    }
  }

  void _submit(LoginBloc loginBloc) async {
    final username = _usernameTextEditingController.text.trim();
    final password = _passwordTextEditingController.text.trim();

    // Debug print untuk input
    LoggerUtil.debug('Submitting - Username: $username, Password length: ${password.length}');

    HttpResponseModel httpResponseModel = AppHelper.checkLoginCredentials(
      username: username,
      password: password,
    );

    if (httpResponseModel.statusCode == 200) {
      await _saveCredentials();
      if (!mounted) return;
      loginBloc.add(
        LoginButtonPressed(
          username: username,
          password: password,
        ),
      );
    } else {
      LoggerUtil.debug('Validation Error: ${httpResponseModel.message}');
      AppHelper.showErrorMessage(
          context: context,
          content: httpResponseModel.message ??
              LocaleKeys.check_your_information.tr());
    }
  }
}
