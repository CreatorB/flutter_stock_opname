import 'package:dio/dio.dart';
import 'package:syathiby/core/models/http_response_model.dart';
import 'package:syathiby/core/services/shared_preferences_service.dart';
import 'package:syathiby/core/utils/logger_util.dart';
import 'package:syathiby/features/setoran/models/setoran_model.dart';

class SetoranService {
  final Dio _dio;

  SetoranService(this._dio);

  Future<HttpResponseModel<SetoranCheckModel?>> checkDeposit() async {
    try {
      final userId = SharedPreferencesService.instance
          .getData<String>(PreferenceKey.userId);
      final brId = SharedPreferencesService.instance
          .getData<String>(PreferenceKey.branchId);

      if (userId == null || brId == null) {
        return HttpResponseModel(
          statusCode: 401,
          message: 'Unauthorized: Missing user data',
        );
      }

      LoggerUtil.debug('check_deposit request: br_id=$brId user_id=$userId');

      final response = await _dio.post(
        '/api/deposit/check_deposit',
        data: FormData.fromMap({
          'br_id': brId,
          'user_id': userId,
        }),
      );

      if (response.data['status'] == true) {
        final dynamic result = response.data['result'];
        SetoranCheckModel? model;

        if (result is Map<String, dynamic>) {
          if (result.isEmpty ||
              (result['de_id'] == null &&
                  (result['tunai_amount'] == null &&
                      result['edc_amount'] == null &&
                      result['tunaiedc_amount'] == null &&
                      result['amount'] == null))) {
            model = null;
          } else {
            model = SetoranCheckModel.fromJson(result);
          }
        } else if (result is List && result.isNotEmpty) {
          model = SetoranCheckModel.fromJson(
            Map<String, dynamic>.from(result.first as Map),
          );
        }

        return HttpResponseModel(
          statusCode: response.statusCode,
          data: model,
          message: response.data['msg'],
        );
      } else {
        return HttpResponseModel(
          statusCode: response.statusCode,
          message: response.data['msg'] ?? 'Failed to check deposit',
        );
      }
    } on DioException catch (e) {
      LoggerUtil.error(
        'check_deposit error: status=${e.response?.statusCode} body=${e.response?.data} message=${e.message}',
        e,
      );
      return HttpResponseModel(
        statusCode: e.response?.statusCode ?? 500,
        message:
            e.response?.data?['msg']?.toString() ?? e.message ?? 'Connection error',
      );
    } catch (e) {
      LoggerUtil.error('check_deposit unknown error', e);
      return HttpResponseModel(
        statusCode: 500,
        message: e.toString(),
      );
    }
  }

  Future<HttpResponseModel<SetoranTrxSummaryModel>> getTrxSummary() async {
    try {
      final userId = SharedPreferencesService.instance
          .getData<String>(PreferenceKey.userId);
      final brId = SharedPreferencesService.instance
          .getData<String>(PreferenceKey.branchId);

      if (userId == null || brId == null) {
        return HttpResponseModel(
          statusCode: 401,
          message: 'Unauthorized: Missing user data',
        );
      }

      LoggerUtil.debug('get_trx_2d request: br_id=$brId user_id=$userId');

      final response = await _dio.post(
        '/api/deposit/get_trx_2d',
        data: FormData.fromMap({
          'br_id': brId,
          'user_id': userId,
        }),
      );

      if (response.data['status'] == true) {
        final dynamic result = response.data['result'];

        SetoranTrxSummaryModel summary;
        if (result is Map<String, dynamic>) {
          summary = SetoranTrxSummaryModel.fromJson(result);
        } else {
          summary = SetoranTrxSummaryModel.fromJson(
            Map<String, dynamic>.from(response.data),
          );
        }

        return HttpResponseModel(
          statusCode: response.statusCode,
          data: summary,
          message: response.data['msg'],
        );
      } else {
        return HttpResponseModel(
          statusCode: response.statusCode,
          message: response.data['msg'] ?? 'Failed to load trx summary',
        );
      }
    } on DioException catch (e) {
      LoggerUtil.error(
        'get_trx_2d error: status=${e.response?.statusCode} body=${e.response?.data} message=${e.message}',
        e,
      );
      return HttpResponseModel(
        statusCode: e.response?.statusCode ?? 500,
        message:
            e.response?.data?['msg']?.toString() ?? e.message ?? 'Connection error',
      );
    } catch (e) {
      LoggerUtil.error('get_trx_2d unknown error', e);
      return HttpResponseModel(
        statusCode: 500,
        message: e.toString(),
      );
    }
  }

  Future<HttpResponseModel<SetoranSaveResponseModel>> saveDeposit({
    required String tunaiAmount,
    required String edcAmount,
    required String tunaiedcAmount,
    required String amount,
  }) async {
    try {
      final userId = SharedPreferencesService.instance
          .getData<String>(PreferenceKey.userId);
      final brId = SharedPreferencesService.instance
          .getData<String>(PreferenceKey.branchId);

      if (userId == null || brId == null) {
        return HttpResponseModel(
          statusCode: 401,
          message: 'Unauthorized: Missing user data',
        );
      }

      LoggerUtil.debug(
        'do_finish deposit: br_id=$brId user_id=$userId tunai=$tunaiAmount edc=$edcAmount tunaiedc=$tunaiedcAmount amount=$amount',
      );

      final response = await _dio.post(
        '/api/deposit/do_finish',
        data: FormData.fromMap({
          'user_id': userId,
          'br_id': brId,
          'tunai_amount': tunaiAmount,
          'edc_amount': edcAmount,
          'tunaiedc_amount': tunaiedcAmount,
          'amount': amount,
        }),
      );

      if (response.data['status'] == true) {
        return HttpResponseModel(
          statusCode: response.statusCode,
          data: SetoranSaveResponseModel.fromJson(
            Map<String, dynamic>.from(response.data),
          ),
          message: response.data['msg'],
        );
      } else {
        if (response.data['result'] is Map<String, dynamic>) {
          return HttpResponseModel(
            statusCode: response.statusCode,
            data: SetoranSaveResponseModel.fromJson(
              Map<String, dynamic>.from(response.data['result']),
            ),
            message: response.data['msg'] ?? 'Failed to save deposit',
          );
        }
        return HttpResponseModel(
          statusCode: response.statusCode,
          message: response.data['msg'] ?? 'Failed to save deposit',
        );
      }
    } on DioException catch (e) {
      LoggerUtil.error(
        'do_finish deposit error: status=${e.response?.statusCode} body=${e.response?.data} message=${e.message}',
        e,
      );
      return HttpResponseModel(
        statusCode: e.response?.statusCode ?? 500,
        message:
            e.response?.data?['msg']?.toString() ?? e.message ?? 'Connection error',
      );
    } catch (e) {
      LoggerUtil.error('do_finish deposit unknown error', e);
      return HttpResponseModel(
        statusCode: 500,
        message: e.toString(),
      );
    }
  }
}
