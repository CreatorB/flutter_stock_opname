import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syathiby/core/utils/logger_util.dart';
import 'package:syathiby/features/product/bloc/product_event.dart';
import 'package:syathiby/features/product/bloc/product_state.dart';
import 'package:syathiby/features/product/service/product_service.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductService productService;

  ProductBloc({required this.productService}) : super(const ProductInitial()) {
    on<GetProductsEvent>(_onGetProducts);
    on<GetCategoriesEvent>(_onGetCategories);
    on<GetUnitsEvent>(_onGetUnits);
  }

  Future<void> _onGetProducts(
      GetProductsEvent event, Emitter<ProductState> emit) async {
    emit(const ProductLoading());

    try {
      final response = await productService.getProducts(
        searchValue: event.searchValue,
        pStart: event.start,
        pLength: event.length,
      );

      if (response.statusCode == 200 && response.data != null) {
        emit(ProductLoaded(products: response.data!));
      } else {
        emit(ProductError(
          message: response.message ?? 'Failed to load products',
          statusCode: response.statusCode,
        ));
      }
    } catch (e, stack) {
      LoggerUtil.error('Error fetching products', e, stack);
      emit(ProductError(message: 'Error: ${e.toString()}'));
    }
  }

  Future<void> _onGetCategories(
      GetCategoriesEvent event, Emitter<ProductState> emit) async {
      // Logic for categories if needed separately
  }

  Future<void> _onGetUnits(
      GetUnitsEvent event, Emitter<ProductState> emit) async {
      // Logic for units if needed separately
  }
}
