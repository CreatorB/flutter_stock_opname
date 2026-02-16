import 'package:equatable/equatable.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object> get props => [];
}

class GetProductsEvent extends ProductEvent {
  final String searchValue;
  final int start;
  final int length;

  const GetProductsEvent({
    this.searchValue = '',
    this.start = 0,
    this.length = 10,
  });

  @override
  List<Object> get props => [searchValue, start, length];
}

class GetCategoriesEvent extends ProductEvent {
  final String searchValue;

  const GetCategoriesEvent({this.searchValue = ''});

  @override
  List<Object> get props => [searchValue];
}

class GetUnitsEvent extends ProductEvent {
  final String searchValue;

  const GetUnitsEvent({this.searchValue = ''});

  @override
  List<Object> get props => [searchValue];
}
