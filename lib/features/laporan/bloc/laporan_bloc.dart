import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syathiby/core/utils/logger_util.dart';
import 'package:syathiby/features/laporan/bloc/laporan_event.dart';
import 'package:syathiby/features/laporan/bloc/laporan_state.dart';
import 'package:syathiby/features/laporan/service/laporan_service.dart';

class LaporanBloc extends Bloc<LaporanEvent, LaporanState> {
  final LaporanService laporanService;

  LaporanBloc({required this.laporanService}) : super(const LaporanState()) {
    on<LaporanTabChangedEvent>(_onTabChanged);
    on<LaporanDateRangeChangedEvent>(_onDateRangeChanged);
    on<LaporanRefreshEvent>(_onRefresh);
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final d = date.toLocal();
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  Future<void> _onTabChanged(
      LaporanTabChangedEvent event, Emitter<LaporanState> emit) async {
    emit(state.copyWith(activeTab: event.tab, clearError: true));
    await _loadActiveTab(emit);
  }

  Future<void> _onDateRangeChanged(
      LaporanDateRangeChangedEvent event, Emitter<LaporanState> emit) async {
    emit(state.copyWith(
      startDate: event.startDate,
      endDate: event.endDate,
      clearStartDate: event.startDate == null,
      clearEndDate: event.endDate == null,
      clearError: true,
    ));
    await _loadActiveTab(emit);
  }

  Future<void> _onRefresh(
      LaporanRefreshEvent event, Emitter<LaporanState> emit) async {
    await _loadActiveTab(emit);
  }

  Future<void> _loadActiveTab(Emitter<LaporanState> emit) async {
    LoggerUtil.debug('BLOC _loadActiveTab: tab=${state.activeTab}');
    switch (state.activeTab) {
      case LaporanTab.penjualan:
        await _loadPenjualan(emit);
        break;
      case LaporanTab.opname:
        await _loadOpname(emit);
        break;
      case LaporanTab.setoran:
        await _loadSetoran(emit);
        break;
    }
    LoggerUtil.debug('BLOC _loadActiveTab: done');
  }

  Future<void> _loadPenjualan(Emitter<LaporanState> emit) async {
    LoggerUtil.debug('BLOC penjualan: enter -> loading=true');
    emit(state.copyWith(penjualanLoading: true, clearError: true));
    try {
      final response = await laporanService.getPenjualanReport(
        startDate: _formatDate(state.startDate),
        endDate: _formatDate(state.endDate),
      );
      LoggerUtil.debug('BLOC penjualan: response status=${response.statusCode} data=${response.data} msg=${response.message}');
      if (response.statusCode == 200 && response.data != null) {
        LoggerUtil.debug('BLOC penjualan: emit success');
        emit(state.copyWith(
          penjualanLoading: false,
          penjualan: response.data,
          clearError: true,
        ));
      } else {
        LoggerUtil.debug('BLOC penjualan: emit error -> ${response.message}');
        emit(state.copyWith(
          penjualanLoading: false,
          errorMessage: response.message ?? 'Gagal memuat laporan penjualan',
        ));
      }
    } catch (e, stack) {
      LoggerUtil.error('Load penjualan report error', e, stack);
      emit(state.copyWith(
        penjualanLoading: false,
        errorMessage: 'Error: ${e.toString()}',
      ));
    }
  }

  Future<void> _loadOpname(Emitter<LaporanState> emit) async {
    emit(state.copyWith(opnameLoading: true, clearError: true));
    try {
      final response = await laporanService.getOpnameReport(
        startDate: _formatDate(state.startDate),
        endDate: _formatDate(state.endDate),
      );
      if (response.statusCode == 200 && response.data != null) {
        emit(state.copyWith(
          opnameLoading: false,
          opname: response.data,
          clearError: true,
        ));
      } else {
        emit(state.copyWith(
          opnameLoading: false,
          errorMessage: response.message ?? 'Gagal memuat laporan opname',
        ));
      }
    } catch (e, stack) {
      LoggerUtil.error('Load opname report error', e, stack);
      emit(state.copyWith(
        opnameLoading: false,
        errorMessage: 'Error: ${e.toString()}',
      ));
    }
  }

  Future<void> _loadSetoran(Emitter<LaporanState> emit) async {
    emit(state.copyWith(setoranLoading: true, clearError: true));
    try {
      final response = await laporanService.getSetoranReport(
        startDate: _formatDate(state.startDate),
        endDate: _formatDate(state.endDate),
      );
      if (response.statusCode == 200 && response.data != null) {
        emit(state.copyWith(
          setoranLoading: false,
          setoran: response.data,
          clearError: true,
        ));
      } else {
        emit(state.copyWith(
          setoranLoading: false,
          errorMessage: response.message ?? 'Gagal memuat laporan setoran',
        ));
      }
    } catch (e, stack) {
      LoggerUtil.error('Load setoran report error', e, stack);
      emit(state.copyWith(
        setoranLoading: false,
        errorMessage: 'Error: ${e.toString()}',
      ));
    }
  }
}