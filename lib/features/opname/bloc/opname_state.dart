import 'package:equatable/equatable.dart';
import 'package:syathiby/features/home/service/rack_model.dart';

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
  final List<RackModel> racks;
  final String? selectedRaId;

  const OpnameInProgress({
    this.items = const [],
    this.racks = const [],
    this.selectedRaId,
  });

  OpnameInProgress copyWith({
    List<OpnameItemModel>? items,
    List<RackModel>? racks,
    String? selectedRaId,
  }) {
    return OpnameInProgress(
      items: items ?? this.items,
      racks: racks ?? this.racks,
      selectedRaId: selectedRaId ?? this.selectedRaId,
    );
  }

  @override
  List<Object?> get props => [items, racks, selectedRaId];
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
  final String? raId;
  final String? raName;

  const OpnameItemModel({
    required this.productId,
    required this.productCode,
    required this.productName,
    required this.systemStock,
    this.actualStock = '',
    this.raId,
    this.raName,
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
    String? raId,
    String? raName,
  }) {
    return OpnameItemModel(
      productId: productId ?? this.productId,
      productCode: productCode ?? this.productCode,
      productName: productName ?? this.productName,
      systemStock: systemStock ?? this.systemStock,
      actualStock: actualStock ?? this.actualStock,
      raId: raId ?? this.raId,
      raName: raName ?? this.raName,
    );
  }

  @override
  List<Object?> get props =>
      [productId, productCode, productName, systemStock, actualStock, raId, raName];
}