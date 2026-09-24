import 'package:syathiby/features/setoran/models/setoran_model.dart' show parseAmount;

dynamic _pick(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    for (final entry in json.entries) {
      if (entry.key.toLowerCase() == key.toLowerCase() && entry.value != null) {
        return entry.value;
      }
    }
  }
  return null;
}

class LaporanSummaryModel {
  final double total;
  final double count;
  final String periodLabel;

  const LaporanSummaryModel({
    this.total = 0.0,
    this.count = 0.0,
    this.periodLabel = '',
  });

  factory LaporanSummaryModel.fromJson(Map<String, dynamic> json) {
    return LaporanSummaryModel(
      total: parseAmount(_pick(json, [
        'total',
        'total_amount',
        'grand_total',
        'amount',
        'nominal',
        'jumlah',
        'value',
        'nilai',
      ])),
      count: parseAmount(_pick(json, [
        'count',
        'total_trx',
        'total_transaction',
        'trx_count',
        'jumlah_transaksi',
        'qty',
      ])),
      periodLabel: _pick(json, [
        'period',
        'periode',
        'period_label',
        'label',
      ])?.toString() ?? '',
    );
  }

  LaporanSummaryModel withOverrides({double? total, double? count}) {
    return LaporanSummaryModel(
      total: total ?? this.total,
      count: count ?? this.count,
      periodLabel: periodLabel,
    );
  }
}

class PenjualanReportItem {
  final String? trxId;
  final String? trxNumber;
  final String? date;
  final double grandTotal;
  final String? paymentMethod;
  final String? jenis;
  final String? cashierName;
  final double itemCount;

  const PenjualanReportItem({
    this.trxId,
    this.trxNumber,
    this.date,
    this.grandTotal = 0.0,
    this.paymentMethod,
    this.jenis,
    this.cashierName,
    this.itemCount = 0.0,
  });

  factory PenjualanReportItem.fromJson(Map<String, dynamic> json) {
    return PenjualanReportItem(
      trxId: _pick(json, [
        'key_id',
        'trx_id',
        'sale_id',
        'id',
        'transaction_id',
      ])?.toString(),
      trxNumber: _pick(json, [
        'sale_code',
        'trx_number',
        'number',
        'kode',
        'no_trx',
      ])?.toString(),
      date: _pick(json, [
        'tgl',
        'date',
        'tanggal',
        'created_at',
        'trx_date',
      ])?.toString(),
      grandTotal: parseAmount(_pick(json, [
        'total',
        'grand_total',
        'amount',
        'nominal',
        'total_amount',
      ])),
      paymentMethod: _pick(json, [
        'metode',
        'payment_method',
        'method',
        'payment',
      ])?.toString(),
      jenis: _pick(json, ['jenis', 'type'])?.toString(),
      cashierName: _pick(json, ['us_name', 'cashier', 'nama_user'])
          ?.toString(),
      itemCount: parseAmount(_pick(json, [
        't_item',
        'item_count',
        'total_item',
        'qty',
        'jumlah_item',
      ])),
    );
  }
}

class PenjualanReportModel {
  final LaporanSummaryModel summary;
  final List<PenjualanReportItem> items;

  const PenjualanReportModel({
    this.summary = const LaporanSummaryModel(),
    this.items = const [],
  });

  factory PenjualanReportModel.fromResponse(dynamic body) {
    if (body is! Map) {
      return const PenjualanReportModel();
    }

    final map = Map<String, dynamic>.from(body);
    final dynamic result = map['result'];
    final dynamic summaryRaw = map['summary'];
    final dynamic itemsRaw = map['items'] ?? map['data'] ?? result;

    final List<PenjualanReportItem> items = itemsRaw is List
        ? itemsRaw
            .whereType<Map>()
            .map((e) =>
                PenjualanReportItem.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : <PenjualanReportItem>[];

    final computedTotal = items.fold<double>(0, (s, i) => s + i.grandTotal);
    final computedCount = items.fold<double>(0, (s, i) => s + i.itemCount);

    final LaporanSummaryModel summary = summaryRaw is Map
        ? LaporanSummaryModel.fromJson(Map<String, dynamic>.from(summaryRaw))
            .withOverrides(total: computedTotal, count: computedCount)
        : LaporanSummaryModel(total: computedTotal, count: computedCount);

    return PenjualanReportModel(summary: summary, items: items);
  }
}

class OpnameReportItem {
  final String? opnameId;
  final String? opnameCode;
  final String? productCode;
  final String? productName;
  final String? raCode;
  final String? opDate;
  final String? createdAt;
  final double qtySystem;
  final double qtyOpname;
  final double buyPrice;

  const OpnameReportItem({
    this.opnameId,
    this.opnameCode,
    this.productCode,
    this.productName,
    this.raCode,
    this.opDate,
    this.createdAt,
    this.qtySystem = 0.0,
    this.qtyOpname = 0.0,
    this.buyPrice = 0.0,
  });

  double get selisih => qtyOpname - qtySystem;

  factory OpnameReportItem.fromJson(Map<String, dynamic> json) {
    return OpnameReportItem(
      opnameId: _pick(json, [
        'p_id',
        'opname_id',
        'id',
        'stock_opname_id',
      ])?.toString(),
      opnameCode: _pick(json, ['op_code', 'kode', 'opname_code'])?.toString(),
      productCode: _pick(json, ['p_code', 'product_code', 'kode_produk'])
          ?.toString(),
      productName: _pick(json, ['p_name', 'product_name', 'nama_produk'])
          ?.toString(),
      raCode: _pick(json, ['ra_code', 'ra_name', 'rack', 'rak', 'nama_rak'])
          ?.toString(),
      opDate: _pick(json, [
        'op_date',
        'tanggal',
        'date',
      ])?.toString(),
      createdAt: _pick(json, ['created_at', 'waktu'])?.toString(),
      qtySystem: parseAmount(_pick(json, [
        'qty_system',
        'qty_system_',
        'stock_system',
      ])),
      qtyOpname: parseAmount(_pick(json, [
        'qty_opname',
        'qty_opname_',
        'stock_actual',
        'qty_actual',
      ])),
      buyPrice: parseAmount(_pick(json, [
        'buy_price',
        'harga_beli',
        'price_buy',
      ])),
    );
  }
}

class OpnameReportModel {
  final LaporanSummaryModel summary;
  final List<OpnameReportItem> items;

  const OpnameReportModel({
    this.summary = const LaporanSummaryModel(),
    this.items = const [],
  });

  factory OpnameReportModel.fromResponse(dynamic body) {
    if (body is! Map) {
      return const OpnameReportModel();
    }

    final map = Map<String, dynamic>.from(body);
    final dynamic result = map['result'];
    final dynamic summaryRaw = map['summary'];
    final dynamic itemsRaw = map['items'] ?? map['data'] ?? result;

    final List<OpnameReportItem> items = itemsRaw is List
        ? itemsRaw
            .whereType<Map>()
            .map((e) =>
                OpnameReportItem.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : <OpnameReportItem>[];

    final totalQty = items.fold<double>(0, (s, i) => s + i.qtyOpname);

    final LaporanSummaryModel summary = summaryRaw is Map
        ? LaporanSummaryModel.fromJson(Map<String, dynamic>.from(summaryRaw))
            .withOverrides(total: totalQty, count: items.length.toDouble())
        : LaporanSummaryModel(total: totalQty, count: items.length.toDouble());

    return OpnameReportModel(summary: summary, items: items);
  }
}

class SetoranReportItem {
  final String? deId;
  final String? regCode;
  final String? transactionDate;
  final String? date;
  final String? shift;
  final String? cashierName;
  final String? description;
  final double tunaiAmount;
  final double edcAmount;
  final double tunaiedcAmount;
  final double amount;
  final String? statusPaid;

  const SetoranReportItem({
    this.deId,
    this.regCode,
    this.transactionDate,
    this.date,
    this.shift,
    this.cashierName,
    this.description,
    this.tunaiAmount = 0.0,
    this.edcAmount = 0.0,
    this.tunaiedcAmount = 0.0,
    this.amount = 0.0,
    this.statusPaid,
  });

  double get total => tunaiAmount + edcAmount + tunaiedcAmount;

  factory SetoranReportItem.fromJson(Map<String, dynamic> json) {
    return SetoranReportItem(
      deId: _pick(json, ['id', 'de_id', 'setoran_id'])?.toString(),
      regCode: _pick(json, ['reg_code', 'kode', 'setoran_code'])?.toString(),
      transactionDate: _pick(json, [
        'transaction_date',
        'date',
        'tanggal',
      ])?.toString(),
      date: _pick(json, [
        'tgl',
        'created_at',
        'waktu',
      ])?.toString(),
      shift: _pick(json, ['shift'])?.toString(),
      cashierName: _pick(json, ['us_name', 'cashier', 'nama_user'])
          ?.toString(),
      description: _pick(json, ['description', 'keterangan', 'catatan'])
          ?.toString(),
      tunaiAmount: parseAmount(_pick(json, [
        'tunai_amount',
        'tunai',
        'cash',
      ])),
      edcAmount: parseAmount(_pick(json, [
        'edc_amount',
        'edc',
      ])),
      tunaiedcAmount: parseAmount(_pick(json, [
        'tunaiedc_amount',
        'tunaiedc',
        'tunai_edc',
      ])),
      amount: parseAmount(_pick(json, [
        'amount',
        'jumlah',
        'setor',
        'total_setoran',
      ])),
      statusPaid: _pick(json, ['status_paid', 'status'])?.toString(),
    );
  }
}

class SetoranReportModel {
  final LaporanSummaryModel summary;
  final List<SetoranReportItem> items;

  const SetoranReportModel({
    this.summary = const LaporanSummaryModel(),
    this.items = const [],
  });

  factory SetoranReportModel.fromResponse(dynamic body) {
    if (body is! Map) {
      return const SetoranReportModel();
    }

    final map = Map<String, dynamic>.from(body);
    final dynamic result = map['result'];
    final dynamic summaryRaw = map['summary'];
    final dynamic itemsRaw = map['items'] ?? map['data'] ?? result;

    final List<SetoranReportItem> items = itemsRaw is List
        ? itemsRaw
            .whereType<Map>()
            .map((e) =>
                SetoranReportItem.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : <SetoranReportItem>[];

    final totalAmount = items.fold<double>(0, (s, i) => s + i.amount);

    final LaporanSummaryModel summary = summaryRaw is Map
        ? LaporanSummaryModel.fromJson(Map<String, dynamic>.from(summaryRaw))
            .withOverrides(total: totalAmount, count: items.length.toDouble())
        : LaporanSummaryModel(total: totalAmount, count: items.length.toDouble());

    return SetoranReportModel(summary: summary, items: items);
  }
}