import 'package:equatable/equatable.dart';

abstract class PaymentState extends Equatable {
  const PaymentState();

  @override
  List<Object?> get props => [];
}

class PaymentInitial extends PaymentState {
  const PaymentInitial();
}

class PaymentCalculated extends PaymentState {
  final double total;
  final double? cashReceived;
  final double? change;
  final double? mdr;
  final double? finalAmount;
  final String paymentMethod;

  const PaymentCalculated({
    required this.total,
    this.cashReceived,
    this.change,
    this.mdr,
    this.finalAmount,
    required this.paymentMethod,
  });

  @override
  List<Object?> get props => [total, cashReceived, change, mdr, finalAmount, paymentMethod];
}

class PaymentSubmitting extends PaymentState {
  const PaymentSubmitting();
}

class PaymentSuccess extends PaymentState {
  final String paymentMethod;
  final double total;
  final double? cashReceived;
  final double? change;
  final double? mdr;
  final double? finalAmount;

  const PaymentSuccess({
    required this.paymentMethod,
    required this.total,
    this.cashReceived,
    this.change,
    this.mdr,
    this.finalAmount,
  });

  @override
  List<Object?> get props => [paymentMethod, total, cashReceived, change, mdr, finalAmount];
}

class PaymentError extends PaymentState {
  final String message;

  const PaymentError(this.message);

  @override
  List<Object?> get props => [message];
}