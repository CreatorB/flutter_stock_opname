import 'package:dio/dio.dart';
import 'package:syathiby/core/models/http_response_model.dart';
import 'package:syathiby/core/utils/logger_util.dart';
import 'package:syathiby/features/sale/models/sale_model.dart';

class SaleService {
  final Dio _dio;

  SaleService(this._dio);

  Future<HttpResponseModel<SaleResponseModel>> createSale({
    required String userId,
    required String brId,
    required int isGrosir,
    required List<String> productIds,
    required List<String> quantities,
    required List<String> prices,
    required String paymentMethod,
    String? dibayar,
    String? kembali,
  }) async {
    try {
      final formData = FormData.fromMap({
        'user_id': userId,
        'br_id': brId,
        'is_grosir': isGrosir,
        'p_id[]': productIds,
        'qty[]': quantities,
        'price[]': prices,
        'payment_method': paymentMethod,
        if (dibayar != null) 'dibayar': dibayar,
        if (kembali != null) 'kembali': kembali,
      });

      final response = await _dio.post(
        '/api/sale/do_trx',
        data: formData,
      );

      if (response.data['status'] == true) {
        final saleResponse =
            SaleResponseModel.fromJson(response.data);
        return HttpResponseModel(
          statusCode: response.statusCode,
          data: saleResponse,
          message: response.data['msg'],
        );
      } else {
        return HttpResponseModel(
          statusCode: response.statusCode,
          message: response.data['msg'] ?? 'Failed to create sale',
        );
      }
    } on DioException catch (e) {
      LoggerUtil.error('Create sale error', e);
      return HttpResponseModel(
        statusCode: e.response?.statusCode ?? 500,
        message: e.message ?? 'Connection error',
      );
    } catch (e) {
      LoggerUtil.error('Create sale unknown error', e);
      return HttpResponseModel(
        statusCode: 500,
        message: e.toString(),
      );
    }
  }

  Future<HttpResponseModel<List<SaleModel>>> getSalesHistory({
    String searchValue = '',
    int start = 0,
    int length = 10,
  }) async {
    try {
      final response = await _dio.post(
        '/api/sale/history',
        data: FormData.fromMap({
          'searchValue': searchValue,
          'start': start,
          'length': length,
        }),
      );

      if (response.data['status'] == true) {
        final List<dynamic> result = response.data['result'] ?? [];
        final sales = result.map((e) => SaleModel.fromJson(e)).toList();
        return HttpResponseModel(
          statusCode: response.statusCode,
          data: sales,
          message: response.data['msg'],
        );
      } else {
        return HttpResponseModel(
          statusCode: response.statusCode,
          message: response.data['msg'] ?? 'Failed to load sales history',
        );
      }
    } on DioException catch (e) {
      LoggerUtil.error('Get sales history error', e);
      return HttpResponseModel(
        statusCode: e.response?.statusCode ?? 500,
        message: e.message ?? 'Connection error',
      );
    } catch (e) {
      LoggerUtil.error('Get sales history unknown error', e);
      return HttpResponseModel(
        statusCode: 500,
        message: e.toString(),
      );
    }
  }
}