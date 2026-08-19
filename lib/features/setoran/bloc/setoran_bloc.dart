import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syathiby/core/utils/logger_util.dart';
import 'package:syathiby/features/setoran/bloc/setoran_event.dart';
import 'package:syathiby/features/setoran/bloc/setoran_state.dart';
import 'package:syathiby/features/setoran/service/setoran_service.dart';

class SetoranBloc extends Bloc<SetoranEvent, SetoranState> {
  final SetoranService setoranService;

  SetoranBloc({required this.setoranService}) : super(const SetoranInitial()) {
    on<SetoranCheckDepositEvent>(_onCheckDeposit);
    on<SetoranGetTrxEvent>(_onGetTrx);
    on<SetoranAmountChangedEvent>(_onAmountChanged);
    on<SetoranSaveDepositEvent>(_onSaveDeposit);
    on<SetoranResetEvent>(_onReset);
  }

  Future<void> _onCheckDeposit(
      SetoranCheckDepositEvent event, Emitter<SetoranState> emit) async {
    emit(const SetoranLoading());

    try {
      final response = await setoranService.checkDeposit();

      if (response.statusCode == 200 && response.data != null) {
        emit(SetoranExistingLoaded(response.data!));
      } else if (response.statusCode == 200) {
        add(const SetoranGetTrxEvent());
      } else {
        emit(SetoranError(
          '[${response.statusCode}] ${response.message ?? 'Gagal cek setoran'}',
        ));
      }
    } catch (e, stack) {
      LoggerUtil.error('Setoran check error', e, stack);
      emit(SetoranError('Error: ${e.toString()}'));
    }
  }

  Future<void> _onGetTrx(
      SetoranGetTrxEvent event, Emitter<SetoranState> emit) async {
    if (state is! SetoranInitial && state is! SetoranError) {
      emit(const SetoranLoading());
    } else if (state is SetoranInitial) {
      emit(const SetoranLoading());
    }

    try {
      final response = await setoranService.getTrxSummary();

      if (response.statusCode == 200 && response.data != null) {
        emit(SetoranReadyForInput(summary: response.data!));
      } else {
        emit(SetoranError(
          '[${response.statusCode}] ${response.message ?? 'Gagal memuat ringkasan transaksi'}',
        ));
      }
    } catch (e, stack) {
      LoggerUtil.error('Setoran get trx error', e, stack);
      emit(SetoranError('Error: ${e.toString()}'));
    }
  }

  void _onAmountChanged(
      SetoranAmountChangedEvent event, Emitter<SetoranState> emit) {
    if (state is SetoranReadyForInput) {
      final current = state as SetoranReadyForInput;
      final raw = event.amount.replaceAll(RegExp(r'[^0-9]'), '');
      emit(current.copyWith(amountInput: raw));
    }
  }

  Future<void> _onSaveDeposit(
      SetoranSaveDepositEvent event, Emitter<SetoranState> emit) async {
    if (state is! SetoranReadyForInput) return;
    final current = state as SetoranReadyForInput;

    if (current.amountInput.isEmpty) {
      emit(const SetoranError('Jumlah setoran tunai wajib diisi'));
      emit(current);
      return;
    }

    emit(const SetoranSubmitting());

    try {
      final response = await setoranService.saveDeposit(
        tunaiAmount: current.summary.tunai ?? '0',
        edcAmount: current.summary.edc ?? '0',
        tunaiedcAmount: current.summary.tunaiedc ?? '0',
        amount: current.amountInput,
      );

      if (response.statusCode == 200 && response.data != null) {
        emit(SetoranSuccess(response.data!));
      } else {
        emit(SetoranReadyForInput(
          summary: current.summary,
          amountInput: current.amountInput,
        ));
        emit(SetoranError(
          '[${response.statusCode}] ${response.message ?? 'Gagal menyimpan setoran'}',
        ));
      }
    } catch (e, stack) {
      LoggerUtil.error('Setoran save error', e, stack);
      emit(SetoranReadyForInput(
        summary: current.summary,
        amountInput: current.amountInput,
      ));
      emit(SetoranError('Error: ${e.toString()}'));
    }
  }

  void _onReset(SetoranResetEvent event, Emitter<SetoranState> emit) {
    emit(const SetoranInitial());
  }
}
