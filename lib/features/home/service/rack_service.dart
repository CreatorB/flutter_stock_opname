import 'package:dio/dio.dart';
import 'package:syathiby/core/models/http_response_model.dart';
import 'package:syathiby/core/services/shared_preferences_service.dart';
import 'package:syathiby/core/utils/logger_util.dart';
import 'package:syathiby/features/home/service/rack_model.dart';

class RackService {
  final Dio _dio;

  RackService(this._dio);

  Future<HttpResponseModel<List<RackModel>>> getRacks({
    String searchValue = '',
  }) async {
    try {
      final token = SharedPreferencesService.instance
          .getData<String>(PreferenceKey.authToken);

      final response = await _dio.post(
        '/api/rack/data',
        data: FormData.fromMap({
          'token': token,
          'searchValue': searchValue,
        }),
      );

      if (response.data['status'] == true) {
        final List<dynamic> result = response.data['result'] ?? [];
        final racks = result.map((e) => RackModel.fromJson(e)).toList();
        return HttpResponseModel(
          statusCode: response.statusCode,
          data: racks,
          message: response.data['msg'],
        );
      } else {
        return HttpResponseModel(
          statusCode: response.statusCode,
          message: response.data['msg'] ?? 'Failed to load racks',
        );
      }
    } on DioException catch (e) {
      LoggerUtil.error('Get racks error', e);
      return HttpResponseModel(
        statusCode: e.response?.statusCode ?? 500,
        message: e.message ?? 'Connection error',
      );
    } catch (e) {
      LoggerUtil.error('Get racks unknown error', e);
      return HttpResponseModel(
        statusCode: 500,
        message: e.toString(),
      );
    }
  }
}