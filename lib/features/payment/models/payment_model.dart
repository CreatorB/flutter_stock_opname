class PaymentModel {
  final double totalAmount;
  final String paymentMethod;
  final double? cashReceived;
  final double? change;
  final double? mdr;
  final double? finalAmount;

  PaymentModel({
    required this.totalAmount,
    required this.paymentMethod,
    this.cashReceived,
    this.change,
    this.mdr,
    this.finalAmount,
  });

  factory PaymentModel.cash(double total, double cashReceived) {
    final change = cashReceived - total;
    return PaymentModel(
      totalAmount: total,
      paymentMethod: 'cash',
      cashReceived: cashReceived,
      change: change > 0 ? change : 0,
    );
  }

  factory PaymentModel.edc(double total, {double mdrRate = 0.01}) {
    final mdr = total * mdrRate;
    final finalAmount = total + mdr;
    return PaymentModel(
      totalAmount: total,
      paymentMethod: 'edc',
      mdr: mdr,
      finalAmount: finalAmount,
    );
  }

  double get changeAmount => change ?? 0;
  double get mdrAmount => mdr ?? 0;
  double get finalPaymentAmount => finalAmount ?? totalAmount;

  bool get isValidCashPayment => cashReceived != null && cashReceived! >= totalAmount;
  bool get isValidEdcPayment => paymentMethod == 'edc';
}

class CashPaymentResult {
  final double total;
  final double cashReceived;
  final double change;
  final bool isSuccess;

  CashPaymentResult({
    required this.total,
    required this.cashReceived,
    required this.change,
    required this.isSuccess,
  });
}

class EdcPaymentResult {
  final double total;
  final double mdr;
  final double finalAmount;
  final bool isSuccess;

  EdcPaymentResult({
    required this.total,
    required this.mdr,
    required this.finalAmount,
    required this.isSuccess,
  });
}