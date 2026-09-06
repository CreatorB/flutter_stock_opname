class PriceListItem {
  final String? pId;
  final String? price;
  final String? qty;
  final String? minQty;
  final String? name;
  final String? isGrosir;

  PriceListItem({
    this.pId,
    this.price,
    this.qty,
    this.minQty,
    this.name,
    this.isGrosir,
  });

  double get priceDouble => double.tryParse(price ?? '0') ?? 0;
  int get qtyInt => int.tryParse(qty ?? '0') ?? 0;
  int get minQtyInt => int.tryParse(minQty ?? '0') ?? 0;

  factory PriceListItem.fromJson(Map<String, dynamic> json) {
    final dynamic rawPrice =
        json['price'] ?? json['price_value'] ?? json['id'] ?? json['text'];
    return PriceListItem(
      pId: json['p_id']?.toString() ?? json['pId']?.toString(),
      price: rawPrice?.toString(),
      qty: json['qty']?.toString() ??
          json['quantity']?.toString() ??
          json['min_qty']?.toString(),
      minQty: json['min_qty']?.toString(),
      name: json['name']?.toString() ?? json['price_name']?.toString(),
      isGrosir: json['is_grosir']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'p_id': pId,
      'price': price,
      'qty': qty,
      'min_qty': minQty,
      'name': name,
      'is_grosir': isGrosir,
    };
  }
}

class PriceListModel {
  final String? pId;
  final List<PriceListItem> items;

  PriceListModel({this.pId, this.items = const []});

  factory PriceListModel.fromJson(Map<String, dynamic> json) {
    dynamic raw = json['result'] ?? json['data'] ?? json;

    if (raw is Map<String, dynamic>) {
      final inner = raw['result'] ?? raw['data'];
      if (inner is List) raw = inner;
    }

    final String? pid = (raw is Map ? raw['p_id']?.toString() : null);

    if (raw is List) {
      return PriceListModel(
        pId: pid,
        items: raw
            .whereType<Map>()
            .map((e) => PriceListItem.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );
    }

    if (raw is Map) {
      final map = Map<String, dynamic>.from(raw);
      final candidates = <dynamic>[
        map['items'],
        map['prices'],
        map['price_list'],
        map['data'],
        map['pricelist'],
      ];
      for (final c in candidates) {
        if (c is List) {
          return PriceListModel(
            pId: pid,
            items: c
                .whereType<Map>()
                .map((e) => PriceListItem.fromJson(Map<String, dynamic>.from(e)))
                .toList(),
          );
        }
      }

      final prices = <PriceListItem>[];
      for (final key in [
        'price_area1',
        'price_area2',
        'price_area3',
        'price1',
        'price2',
        'price3',
        'price_1',
        'price_2',
        'price_3',
        'harga1',
        'harga2',
        'harga3',
      ]) {
        final v = map[key];
        if (v != null) {
          prices.add(PriceListItem(
            pId: pid,
            price: v.toString(),
            name: key,
          ));
        }
      }
      return PriceListModel(pId: pid, items: prices);
    }

    return PriceListModel(pId: pid, items: const []);
  }

  List<PriceListItem> get retailDisplay => items;
  List<PriceListItem> get grosirDisplay => items;
}
