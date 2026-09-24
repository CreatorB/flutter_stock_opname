import 'package:equatable/equatable.dart';

enum LaporanTab { penjualan, opname, setoran }

abstract class LaporanEvent extends Equatable {
  const LaporanEvent();

  @override
  List<Object?> get props => [];
}

class LaporanTabChangedEvent extends LaporanEvent {
  final LaporanTab tab;
  const LaporanTabChangedEvent(this.tab);

  @override
  List<Object?> get props => [tab];
}

class LaporanDateRangeChangedEvent extends LaporanEvent {
  final DateTime? startDate;
  final DateTime? endDate;
  const LaporanDateRangeChangedEvent({this.startDate, this.endDate});

  @override
  List<Object?> get props => [startDate, endDate];
}

class LaporanRefreshEvent extends LaporanEvent {
  const LaporanRefreshEvent();
}