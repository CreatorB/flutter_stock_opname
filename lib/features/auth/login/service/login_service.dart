import 'package:dio/dio.dart';
import 'package:syathiby/core/models/http_response_model.dart';
import 'package:syathiby/core/services/shared_preferences_service.dart';
import 'package:syathiby/core/utils/logger_util.dart';

class LoginService {
  final Dio _dio;

  LoginService(this._dio);

  Future<HttpResponseModel> login(String username, String password) async {
    try {
      final response = await _dio.post(
        '/api/auth/do_login',
        data: FormData.fromMap({
          'username': username,
          'password': password,
        }),
      );

      if (response.data['status'] == true) {
        final result = response.data['result'][0];
        final String token = result['token'];

        // Save token
        await SharedPreferencesService.instance
            .setData<String>(PreferenceKey.authToken, token);
        
        // Save user data if needed (optional based on response structure)
        // Note: The response structure is quite different from the previous implementation
        // Adjusting to match the new API response

        return HttpResponseModel(
          statusCode: response.statusCode,
          data: result,
          message: result['msg'],
        );
      } else {
        return HttpResponseModel(
          statusCode: response.statusCode,
          message: response.data['msg'] ?? 'Login failed',
        );
      }
    } on DioException catch (e) {
      LoggerUtil.error('Login error', e);
      return HttpResponseModel(
        statusCode: e.response?.statusCode ?? 500,
        message: e.response?.data['msg'] ?? e.message ?? 'Connection error',
      );
    } catch (e) {
      LoggerUtil.error('Login unknown error', e);
      return HttpResponseModel(
        statusCode: 500,
        message: e.toString(),
      );
    }
  }

  Future<HttpResponseModel> validateToken(String token) async {
    try {
      final response = await _dio.post(
        '/api/auth/validate_token',
        data: FormData.fromMap({
          'token': token,
        }),
      );

      return HttpResponseModel(
        statusCode: response.statusCode,
        data: response.data,
        message: response.data['msg'],
      );
    } on DioException catch (e) {
      return HttpResponseModel(
        statusCode: e.response?.statusCode ?? 500,
        message: e.message ?? 'Connection error',
      );
    }
  }
}
