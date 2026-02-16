import 'package:dio/dio.dart';
import 'package:syathiby/core/models/http_response_model.dart';
import 'package:syathiby/core/utils/logger_util.dart';
import 'package:syathiby/features/product/models/category_model.dart';
import 'package:syathiby/features/product/models/product_model.dart';
import 'package:syathiby/features/product/models/unit_model.dart';

class ProductService {
  final Dio _dio;

  ProductService(this._dio);

  Future<HttpResponseModel<List<ProductModel>>> getProducts({
    required String token,
    String searchValue = '',
    int start = 0,
    int length = 10,
  }) async {
    try {
      final response = await _dio.post(
        '/api/product/data',
        data: FormData.fromMap({
          'token': token,
          'searchValue': searchValue,
        }),
      );

      if (response.data['status'] == true) {
        final List<dynamic> result = response.data['result'];
        final products = result.map((e) => ProductModel.fromJson(e)).toList();

        return HttpResponseModel(
          statusCode: response.statusCode,
          data: products,
          message: response.data['msg'],
        );
      } else {
        return HttpResponseModel(
          statusCode: response.statusCode,
          message: response.data['msg'] ?? 'Failed to load products',
        );
      }
    } on DioException catch (e) {
      LoggerUtil.error('Get products error', e);
      return HttpResponseModel(
        statusCode: e.response?.statusCode ?? 500,
        message: e.message ?? 'Connection error',
      );
    } catch (e) {
      LoggerUtil.error('Get products unknown error', e);
      return HttpResponseModel(
        statusCode: 500,
        message: e.toString(),
      );
    }
  }

  Future<HttpResponseModel<List<CategoryModel>>> getCategories({
    required String token,
    String searchValue = '',
  }) async {
    try {
      final response = await _dio.post(
        '/api/category/data',
        data: FormData.fromMap({
          'token': token,
          'searchValue': searchValue,
        }),
      );

      if (response.data['status'] == true) {
        final List<dynamic> result = response.data['result'];
        final categories = result.map((e) => CategoryModel.fromJson(e)).toList();

        return HttpResponseModel(
          statusCode: response.statusCode,
          data: categories,
          message: response.data['msg'],
        );
      } else {
        return HttpResponseModel(
          statusCode: response.statusCode,
          message: response.data['msg'] ?? 'Failed to load categories',
        );
      }
    } on DioException catch (e) {
      LoggerUtil.error('Get categories error', e);
      return HttpResponseModel(
        statusCode: e.response?.statusCode ?? 500,
        message: e.message ?? 'Connection error',
      );
    } catch (e) {
      LoggerUtil.error('Get categories unknown error', e);
      return HttpResponseModel(
        statusCode: 500,
        message: e.toString(),
      );
    }
  }

  Future<HttpResponseModel<List<UnitModel>>> getUnits({
    required String token,
    String searchValue = '',
  }) async {
    try {
      final response = await _dio.post(
        '/api/unit/data',
        data: FormData.fromMap({
          'token': token,
          'searchValue': searchValue,
        }),
      );

      if (response.data['status'] == true) {
        final List<dynamic> result = response.data['result'];
        final units = result.map((e) => UnitModel.fromJson(e)).toList();

        return HttpResponseModel(
          statusCode: response.statusCode,
          data: units,
          message: response.data['msg'],
        );
      } else {
        return HttpResponseModel(
          statusCode: response.statusCode,
          message: response.data['msg'] ?? 'Failed to load units',
        );
      }
    } on DioException catch (e) {
      LoggerUtil.error('Get units error', e);
      return HttpResponseModel(
        statusCode: e.response?.statusCode ?? 500,
        message: e.message ?? 'Connection error',
      );
    } catch (e) {
      LoggerUtil.error('Get units unknown error', e);
      return HttpResponseModel(
        statusCode: 500,
        message: e.toString(),
      );
    }
  }
}
