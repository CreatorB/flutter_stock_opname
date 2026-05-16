class ProductModel {
  final String? id;
  final String? pcrId;
  final String? puId;
  final String? pCode;
  final String? pName;
  final String? description;
  final String? photo;
  final String? priceArea1;
  final String? priceArea2;
  final String? priceArea3;
  final String? createdBy;
  final String? createdAt;
  final String? updatedAt;
  final String? prId;
  final String? updatedBy;
  final String? buyPrice;
  final String? minStock;
  final String? maxStock;
  final String? qty1;
  final String? qty2;
  final String? brId;
  final String? isPpn;
  final String? ppnVal;
  final String? stock;
  final String? rgId;
  final String? rtId;
  final String? ppnAmount;
  final String? suId;
  final String? pcrCode;
  final String? pcrName;
  final String? puCode;
  final String? prName;
  final String? prCode;
  final String? brCode;

  ProductModel({
    this.id,
    this.pcrId,
    this.puId,
    this.pCode,
    this.pName,
    this.description,
    this.photo,
    this.priceArea1,
    this.priceArea2,
    this.priceArea3,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.prId,
    this.updatedBy,
    this.buyPrice,
    this.minStock,
    this.maxStock,
    this.qty1,
    this.qty2,
    this.brId,
    this.isPpn,
    this.ppnVal,
    this.stock,
    this.rgId,
    this.rtId,
    this.ppnAmount,
    this.suId,
    this.pcrCode,
    this.pcrName,
    this.puCode,
    this.prName,
    this.prCode,
    this.brCode,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id']?.toString(),
      pcrId: json['pcr_id']?.toString(),
      puId: json['pu_id']?.toString(),
      pCode: json['p_code'],
      pName: json['p_name'],
      description: json['description'],
      photo: json['photo'],
      priceArea1: json['price_area1']?.toString(),
      priceArea2: json['price_area2']?.toString(),
      priceArea3: json['price_area3']?.toString(),
      createdBy: json['created_by']?.toString(),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      prId: json['pr_id']?.toString(),
      updatedBy: json['updated_by']?.toString(),
      buyPrice: json['buy_price']?.toString(),
      minStock: json['min_stock']?.toString(),
      maxStock: json['max_stock']?.toString(),
      qty1: json['qty1']?.toString(),
      qty2: json['qty2']?.toString(),
      brId: json['br_id']?.toString(),
      isPpn: json['is_ppn']?.toString(),
      ppnVal: json['ppn_val']?.toString(),
      stock: json['stock']?.toString(),
      rgId: json['rg_id']?.toString(),
      rtId: json['rt_id']?.toString(),
      ppnAmount: json['ppn_amount']?.toString(),
      suId: json['su_id']?.toString(),
      pcrCode: json['pcr_code'],
      pcrName: json['pcr_name'],
      puCode: json['pu_code'],
      prName: json['pr_name'],
      prCode: json['pr_code'],
      brCode: json['br_code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pcr_id': pcrId,
      'pu_id': puId,
      'p_code': pCode,
      'p_name': pName,
      'description': description,
      'photo': photo,
      'price_area1': priceArea1,
      'price_area2': priceArea2,
      'price_area3': priceArea3,
      'created_by': createdBy,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'pr_id': prId,
      'updated_by': updatedBy,
      'buy_price': buyPrice,
      'min_stock': minStock,
      'max_stock': maxStock,
      'qty1': qty1,
      'qty2': qty2,
      'br_id': brId,
      'is_ppn': isPpn,
      'ppn_val': ppnVal,
      'stock': stock,
      'rg_id': rgId,
      'rt_id': rtId,
      'ppn_amount': ppnAmount,
      'su_id': suId,
      'pcr_code': pcrCode,
      'pcr_name': pcrName,
      'pu_code': puCode,
      'pr_name': prName,
      'pr_code': prCode,
      'br_code': brCode,
    };
  }
}
