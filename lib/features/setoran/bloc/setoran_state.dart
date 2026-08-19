import 'package:equatable/equatable.dart';
import 'package:syathiby/features/setoran/models/setoran_model.dart';

abstract class SetoranState extends Equatable {
  const SetoranState();

  @override
  List<Object?> get props => [];
}

class SetoranInitial extends SetoranState {
  const SetoranInitial();
}

class SetoranLoading extends SetoranState {
  const SetoranLoading();
}

class SetoranExistingLoaded extends SetoranState {
  final SetoranCheckModel existing;

  const SetoranExistingLoaded(this.existing);

  @override
  List<Object?> get props => [existing];
}

class SetoranReadyForInput extends SetoranState {
  final SetoranTrxSummaryModel summary;
  final String amountInput;

  const SetoranReadyForInput({
    required this.summary,
    this.amountInput = '',
  });

  SetoranReadyForInput copyWith({
    SetoranTrxSummaryModel? summary,
    String? amountInput,
  }) {
    return SetoranReadyForInput(
      summary: summary ?? this.summary,
      amountInput: amountInput ?? this.amountInput,
    );
  }

  double get amountDouble => double.tryParse(amountInput) ?? 0.0;
  double get difference => amountDouble - summary.tunaiDouble;

  @override
  List<Object?> get props => [summary, amountInput];
}

class SetoranSubmitting extends SetoranState {
  const SetoranSubmitting();
}

class SetoranSuccess extends SetoranState {
  final SetoranSaveResponseModel response;

  const SetoranSuccess(this.response);

  @override
  List<Object?> get props => [response];
}

class SetoranError extends SetoranState {
  final String message;

  const SetoranError(this.message);

  @override
  List<Object?> get props => [message];
}
