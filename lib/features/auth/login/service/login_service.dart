import 'package:dio/dio.dart';
import 'package:syathiby/core/models/http_response_model.dart';
import 'package:syathiby/core/services/device_info_service.dart';
import 'package:syathiby/core/services/shared_preferences_service.dart';
import 'package:syathiby/core/utils/logger_util.dart';

class LoginService {
  final Dio _dio;

  LoginService(this._dio);

  Future<HttpResponseModel> login(String username, String password) async {
    try {
      final deviceString = DeviceInfoService.instance.getCachedDeviceString();
      final response = await _dio.post(
        '/api/auth/do_login',
        data: FormData.fromMap({
          'username': username,
          'password': password,
        }),
        options: Options(headers: {'device': deviceString}),
      );

      if (response.data['status'] == true) {
        final result = response.data['result'][0];
        final String token = result['token'];
        final String userId = result['user_id'] ?? '';
        final String brId = result['br_id'] ?? '';

        await SharedPreferencesService.instance
            .setData<String>(PreferenceKey.authToken, token);
        await SharedPreferencesService.instance
            .setData<String>(PreferenceKey.userId, userId);
        await SharedPreferencesService.instance
            .setData<String>(PreferenceKey.branchId, brId);

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
