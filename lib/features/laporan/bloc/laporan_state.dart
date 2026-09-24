import 'package:equatable/equatable.dart';
import 'package:syathiby/features/laporan/bloc/laporan_event.dart';
import 'package:syathiby/features/laporan/models/laporan_model.dart';

class LaporanState extends Equatable {
  final LaporanTab activeTab;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool penjualanLoading;
  final bool opnameLoading;
  final bool setoranLoading;
  final PenjualanReportModel? penjualan;
  final OpnameReportModel? opname;
  final SetoranReportModel? setoran;
  final String? errorMessage;

  const LaporanState({
    this.activeTab = LaporanTab.penjualan,
    this.startDate,
    this.endDate,
    this.penjualanLoading = false,
    this.opnameLoading = false,
    this.setoranLoading = false,
    this.penjualan,
    this.opname,
    this.setoran,
    this.errorMessage,
  });

  bool get isLoading {
    switch (activeTab) {
      case LaporanTab.penjualan:
        return penjualanLoading;
      case LaporanTab.opname:
        return opnameLoading;
      case LaporanTab.setoran:
        return setoranLoading;
    }
  }

  LaporanState copyWith({
    LaporanTab? activeTab,
    DateTime? startDate,
    DateTime? endDate,
    bool clearStartDate = false,
    bool clearEndDate = false,
    bool? penjualanLoading,
    bool? opnameLoading,
    bool? setoranLoading,
    PenjualanReportModel? penjualan,
    OpnameReportModel? opname,
    SetoranReportModel? setoran,
    String? errorMessage,
    bool clearError = false,
  }) {
    return LaporanState(
      activeTab: activeTab ?? this.activeTab,
      startDate: clearStartDate ? null : (startDate ?? this.startDate),
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
      penjualanLoading: penjualanLoading ?? this.penjualanLoading,
      opnameLoading: opnameLoading ?? this.opnameLoading,
      setoranLoading: setoranLoading ?? this.setoranLoading,
      penjualan: penjualan ?? this.penjualan,
      opname: opname ?? this.opname,
      setoran: setoran ?? this.setoran,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        activeTab,
        startDate,
        endDate,
        penjualanLoading,
        opnameLoading,
        setoranLoading,
        penjualan,
        opname,
        setoran,
        errorMessage,
      ];
}