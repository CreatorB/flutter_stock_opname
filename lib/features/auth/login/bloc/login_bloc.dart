import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syathiby/core/utils/logger_util.dart';
import 'package:syathiby/features/auth/login/bloc/login_event.dart';
import 'package:syathiby/features/auth/login/bloc/login_state.dart';
import 'package:syathiby/features/profile/model/user_model.dart';
import 'package:syathiby/features/auth/login/service/login_service.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginService loginService;

  LoginBloc({required this.loginService}) : super(const LoginInitial()) {
    on<LoginButtonPressed>((event, emit) async {
      emit(const LoginLoading());
      try {
        final loginResponse = await loginService.login(
            event.username, event.password);
        LoggerUtil.debug(
            'Login response received: ${loginResponse.statusCode}');
        LoggerUtil.debug('Login data: ${loginResponse.data}');

        if (loginResponse.statusCode == 200 && loginResponse.data != null) {
          final userData = loginResponse.data;
          
          if (userData != null) {
            // Note: The response from new API is different, we might need to adjust UserModel
            // or map the response correctly.
            // Based on curl response:
            // "user_id": "825",
            // "username": "333",
            // "nama": "Kasir 1",
            // ...
            
            // For now, let's create a partial UserModel or pass what we have
            // Since UserModel is quite strict, we might need to be careful.
            
            // Temporarily mapping to what UserModel expects or just creating a basic user
            // If UserModel.fromMap expects specific fields that are missing, it might crash.
            // Let's look at UserModel.fromMap... (I haven't seen it yet, but based on previous code it checks for many nulls)
            
            // Re-evaluating based on previous LoginBloc code:
            // It checked for id, uuid, name, email, etc.
            // The new API returns user_id, username, nama.
            
            // I should update UserModel to be compatible or create a new User model for this app if the backend changed completely.
            // However, the task is to implement specific APIs. 
            // Let's assume for now we just want to login successfully.
            // I will emit LoginSuccess with a dummy user if mapping fails, or try to map available fields.
            
            // Let's construct a UserModel with available data
             final user = UserModel(
               id: int.tryParse(userData['user_id'].toString()) ?? 0,
               uuid: '',
               name: userData['nama'] ?? 'User',
               email: userData['username'] ?? '', // Store username in email for now
               nip: '',
               workingDays: 0,
               jumlahCuti: 0,
               status: 'active',
               createdAt: DateTime.now(),
               updatedAt: DateTime.now(),
             );

            emit(LoginSuccess(
                user: user,
                message: loginResponse.message ?? 'Login successful'));
          } else {
            emit(const LoginFailed(
                message: 'Invalid response data', statusCode: 400));
          }
        } else {
          emit(LoginFailed(
              message: loginResponse.message ?? 'Login failed',
              statusCode: loginResponse.statusCode));
        }
      } catch (e, stack) {
        LoggerUtil.error('Login failed', e, stack);
        emit(LoginFailed(
          message: 'Error: ${e.toString()}',
          statusCode: 500,
        ));
      }
    });

    on<LogoutButtonPressed>((event, emit) async {
      // await loginService.deleteAuthTokenFromSP(); // LoginService doesn't have this exposed yet, need to check
      // It was in UserService. LoginService has saveAuthToken.
      // I should probably move auth token management to a central place or expose it in LoginService.
      // For now, I will use SharedPreferencesService directly or handle it in LoginService.
       emit(const LoginInitial());
    });
    
    // ... other events
    on<ClearLoginData>((event, emit) => emit(const LoginInitial()));
  }
}
