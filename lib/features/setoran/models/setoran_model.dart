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

  double get tunaiAmountDouble =>
      double.tryParse(tunaiAmount?.toString() ?? '') ?? 0.0;
  double get edcAmountDouble =>
      double.tryParse(edcAmount?.toString() ?? '') ?? 0.0;
  double get tunaiedcAmountDouble =>
      double.tryParse(tunaiedcAmount?.toString() ?? '') ?? 0.0;
  double get amountDouble =>
      double.tryParse(amount?.toString() ?? '') ?? 0.0;

  factory SetoranCheckModel.fromJson(Map<String, dynamic> json) {
    return SetoranCheckModel(
      deId: json['de_id']?.toString(),
      statusPaid: json['status_paid']?.toString(),
      tunaiAmount: json['tunai_amount']?.toString(),
      edcAmount: json['edc_amount']?.toString(),
      tunaiedcAmount: json['tunaiedc_amount']?.toString(),
      amount: json['amount']?.toString(),
      createdAt: json['created_at']?.toString() ?? json['date']?.toString(),
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

  double get tunaiDouble => double.tryParse(tunai?.toString() ?? '') ?? 0.0;
  double get edcDouble => double.tryParse(edc?.toString() ?? '') ?? 0.0;
  double get tunaiedcDouble =>
      double.tryParse(tunaiedc?.toString() ?? '') ?? 0.0;

  double get total => tunaiDouble + edcDouble + tunaiedcDouble;

  factory SetoranTrxSummaryModel.fromJson(Map<String, dynamic> json) {
    return SetoranTrxSummaryModel(
      tunai: json['tunai']?.toString() ?? json['tunai_amount']?.toString(),
      edc: json['edc']?.toString() ?? json['edc_amount']?.toString(),
      tunaiedc:
          json['tunaiedc']?.toString() ?? json['tunaiedc_amount']?.toString(),
    );
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
