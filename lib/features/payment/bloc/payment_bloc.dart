import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syathiby/features/payment/bloc/payment_event.dart';
import 'package:syathiby/features/payment/bloc/payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  PaymentBloc() : super(const PaymentInitial()) {
    on<CalculateCashChangeEvent>(_onCalculateCashChange);
    on<CalculateMdrEvent>(_onCalculateMdr);
    on<SubmitPaymentEvent>(_onSubmitPayment);
    on<ResetPaymentEvent>(_onResetPayment);
  }

  void _onCalculateCashChange(
      CalculateCashChangeEvent event, Emitter<PaymentState> emit) {
    final change = event.cashReceived - event.total;
    emit(PaymentCalculated(
      total: event.total,
      cashReceived: event.cashReceived,
      change: change > 0 ? change : 0,
      paymentMethod: 'cash',
    ));
  }

  void _onCalculateMdr(CalculateMdrEvent event, Emitter<PaymentState> emit) {
    final mdr = event.total * event.mdrRate;
    final finalAmount = event.total + mdr;
    emit(PaymentCalculated(
      total: event.total,
      mdr: mdr,
      finalAmount: finalAmount,
      paymentMethod: 'edc',
    ));
  }

  void _onSubmitPayment(SubmitPaymentEvent event, Emitter<PaymentState> emit) {
    emit(const PaymentSubmitting());

    if (event.paymentMethod == 'cash') {
      if (event.cashReceived == null || event.cashReceived! < event.total) {
        emit(const PaymentError('Jumlah cash tidak cukup'));
        return;
      }
      final change = event.cashReceived! - event.total;
      emit(PaymentSuccess(
        paymentMethod: 'cash',
        total: event.total,
        cashReceived: event.cashReceived,
        change: change,
      ));
    } else if (event.paymentMethod == 'edc') {
      final mdr = event.mdr ?? (event.total * 0.01);
      final finalAmount = event.total + mdr;
      emit(PaymentSuccess(
        paymentMethod: 'edc',
        total: event.total,
        mdr: mdr,
        finalAmount: finalAmount,
      ));
    } else {
      emit(const PaymentError('Metode pembayaran tidak valid'));
    }
  }

  void _onResetPayment(ResetPaymentEvent event, Emitter<PaymentState> emit) {
    emit(const PaymentInitial());
  }
}