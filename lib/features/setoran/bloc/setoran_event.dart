import 'package:equatable/equatable.dart';

abstract class SetoranEvent extends Equatable {
  const SetoranEvent();

  @override
  List<Object?> get props => [];
}

class SetoranCheckDepositEvent extends SetoranEvent {
  const SetoranCheckDepositEvent();
}

class SetoranGetTrxEvent extends SetoranEvent {
  const SetoranGetTrxEvent();
}

class SetoranAmountChangedEvent extends SetoranEvent {
  final String amount;
  const SetoranAmountChangedEvent(this.amount);

  @override
  List<Object?> get props => [amount];
}

class SetoranSaveDepositEvent extends SetoranEvent {
  const SetoranSaveDepositEvent();
}

class SetoranResetEvent extends SetoranEvent {
  const SetoranResetEvent();
}
