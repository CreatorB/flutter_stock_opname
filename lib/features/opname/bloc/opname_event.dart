import 'package:equatable/equatable.dart';

abstract class OpnameEvent extends Equatable {
  const OpnameEvent();

  @override
  List<Object?> get props => [];
}

class GetOpnameProductsEvent extends OpnameEvent {
  final String searchValue;
  final String? raId;

  const GetOpnameProductsEvent({this.searchValue = '', this.raId});

  @override
  List<Object?> get props => [searchValue, raId];
}

class UpdateActualStockEvent extends OpnameEvent {
  final String productId;
  final String actualStock;

  const UpdateActualStockEvent({
    required this.productId,
    required this.actualStock,
  });

  @override
  List<Object?> get props => [productId, actualStock];
}

class ScanBarcodeEvent extends OpnameEvent {
  final String productId;
  final String productCode;
  final String productName;
  final String qty;

  const ScanBarcodeEvent({
    required this.productId,
    this.productCode = '',
    this.productName = '',
    required this.qty,
  });

  @override
  List<Object?> get props => [productId, productCode, productName, qty];
}

class LoadRacksEvent extends OpnameEvent {
  const LoadRacksEvent();
}

class ChangeRackEvent extends OpnameEvent {
  final String raId;

  const ChangeRackEvent(this.raId);

  @override
  List<Object?> get props => [raId];
}

class ScanFromGalleryEvent extends OpnameEvent {
  final String imagePath;

  const ScanFromGalleryEvent({required this.imagePath});

  @override
  List<Object?> get props => [imagePath];
}

class UndoScanEvent extends OpnameEvent {
  final String productId;

  const UndoScanEvent({required this.productId});

  @override
  List<Object?> get props => [productId];
}

class SelectRackEvent extends OpnameEvent {
  final String raId;

  const SelectRackEvent(this.raId);

  @override
  List<Object?> get props => [raId];
}

class SubmitOpnameEvent extends OpnameEvent {
  const SubmitOpnameEvent();
}

class ResetOpnameEvent extends OpnameEvent {
  const ResetOpnameEvent();
}