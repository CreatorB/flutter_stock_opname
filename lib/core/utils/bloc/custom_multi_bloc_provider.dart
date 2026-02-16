import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syathiby/core/di/injection.dart'; 
import 'package:syathiby/features/auth/login/bloc/login_bloc.dart';
import 'package:syathiby/features/product/bloc/product_bloc.dart';
import 'package:syathiby/features/auth/register/bloc/register_bloc.dart';
import 'package:syathiby/features/profile/bloc/profile_bloc.dart';
import 'package:syathiby/features/theme/bloc/theme_bloc.dart';
import 'package:syathiby/features/profile/service/user_service.dart'; // Still needed for other blocs

class CustomMultiBlocProvider extends StatelessWidget {
  final Widget child;
  const CustomMultiBlocProvider({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<ThemeBloc>()),
        BlocProvider(create: (_) => sl<LoginBloc>()),
        BlocProvider(create: (_) => sl<ProductBloc>()),
        BlocProvider(create: (context) => RegisterBloc(userService: UserService())), // Kept original RegisterBloc
        BlocProvider(create: (context) => ProfileBloc(userService: UserService())),
      ],
      child: child,
    );
  }
}
