import 'package:equatable/equatable.dart';

abstract class SaleEvent extends Equatable {
  const SaleEvent();

  @override
  List<Object?> get props => [];
}

class AddToCartEvent extends SaleEvent {
  final String productId;
  final String productCode;
  final String productName;
  final String? priceArea1;
  final String? priceArea2;
  final String? priceArea3;
  final String? buyPrice;

  const AddToCartEvent({
    required this.productId,
    required this.productCode,
    required this.productName,
    this.priceArea1,
    this.priceArea2,
    this.priceArea3,
    this.buyPrice,
  });

  @override
  List<Object?> get props => [
        productId,
        productCode,
        productName,
        priceArea1,
        priceArea2,
        priceArea3,
        buyPrice,
      ];
}

class UpdateCartItemEvent extends SaleEvent {
  final String productId;
  final int quantity;
  final String? priceMode;
  final String? selectedPriceArea;
  final String? manualPrice;

  const UpdateCartItemEvent({
    required this.productId,
    required this.quantity,
    this.priceMode,
    this.selectedPriceArea,
    this.manualPrice,
  });

  @override
  List<Object?> get props => [
        productId,
        quantity,
        priceMode,
        selectedPriceArea,
        manualPrice,
      ];
}

class RemoveFromCartEvent extends SaleEvent {
  final String productId;

  const RemoveFromCartEvent(this.productId);

  @override
  List<Object?> get props => [productId];
}

class ClearCartEvent extends SaleEvent {
  const ClearCartEvent();
}

class SubmitSaleEvent extends SaleEvent {
  final String paymentMethod;
  final String? cashReceived;
  final String? mdr;

  const SubmitSaleEvent({
    required this.paymentMethod,
    this.cashReceived,
    this.mdr,
  });

  @override
  List<Object?> get props => [paymentMethod, cashReceived, mdr];
}

class TogglePriceModeEvent extends SaleEvent {
  final String productId;
  final String priceMode;

  const TogglePriceModeEvent({
    required this.productId,
    required this.priceMode,
  });

  @override
  List<Object?> get props => [productId, priceMode];
}