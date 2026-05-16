enum PriceMode { retail, grosir }

enum PriceArea { area1, area2, area3 }

class CartItemModel {
  final String productId;
  final String productCode;
  final String productName;
  final PriceMode priceMode;
  final PriceArea? selectedPriceArea;
  final String? manualPrice;
  final String? priceArea1;
  final String? priceArea2;
  final String? priceArea3;
  final String? buyPrice;
  int quantity;

  CartItemModel({
    required this.productId,
    required this.productCode,
    required this.productName,
    this.priceMode = PriceMode.retail,
    this.selectedPriceArea = PriceArea.area1,
    this.manualPrice,
    this.priceArea1,
    this.priceArea2,
    this.priceArea3,
    this.buyPrice,
    this.quantity = 1,
  });

  String get selectedPrice {
    if (priceMode == PriceMode.retail) {
      switch (selectedPriceArea) {
        case PriceArea.area1:
          return priceArea1 ?? '0';
        case PriceArea.area2:
          return priceArea2 ?? '0';
        case PriceArea.area3:
          return priceArea3 ?? '0';
        default:
          return priceArea1 ?? '0';
      }
    } else {
      return manualPrice ?? '0';
    }
  }

  double get selectedPriceDouble => double.tryParse(selectedPrice) ?? 0;
  double get buyPriceDouble => double.tryParse(buyPrice ?? '0') ?? 0;
  double get subtotal => selectedPriceDouble * quantity;

  bool isValidGrosirPrice() {
    if (priceMode != PriceMode.grosir) return true;
    return selectedPriceDouble >= buyPriceDouble;
  }

  CartItemModel copyWith({
    String? productId,
    String? productCode,
    String? productName,
    PriceMode? priceMode,
    PriceArea? selectedPriceArea,
    String? manualPrice,
    String? priceArea1,
    String? priceArea2,
    String? priceArea3,
    String? buyPrice,
    int? quantity,
  }) {
    return CartItemModel(
      productId: productId ?? this.productId,
      productCode: productCode ?? this.productCode,
      productName: productName ?? this.productName,
      priceMode: priceMode ?? this.priceMode,
      selectedPriceArea: selectedPriceArea ?? this.selectedPriceArea,
      manualPrice: manualPrice ?? this.manualPrice,
      priceArea1: priceArea1 ?? this.priceArea1,
      priceArea2: priceArea2 ?? this.priceArea2,
      priceArea3: priceArea3 ?? this.priceArea3,
      buyPrice: buyPrice ?? this.buyPrice,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_code': productCode,
      'product_name': productName,
      'price_mode': priceMode.name,
      'selected_price_area': selectedPriceArea?.name,
      'manual_price': manualPrice,
      'price_area1': priceArea1,
      'price_area2': priceArea2,
      'price_area3': priceArea3,
      'buy_price': buyPrice,
      'quantity': quantity,
      'selected_price': selectedPrice,
      'subtotal': subtotal,
    };
  }
}