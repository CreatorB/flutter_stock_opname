import 'package:dio/dio.dart';
import 'package:syathiby/core/models/http_response_model.dart';
import 'package:syathiby/core/services/shared_preferences_service.dart';
import 'package:syathiby/core/utils/logger_util.dart';
import 'package:syathiby/features/laporan/models/laporan_model.dart';

class LaporanService {
  final Dio _dio;

  LaporanService(this._dio);

  String? _requireUserId() {
    return SharedPreferencesService.instance
        .getData<String>(PreferenceKey.userId);
  }

  String? _requireBranchId() {
    return SharedPreferencesService.instance
        .getData<String>(PreferenceKey.branchId);
  }

  Map<String, String> _requireContext() {
    final userId = _requireUserId();
    final brId = _requireBranchId();
    if (userId == null || brId == null) {
      throw _MissingAuthContext();
    }
    return {'user_id': userId, 'br_id': brId};
  }

  String _formatApiDate(String isoDate) {
    if (isoDate.isEmpty) return '';
    final parts = isoDate.split('-');
    if (parts.length != 3) return isoDate;
    return '${parts[2]}/${parts[1]}/${parts[0]}';
  }

  Future<HttpResponseModel<PenjualanReportModel>> getPenjualanReport({
    String startDate = '',
    String endDate = '',
    String searchValue = '',
    int pStart = 0,
    int pLength = 50,
  }) async {
    try {
      final ctx = _requireContext();
      final response = await _dio.post(
        '/api/report/data_sale',
        data: FormData.fromMap({
          'br_id': ctx['br_id'],
          if (startDate.isNotEmpty) 'tgl1': _formatApiDate(startDate),
          if (endDate.isNotEmpty) 'tgl2': _formatApiDate(endDate),
          'searchValue': searchValue,
          'pStart': pStart,
          'pLength': pLength,
        }),
      );

      LoggerUtil.debug('report/data_sale response: ${response.data}');

      if (response.data['status'] == true) {
        return HttpResponseModel(
          statusCode: response.statusCode,
          data: PenjualanReportModel.fromResponse(response.data),
          message: response.data['msg'],
        );
      } else {
        return HttpResponseModel(
          statusCode: response.statusCode,
          message: response.data['msg'] ?? 'Gagal memuat laporan penjualan',
        );
      }
    } on _MissingAuthContext {
      return HttpResponseModel(
        statusCode: 401,
        message: 'Unauthorized: Missing user/branch id',
      );
    } on DioException catch (e) {
      LoggerUtil.error(
        'Report penjualan error: status=${e.response?.statusCode} body=${e.response?.data} message=${e.message}',
        e,
      );
      return HttpResponseModel(
        statusCode: e.response?.statusCode ?? 500,
        message: _extractErrorMessage(e.response?.data, e.message),
      );
    } catch (e, stack) {
      LoggerUtil.error('Report penjualan unknown error', e, stack);
      return HttpResponseModel(
        statusCode: 500,
        message: e.toString(),
      );
    }
  }

  Future<HttpResponseModel<OpnameReportModel>> getOpnameReport({
    String startDate = '',
    String endDate = '',
    String searchValue = '',
    int pStart = 0,
    int pLength = 50,
  }) async {
    try {
      final ctx = _requireContext();
      final response = await _dio.post(
        '/api/report/data_opname',
        data: FormData.fromMap({
          'br_id': ctx['br_id'],
          if (startDate.isNotEmpty) 'tgl1': _formatApiDate(startDate),
          if (endDate.isNotEmpty) 'tgl2': _formatApiDate(endDate),
          'op_type': 'TOKO',
          'searchValue': searchValue,
          'pStart': pStart,
          'pLength': pLength,
        }),
      );

      LoggerUtil.debug('report/data_opname response: ${response.data}');

      if (response.data['status'] == true) {
        return HttpResponseModel(
          statusCode: response.statusCode,
          data: OpnameReportModel.fromResponse(response.data),
          message: response.data['msg'],
        );
      } else {
        return HttpResponseModel(
          statusCode: response.statusCode,
          message: response.data['msg'] ?? 'Gagal memuat laporan opname',
        );
      }
    } on _MissingAuthContext {
      return HttpResponseModel(
        statusCode: 401,
        message: 'Unauthorized: Missing user/branch id',
      );
    } on DioException catch (e) {
      LoggerUtil.error(
        'Report opname error: status=${e.response?.statusCode} body=${e.response?.data} message=${e.message}',
        e,
      );
      return HttpResponseModel(
        statusCode: e.response?.statusCode ?? 500,
        message: _extractErrorMessage(e.response?.data, e.message),
      );
    } catch (e, stack) {
      LoggerUtil.error('Report opname unknown error', e, stack);
      return HttpResponseModel(
        statusCode: 500,
        message: e.toString(),
      );
    }
  }

  Future<HttpResponseModel<SetoranReportModel>> getSetoranReport({
    String startDate = '',
    String endDate = '',
    String searchValue = '',
    int pStart = 0,
    int pLength = 50,
  }) async {
    try {
      final ctx = _requireContext();
      final response = await _dio.post(
        '/api/report/data_setoran',
        data: FormData.fromMap({
          'br_id': ctx['br_id'],
          if (startDate.isNotEmpty) 'tgl1': _formatApiDate(startDate),
          if (endDate.isNotEmpty) 'tgl2': _formatApiDate(endDate),
          'searchValue': searchValue,
          'pStart': pStart,
          'pLength': pLength,
        }),
      );

      LoggerUtil.debug('report/data_setoran response: ${response.data}');

      if (response.data['status'] == true) {
        return HttpResponseModel(
          statusCode: response.statusCode,
          data: SetoranReportModel.fromResponse(response.data),
          message: response.data['msg'],
        );
      } else {
        return HttpResponseModel(
          statusCode: response.statusCode,
          message: response.data['msg'] ?? 'Gagal memuat laporan setoran',
        );
      }
    } on _MissingAuthContext {
      return HttpResponseModel(
        statusCode: 401,
        message: 'Unauthorized: Missing user/branch id',
      );
    } on DioException catch (e) {
      LoggerUtil.error(
        'Report setoran error: status=${e.response?.statusCode} body=${e.response?.data} message=${e.message}',
        e,
      );
      return HttpResponseModel(
        statusCode: e.response?.statusCode ?? 500,
        message: _extractErrorMessage(e.response?.data, e.message),
      );
    } catch (e, stack) {
      LoggerUtil.error('Report setoran unknown error', e, stack);
      return HttpResponseModel(
        statusCode: 500,
        message: e.toString(),
      );
    }
  }

  String _extractErrorMessage(dynamic data, String? fallback) {
    if (data is Map && data['msg'] != null) {
      return data['msg'].toString();
    }
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    return fallback ?? 'Connection error';
  }
}

class _MissingAuthContext implements Exception {
  const _MissingAuthContext();
}