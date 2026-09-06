import 'package:equatable/equatable.dart';
import 'package:syathiby/features/product/models/price_list_model.dart';

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
  final PriceListModel? retailPriceList;
  final PriceListModel? grosirPriceList;

  const AddToCartEvent({
    required this.productId,
    required this.productCode,
    required this.productName,
    this.priceArea1,
    this.priceArea2,
    this.priceArea3,
    this.buyPrice,
    this.retailPriceList,
    this.grosirPriceList,
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
        retailPriceList,
        grosirPriceList,
      ];
}

class UpdateCartItemEvent extends SaleEvent {
  final String productId;
  final int quantity;
  final String? priceMode;
  final String? selectedPriceArea;
  final int? priceListIndex;
  final String? manualPrice;
  final PriceListModel? retailPriceList;
  final PriceListModel? grosirPriceList;

  const UpdateCartItemEvent({
    required this.productId,
    required this.quantity,
    this.priceMode,
    this.selectedPriceArea,
    this.priceListIndex,
    this.manualPrice,
    this.retailPriceList,
    this.grosirPriceList,
  });

  @override
  List<Object?> get props => [
        productId,
        quantity,
        priceMode,
        selectedPriceArea,
        priceListIndex,
        manualPrice,
        retailPriceList,
        grosirPriceList,
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