import 'package:dio/dio.dart';
import 'package:syathiby/core/models/http_response_model.dart';
import 'package:syathiby/core/services/shared_preferences_service.dart';
import 'package:syathiby/core/utils/logger_util.dart';

class OpnameService {
  final Dio _dio;

  OpnameService(this._dio);

  Future<HttpResponseModel<List<OpnameDraftResponseModel>>> getDraft({
    String searchValue = '',
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

      final response = await _dio.post(
        '/api/opname/get_draft',
        data: FormData.fromMap({
          'user_id': userId,
          'br_id': brId,
          'searchValue': searchValue,
        }),
      );

      if (response.data['status'] == true) {
        final List<dynamic> result = response.data['result'] ?? [];
        final drafts =
            result.map((e) => OpnameDraftResponseModel.fromJson(e)).toList();
        return HttpResponseModel(
          statusCode: response.statusCode,
          data: drafts,
          message: response.data['msg'],
        );
      } else {
        return HttpResponseModel(
          statusCode: response.statusCode,
          message: response.data['msg'] ?? 'Failed to load draft',
        );
      }
    } on DioException catch (e) {
      LoggerUtil.error('Get opname draft error', e);
      return HttpResponseModel(
        statusCode: e.response?.statusCode ?? 500,
        message: e.message ?? 'Connection error',
      );
    } catch (e) {
      LoggerUtil.error('Get opname draft unknown error', e);
      return HttpResponseModel(
        statusCode: 500,
        message: e.toString(),
      );
    }
  }

  Future<HttpResponseModel<OpnameSaveResponseModel>> doSaveBarcode({
    required String pId,
    required String qty,
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

      final response = await _dio.post(
        '/api/opname/do_save',
        data: FormData.fromMap({
          'user_id': userId,
          'br_id': brId,
          'p_id': pId,
          'qty': qty,
        }),
      );

      if (response.data['status'] == true) {
        return HttpResponseModel(
          statusCode: response.statusCode,
          data: OpnameSaveResponseModel.fromJson(response.data),
          message: response.data['msg'],
        );
      } else {
        return HttpResponseModel(
          statusCode: response.statusCode,
          message: response.data['msg'] ?? 'Failed to save barcode',
        );
      }
    } on DioException catch (e) {
      LoggerUtil.error(
        'Do save barcode error: status=${e.response?.statusCode} body=${e.response?.data} message=${e.message}',
        e,
      );
      return HttpResponseModel(
        statusCode: e.response?.statusCode ?? 500,
        message: e.response?.data?['msg']?.toString() ?? e.message ?? 'Connection error',
      );
    } catch (e) {
      LoggerUtil.error('Do save barcode unknown error', e);
      return HttpResponseModel(
        statusCode: 500,
        message: e.toString(),
      );
    }
  }

  Future<HttpResponseModel<OpnameFinishResponseModel>> doFinish({
    required String raId,
    String jenis = 'TOKO',
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

      final token = SharedPreferencesService.instance
          .getData<String>(PreferenceKey.authToken);

      LoggerUtil.debug(
        'doFinish request: ra_id=$raId jenis=$jenis user_id=$userId br_id=$brId',
      );

      final response = await _dio.post(
        '/api/opname/do_finish',
        data: FormData.fromMap({
          'token': token,
          'user_id': userId,
          'br_id': brId,
          'ra_id': raId,
          'jenis': jenis,
        }),
      );

      if (response.data['status'] == true) {
        return HttpResponseModel(
          statusCode: response.statusCode,
          data: OpnameFinishResponseModel.fromJson(response.data),
          message: response.data['msg'],
        );
      } else {
        return HttpResponseModel(
          statusCode: response.statusCode,
          message: response.data['msg'] ?? 'Failed to finish opname',
        );
      }
    } on DioException catch (e) {
      LoggerUtil.error(
        'Do finish opname error: status=${e.response?.statusCode} body=${e.response?.data} message=${e.message}',
        e,
      );
      return HttpResponseModel(
        statusCode: e.response?.statusCode ?? 500,
        message: e.response?.data?['msg']?.toString() ?? e.message ?? 'Connection error',
      );
    } catch (e) {
      LoggerUtil.error('Do finish opname unknown error', e);
      return HttpResponseModel(
        statusCode: 500,
        message: e.toString(),
      );
    }
  }
}

class OpnameSaveResponseModel {
  final bool status;
  final String? msg;
  final String? raId;

  OpnameSaveResponseModel({
    required this.status,
    this.msg,
    this.raId,
  });

  factory OpnameSaveResponseModel.fromJson(Map<String, dynamic> json) {
    return OpnameSaveResponseModel(
      status: json['status'] ?? false,
      msg: json['msg'],
      raId: json['ra_id']?.toString(),
    );
  }
}

class OpnameFinishResponseModel {
  final bool status;
  final String? msg;
  final String? opnameId;

  OpnameFinishResponseModel({
    required this.status,
    this.msg,
    this.opnameId,
  });

  factory OpnameFinishResponseModel.fromJson(Map<String, dynamic> json) {
    return OpnameFinishResponseModel(
      status: json['status'] ?? false,
      msg: json['msg'],
      opnameId: json['opname_id']?.toString(),
    );
  }
}

class OpnameDraftResponseModel {
  final String? pId;
  final String? pCode;
  final String? pName;
  final String? qty;
  final String? raId;
  final String? raName;
  final String? systemStock;

  OpnameDraftResponseModel({
    this.pId,
    this.pCode,
    this.pName,
    this.qty,
    this.raId,
    this.raName,
    this.systemStock,
  });

  factory OpnameDraftResponseModel.fromJson(Map<String, dynamic> json) {
    return OpnameDraftResponseModel(
      pId: json['p_id']?.toString(),
      pCode: json['p_code'],
      pName: json['p_name'],
      qty: json['qty']?.toString(),
      raId: json['ra_id']?.toString(),
      raName: json['ra_name'],
      systemStock: json['system_stock']?.toString(),
    );
  }
}