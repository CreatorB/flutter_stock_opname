import 'package:equatable/equatable.dart';
import 'package:syathiby/features/product/models/category_model.dart';
import 'package:syathiby/features/product/models/product_model.dart';
import 'package:syathiby/features/product/models/unit_model.dart';

abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object> get props => [];
}

class ProductInitial extends ProductState {
  const ProductInitial();
}

class ProductLoading extends ProductState {
  const ProductLoading();
}

class ProductLoaded extends ProductState {
  final List<ProductModel> products;
  final List<CategoryModel> categories;
  final List<UnitModel> units;
  final bool hasReachedMax;

  const ProductLoaded({
    this.products = const [],
    this.categories = const [],
    this.units = const [],
    this.hasReachedMax = false,
  });

  ProductLoaded copyWith({
    List<ProductModel>? products,
    List<CategoryModel>? categories,
    List<UnitModel>? units,
    bool? hasReachedMax,
  }) {
    return ProductLoaded(
      products: products ?? this.products,
      categories: categories ?? this.categories,
      units: units ?? this.units,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object> get props => [products, categories, units, hasReachedMax];
}

class ProductError extends ProductState {
  final String message;
  final int? statusCode;

  const ProductError({required this.message, this.statusCode});

  @override
  List<Object> get props => [message, statusCode ?? 0];
}
