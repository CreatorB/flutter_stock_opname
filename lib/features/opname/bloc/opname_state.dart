import 'package:equatable/equatable.dart';

abstract class OpnameState extends Equatable {
  const OpnameState();

  @override
  List<Object?> get props => [];
}

class OpnameInitial extends OpnameState {
  const OpnameInitial();
}

class OpnameLoading extends OpnameState {
  const OpnameLoading();
}

class OpnameInProgress extends OpnameState {
  final List<OpnameItemModel> items;

  const OpnameInProgress({
    this.items = const [],
  });

  OpnameInProgress copyWith({
    List<OpnameItemModel>? items,
  }) {
    return OpnameInProgress(
      items: items ?? this.items,
    );
  }

  @override
  List<Object?> get props => [items];
}

class OpnameSubmitting extends OpnameState {
  const OpnameSubmitting();
}

class OpnameSuccess extends OpnameState {
  final String opnameId;
  final String opnameCode;

  const OpnameSuccess({required this.opnameId, required this.opnameCode});

  @override
  List<Object?> get props => [opnameId, opnameCode];
}

class OpnameError extends OpnameState {
  final String message;

  const OpnameError(this.message);

  @override
  List<Object?> get props => [message];
}

class OpnameItemModel extends Equatable {
  final String productId;
  final String productCode;
  final String productName;
  final String systemStock;
  final String actualStock;

  const OpnameItemModel({
    required this.productId,
    required this.productCode,
    required this.productName,
    required this.systemStock,
    this.actualStock = '',
  });

  int get systemStockInt => int.tryParse(systemStock) ?? 0;
  int get actualStockInt => int.tryParse(actualStock) ?? 0;
  int get difference => actualStockInt - systemStockInt;

  OpnameItemModel copyWith({
    String? productId,
    String? productCode,
    String? productName,
    String? systemStock,
    String? actualStock,
  }) {
    return OpnameItemModel(
      productId: productId ?? this.productId,
      productCode: productCode ?? this.productCode,
      productName: productName ?? this.productName,
      systemStock: systemStock ?? this.systemStock,
      actualStock: actualStock ?? this.actualStock,
    );
  }

  @override
  List<Object?> get props =>
      [productId, productCode, productName, systemStock, actualStock];
}
