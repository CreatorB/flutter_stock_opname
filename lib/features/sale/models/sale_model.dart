class SaleModel {
  final String? id;
  final String? saleCode;
  final String? totalAmount;
  final String? discount;
  final String? finalAmount;
  final String? paymentMethod;
  final String? cashReceived;
  final String? change;
  final String? mdr;
  final String? createdAt;
  final List<Map<String, dynamic>>? items;

  SaleModel({
    this.id,
    this.saleCode,
    this.totalAmount,
    this.discount,
    this.finalAmount,
    this.paymentMethod,
    this.cashReceived,
    this.change,
    this.mdr,
    this.createdAt,
    this.items,
  });

  factory SaleModel.fromJson(Map<String, dynamic> json) {
    return SaleModel(
      id: json['id']?.toString(),
      saleCode: json['sale_code'],
      totalAmount: json['total_amount']?.toString(),
      discount: json['discount']?.toString(),
      finalAmount: json['final_amount']?.toString(),
      paymentMethod: json['payment_method'],
      cashReceived: json['cash_received']?.toString(),
      change: json['change']?.toString(),
      mdr: json['mdr']?.toString(),
      createdAt: json['created_at'],
      items: json['items'] != null
          ? List<Map<String, dynamic>>.from(json['items'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sale_code': saleCode,
      'total_amount': totalAmount,
      'discount': discount,
      'final_amount': finalAmount,
      'payment_method': paymentMethod,
      'cash_received': cashReceived,
      'change': change,
      'mdr': mdr,
      'created_at': createdAt,
      'items': items,
    };
  }
}

class SaleResponseModel {
  final bool status;
  final String? message;
  final SaleModel? data;
  final String? saleId;
  final String? saleCode;

  SaleResponseModel({
    this.status = false,
    this.message,
    this.data,
    this.saleId,
    this.saleCode,
  });

  factory SaleResponseModel.fromJson(Map<String, dynamic> json) {
    return SaleResponseModel(
      status: json['status'] ?? false,
      message: json['msg'],
      data: json['data'] != null ? SaleModel.fromJson(json['data']) : null,
      saleId: json['sale_id']?.toString(),
      saleCode: json['sale_code'],
    );
  }
}