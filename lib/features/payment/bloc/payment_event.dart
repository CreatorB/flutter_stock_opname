import 'package:equatable/equatable.dart';

abstract class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object?> get props => [];
}

class CalculateCashChangeEvent extends PaymentEvent {
  final double total;
  final double cashReceived;

  const CalculateCashChangeEvent({
    required this.total,
    required this.cashReceived,
  });

  @override
  List<Object?> get props => [total, cashReceived];
}

class CalculateMdrEvent extends PaymentEvent {
  final double total;
  final double mdrRate;

  const CalculateMdrEvent({
    required this.total,
    this.mdrRate = 0.01,
  });

  @override
  List<Object?> get props => [total, mdrRate];
}

class SubmitPaymentEvent extends PaymentEvent {
  final String paymentMethod;
  final double total;
  final double? cashReceived;
  final double? mdr;

  const SubmitPaymentEvent({
    required this.paymentMethod,
    required this.total,
    this.cashReceived,
    this.mdr,
  });

  @override
  List<Object?> get props => [paymentMethod, total, cashReceived, mdr];
}

class ResetPaymentEvent extends PaymentEvent {
  const ResetPaymentEvent();
}