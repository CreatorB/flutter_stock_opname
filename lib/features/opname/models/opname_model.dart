class OpnameModel {
  final String? id;
  final String? productId;
  final String? productCode;
  final String? productName;
  final String? systemStock;
  final String? actualStock;
  final String? difference;
  final String? createdAt;

  OpnameModel({
    this.id,
    this.productId,
    this.productCode,
    this.productName,
    this.systemStock,
    this.actualStock,
    this.difference,
    this.createdAt,
  });

  factory OpnameModel.fromJson(Map<String, dynamic> json) {
    return OpnameModel(
      id: json['id']?.toString(),
      productId: json['product_id']?.toString(),
      productCode: json['product_code'],
      productName: json['product_name'],
      systemStock: json['system_stock']?.toString(),
      actualStock: json['actual_stock']?.toString(),
      difference: json['difference']?.toString(),
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'product_code': productCode,
      'product_name': productName,
      'system_stock': systemStock,
      'actual_stock': actualStock,
      'difference': difference,
      'created_at': createdAt,
    };
  }
}

class OpnameResponseModel {
  final bool status;
  final String? message;
  final String? opnameId;
  final String? opnameCode;

  OpnameResponseModel({
    this.status = false,
    this.message,
    this.opnameId,
    this.opnameCode,
  });

  factory OpnameResponseModel.fromJson(Map<String, dynamic> json) {
    return OpnameResponseModel(
      status: json['status'] ?? false,
      message: json['msg'],
      opnameId: json['opname_id']?.toString(),
      opnameCode: json['opname_code'],
    );
  }
}