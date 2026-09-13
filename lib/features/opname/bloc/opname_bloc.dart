import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syathiby/core/services/shared_preferences_service.dart';
import 'package:syathiby/core/utils/logger_util.dart';
import 'package:syathiby/features/opname/bloc/opname_event.dart';
import 'package:syathiby/features/opname/bloc/opname_state.dart';
import 'package:syathiby/features/opname/service/opname_service.dart';
import 'package:syathiby/features/product/service/product_service.dart';

class OpnameBloc extends Bloc<OpnameEvent, OpnameState> {
  final OpnameService opnameService;
  final ProductService productService;

  OpnameBloc({
    required this.opnameService,
    required this.productService,
  }) : super(const OpnameInitial()) {
    on<GetOpnameProductsEvent>(_onGetProducts);
    on<UpdateActualStockEvent>(_onUpdateActualStock);
    on<SubmitOpnameEvent>(_onSubmitOpname);
    on<ResetOpnameEvent>(_onResetOpname);
    on<ScanBarcodeEvent>(_onScanBarcode);
    on<ScanFromGalleryEvent>(_onScanFromGallery);
    on<UndoScanEvent>(_onUndoScan);
  }

  /// Item yang sudah dihitung kasir, dipertahankan lintas pencarian.
  final Map<String, OpnameItemModel> _counted = {};

  List<OpnameItemModel> get _countedList => _counted.values.toList();

  /// Tempelkan qty yang sudah pernah diisi ke hasil pencarian terbaru.
  List<OpnameItemModel> _mergeCounted(List<OpnameItemModel> items) {
    return items.map((item) {
      final counted = _counted[item.productId];
      if (counted == null) return item;
      return item.copyWith(
        actualStock: counted.actualStock,
        isCounted: true,
      );
    }).toList();
  }

  void _rememberCounted(OpnameItemModel item) {
    if (item.actualStock.trim().isEmpty) {
      _counted.remove(item.productId);
    } else {
      _counted[item.productId] = item.copyWith(isCounted: true);
    }
  }

  void _onGetProducts(
      GetOpnameProductsEvent event, Emitter<OpnameState> emit) async {
    emit(const OpnameLoading());

    try {
      final productResponse = await productService.getProducts(
        searchValue: event.searchValue,
      );

      if (productResponse.statusCode == 200 && productResponse.data != null) {
        final items = productResponse.data!.map((p) {
          return OpnameItemModel(
            productId: p.id ?? '',
            productCode: p.pCode ?? '',
            productName: p.pName ?? '',
            systemStock: p.stock ?? '0',
            actualStock: '',
          );
        }).toList();

        emit(OpnameInProgress(
          items: _mergeCounted(items),
          countedItems: _countedList,
        ));
      } else {
        emit(OpnameError(
          '[${productResponse.statusCode}] ${productResponse.message ?? 'Failed to load products'}',
        ));
      }
    } catch (e, stack) {
      LoggerUtil.error('Error fetching opname products', e, stack);
      emit(OpnameError('Error: ${e.toString()}'));
    }
  }

  void _onUpdateActualStock(
      UpdateActualStockEvent event, Emitter<OpnameState> emit) async {
    if (state is! OpnameInProgress) return;
    final currentState = state as OpnameInProgress;

    final existingIndex =
        currentState.items.indexWhere((i) => i.productId == event.productId);
    if (existingIndex < 0) return;

    final updated = currentState.items[existingIndex].copyWith(
      actualStock: event.actualStock,
      isCounted: event.actualStock.trim().isNotEmpty,
    );
    _rememberCounted(updated);

    final updatedItems = List<OpnameItemModel>.from(currentState.items);
    updatedItems[existingIndex] = updated;

    emit(currentState.copyWith(
      items: updatedItems,
      countedItems: _countedList,
    ));

    if (updated.actualStock.trim().isEmpty) return;

    try {
      final response = await opnameService.doSaveBarcode(
        pId: event.productId,
        qty: updated.actualStock,
      );
      if (response.statusCode != 200) {
        LoggerUtil.error(
          'do_save ditolak server untuk ${event.productId}: ${response.message}',
        );
      }
    } catch (e, stack) {
      LoggerUtil.error('do_save failed for ${event.productId}', e, stack);
    }
  }

  void _onScanBarcode(ScanBarcodeEvent event, Emitter<OpnameState> emit) async {
    if (state is OpnameInProgress) {
      final currentState = state as OpnameInProgress;

      try {
        final response = await opnameService.doSaveBarcode(
          pId: event.productId,
          qty: event.qty,
        );

        if (response.statusCode == 200 && response.data != null) {
          final existingIndex = currentState.items.indexWhere(
            (item) => item.productId == event.productId,
          );

          if (existingIndex >= 0) {
            final item = currentState.items[existingIndex];
            final newQty = (int.tryParse(item.actualStock) ?? 0) +
                (int.tryParse(event.qty) ?? 0);
            final updated = item.copyWith(
              actualStock: newQty.toString(),
              isCounted: true,
            );
            _rememberCounted(updated);

            final updatedItems = List<OpnameItemModel>.from(currentState.items);
            updatedItems[existingIndex] = updated;
            emit(currentState.copyWith(
              items: updatedItems,
              countedItems: _countedList,
            ));
          } else {
            final newItem = OpnameItemModel(
              productId: event.productId,
              productCode: event.productCode,
              productName: event.productName,
              systemStock: '0',
              actualStock: event.qty,
              isCounted: true,
            );
            _rememberCounted(newItem);
            emit(currentState.copyWith(
              items: [...currentState.items, newItem],
              countedItems: _countedList,
            ));
          }
        } else {
          emit(OpnameError(response.message ?? 'Failed to save barcode'));
          emit(currentState);
        }
      } catch (e, stack) {
        LoggerUtil.error('Error scanning barcode', e, stack);
        emit(OpnameError('Error: ${e.toString()}'));
        emit(currentState);
      }
    }
  }

  void _onScanFromGallery(
      ScanFromGalleryEvent event, Emitter<OpnameState> emit) async {
    if (state is OpnameInProgress) {
      final currentState = state as OpnameInProgress;
      emit(const OpnameError('Scan from gallery belum didukung oleh API'));
      emit(currentState);
    }
  }

  void _onUndoScan(UndoScanEvent event, Emitter<OpnameState> emit) {
    if (state is OpnameInProgress) {
      final currentState = state as OpnameInProgress;

      final updatedItems = currentState.items.map((item) {
        if (item.productId == event.productId) {
          final newQty = (int.tryParse(item.actualStock) ?? 0) - 1;
          final updated = item.copyWith(actualStock: newQty.toString());
          _rememberCounted(updated);
          return updated;
        }
        return item;
      }).toList();

      emit(currentState.copyWith(
        items: updatedItems,
        countedItems: _countedList,
      ));
    }
  }

  Future<void> _onSubmitOpname(
      SubmitOpnameEvent event, Emitter<OpnameState> emit) async {
    if (state is! OpnameInProgress) return;

    final currentState = state as OpnameInProgress;

    if (_counted.isEmpty) {
      emit(const OpnameError('Belum ada item yang dihitung.'));
      emit(currentState);
      return;
    }

    emit(const OpnameSubmitting());

    try {
      // Sinkronkan ulang semua item terhitung supaya draft di server pasti sama
      // dengan yang tampil di layar: do_save saat mengetik bisa gagal diam-diam
      // (mis. koneksi putus sesaat) dan submit jadi ikut kosong.
      final failed = <String>[];
      for (final item in _countedList) {
        final saved = await opnameService.doSaveBarcode(
          pId: item.productId,
          qty: item.actualStock,
        );
        if (saved.statusCode != 200) {
          failed.add('${item.productName} (${saved.message ?? 'gagal'})');
        }
      }

      if (failed.length == _counted.length) {
        emit(OpnameError('Gagal menyimpan item ke server: ${failed.first}'));
        emit(currentState);
        return;
      }

      final draftCheck = await opnameService.getDraft();
      if (draftCheck.statusCode != 200) {
        emit(OpnameError(
          '[${draftCheck.statusCode}] ${draftCheck.message ?? 'Gagal membaca draft opname'}',
        ));
        emit(currentState);
        return;
      }
      if (draftCheck.data == null || draftCheck.data!.isEmpty) {
        emit(const OpnameError(
          'Draft opname masih kosong di server, jadi belum bisa di-submit. '
          'Cek koneksi lalu isi ulang qty item.',
        ));
        emit(currentState);
        return;
      }

      final response = await opnameService.doFinish(jenis: 'TOKO');

      if (response.statusCode == 200 && response.data != null) {
        await SharedPreferencesService.instance
            .setData(PreferenceKey.saleCompletedToday, false);

        _counted.clear();

        emit(OpnameSuccess(
          opnameId: response.data!.opnameId ?? '',
          opnameCode: response.data!.opnameId ?? '',
        ));
      } else {
        emit(OpnameError(
          '[${response.statusCode}] ${response.message ?? 'Gagal submit opname'}',
        ));
        emit(currentState);
      }
    } catch (e, stack) {
      LoggerUtil.error('Error submitting opname', e, stack);
      emit(OpnameError('Error: ${e.toString()}'));
      emit(currentState);
    }
  }

  void _onResetOpname(ResetOpnameEvent event, Emitter<OpnameState> emit) {
    _counted.clear();
    emit(const OpnameInitial());
  }
}
