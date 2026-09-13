/// Angka dari API bisa datang sebagai num, "100000", "100.000", "Rp 100.000",
/// atau "100.000,50". Semua dinormalkan lewat [parseAmount].
double parseAmount(dynamic value) {
  if (value == null) return 0.0;
  if (value is num) return value.toDouble();

  var s = value.toString().trim();
  if (s.isEmpty) return 0.0;

  s = s.replaceAll(RegExp(r'[^0-9,.\-]'), '');
  if (s.isEmpty || s == '-') return 0.0;

  final hasDot = s.contains('.');
  final hasComma = s.contains(',');

  if (hasDot && hasComma) {
    // Format ID: 1.000.000,50
    s = s.replaceAll('.', '').replaceAll(',', '.');
  } else if (hasComma) {
    final parts = s.split(',');
    s = (parts.length == 2 && parts.last.length <= 2)
        ? parts.join('.')
        : s.replaceAll(',', '');
  } else if (hasDot) {
    final parts = s.split('.');
    // "100.000" = pemisah ribuan, "100.5" = desimal
    final isThousandSep =
        parts.length > 2 || (parts.length == 2 && parts.last.length == 3);
    if (isThousandSep) s = s.replaceAll('.', '');
  }

  return double.tryParse(s) ?? 0.0;
}

/// Ambil nilai pertama yang tidak null dari beberapa kemungkinan nama key.
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

String _plain(double value) => value.toStringAsFixed(0);

class SetoranCheckModel {
  final String? deId;
  final String? statusPaid;
  final String? tunaiAmount;
  final String? edcAmount;
  final String? tunaiedcAmount;
  final String? amount;
  final String? createdAt;

  const SetoranCheckModel({
    this.deId,
    this.statusPaid,
    this.tunaiAmount,
    this.edcAmount,
    this.tunaiedcAmount,
    this.amount,
    this.createdAt,
  });

  bool get isPaid =>
      statusPaid != null &&
      (statusPaid == '1' ||
          statusPaid.toString().toLowerCase() == 'true' ||
          statusPaid.toString().toLowerCase() == 'paid');

  double get tunaiAmountDouble => parseAmount(tunaiAmount);
  double get edcAmountDouble => parseAmount(edcAmount);
  double get tunaiedcAmountDouble => parseAmount(tunaiedcAmount);
  double get amountDouble => parseAmount(amount);

  factory SetoranCheckModel.fromJson(Map<String, dynamic> json) {
    return SetoranCheckModel(
      deId: _pick(json, ['de_id', 'deId', 'id'])?.toString(),
      statusPaid: _pick(json, ['status_paid', 'statusPaid', 'status'])?.toString(),
      tunaiAmount: _pick(json, ['tunai_amount', 'tunai'])?.toString(),
      edcAmount: _pick(json, ['edc_amount', 'edc'])?.toString(),
      tunaiedcAmount:
          _pick(json, ['tunaiedc_amount', 'tunaiedc', 'tunai_edc_amount'])
              ?.toString(),
      amount: _pick(json, ['amount', 'jumlah', 'setor'])?.toString(),
      createdAt: _pick(json, ['created_at', 'date', 'tanggal'])?.toString(),
    );
  }
}

class SetoranTrxSummaryModel {
  final String? tunai;
  final String? edc;
  final String? tunaiedc;

  const SetoranTrxSummaryModel({
    this.tunai,
    this.edc,
    this.tunaiedc,
  });

  double get tunaiDouble => parseAmount(tunai);
  double get edcDouble => parseAmount(edc);
  double get tunaiedcDouble => parseAmount(tunaiedc);

  double get total => tunaiDouble + edcDouble + tunaiedcDouble;

  bool get isEmpty => tunaiDouble == 0 && edcDouble == 0 && tunaiedcDouble == 0;

  /// Nilai siap kirim ke API (tanpa pemisah ribuan).
  String get tunaiPlain => _plain(tunaiDouble);
  String get edcPlain => _plain(edcDouble);
  String get tunaiedcPlain => _plain(tunaiedcDouble);

  factory SetoranTrxSummaryModel.fromJson(Map<String, dynamic> json) {
    return SetoranTrxSummaryModel(
      tunai: _pick(json, ['tunai', 'tunai_amount', 'cash'])?.toString(),
      edc: _pick(json, ['edc', 'edc_amount'])?.toString(),
      tunaiedc:
          _pick(json, ['tunaiedc', 'tunaiedc_amount', 'tunai_edc'])?.toString(),
    );
  }

  /// `result` dari get_trx_2d bisa berupa object {tunai, edc, tunaiedc}
  /// atau list baris per metode bayar, mis.
  /// [{"payment_method":"tunai","total":"150000"}, ...].
  factory SetoranTrxSummaryModel.fromResult(dynamic result) {
    if (result is Map) {
      final map = Map<String, dynamic>.from(result);
      final direct = SetoranTrxSummaryModel.fromJson(map);
      if (!direct.isEmpty) return direct;

      // Object yang isinya justru list baris, mis. {"result":[...]}
      for (final value in map.values) {
        if (value is List && value.isNotEmpty) {
          final nested = SetoranTrxSummaryModel.fromResult(value);
          if (!nested.isEmpty) return nested;
        }
      }
      return direct;
    }

    if (result is List) {
      double tunai = 0, edc = 0, tunaiedc = 0;

      for (final row in result) {
        if (row is! Map) continue;
        final map = Map<String, dynamic>.from(row);

        // Baris bisa sudah berbentuk object ringkasan
        final asSummary = SetoranTrxSummaryModel.fromJson(map);
        if (!asSummary.isEmpty) {
          tunai += asSummary.tunaiDouble;
          edc += asSummary.edcDouble;
          tunaiedc += asSummary.tunaiedcDouble;
          continue;
        }

        final method = _pick(map, [
          'payment_list',
          'payment_method',
          'paymentMethod',
          'metode',
          'jenis',
          'method',
          'type',
        ])?.toString().toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');

        final value = parseAmount(_pick(map, [
          'total',
          'amount',
          'jumlah',
          'nominal',
          'grand_total',
          'total_amount',
          'nilai',
        ]));

        if (method == null || value == 0) continue;

        if (method.contains('tunai') && method.contains('edc')) {
          tunaiedc += value;
        } else if (method.contains('edc') || method.contains('debit') ||
            method.contains('kartu')) {
          edc += value;
        } else if (method.contains('tunai') || method.contains('cash')) {
          tunai += value;
        }
      }

      return SetoranTrxSummaryModel(
        tunai: _plain(tunai),
        edc: _plain(edc),
        tunaiedc: _plain(tunaiedc),
      );
    }

    return const SetoranTrxSummaryModel();
  }
}

class SetoranSaveResponseModel {
  final String? deId;
  final String? msg;
  final bool status;

  const SetoranSaveResponseModel({
    this.deId,
    this.msg,
    this.status = false,
  });

  factory SetoranSaveResponseModel.fromJson(Map<String, dynamic> json) {
    return SetoranSaveResponseModel(
      deId: json['de_id']?.toString(),
      msg: json['msg']?.toString(),
      status: json['status'] == true,
    );
  }
}
