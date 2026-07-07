import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syathiby/core/services/shared_preferences_service.dart';
import 'package:syathiby/core/utils/logger_util.dart';
import 'package:syathiby/features/home/service/rack_model.dart';
import 'package:syathiby/features/home/service/rack_service.dart';
import 'package:syathiby/features/opname/bloc/opname_event.dart';
import 'package:syathiby/features/opname/bloc/opname_state.dart';
import 'package:syathiby/features/opname/service/opname_service.dart';
import 'package:syathiby/features/product/service/product_service.dart';

class OpnameBloc extends Bloc<OpnameEvent, OpnameState> {
  final OpnameService opnameService;
  final RackService rackService;
  final ProductService productService;

  OpnameBloc({
    required this.opnameService,
    required this.rackService,
    required this.productService,
  }) : super(const OpnameInitial()) {
    on<GetOpnameProductsEvent>(_onGetProducts);
    on<UpdateActualStockEvent>(_onUpdateActualStock);
    on<SubmitOpnameEvent>(_onSubmitOpname);
    on<ResetOpnameEvent>(_onResetOpname);
    on<ScanBarcodeEvent>(_onScanBarcode);
    on<LoadRacksEvent>(_onLoadRacks);
    on<ChangeRackEvent>(_onChangeRack);
    on<ScanFromGalleryEvent>(_onScanFromGallery);
    on<UndoScanEvent>(_onUndoScan);
  }

  List<OpnameItemModel> _opnameItems = [];
  List<RackModel> _racks = [];
  String? _selectedRaId;

  void _onGetProducts(
      GetOpnameProductsEvent event, Emitter<OpnameState> emit) async {
    emit(const OpnameLoading());

    try {
      final rackFuture = rackService.getRacks();
      final productFuture = productService.getProducts(
        searchValue: event.searchValue,
      );

      final rackResponse = await rackFuture;
      final productResponse = await productFuture;

      LoggerUtil.debug(
        'Rack fetch: status=${rackResponse.statusCode} count=${rackResponse.data?.length ?? 0}',
      );

      if (rackResponse.statusCode == 200 && rackResponse.data != null) {
        _racks = rackResponse.data!;

        if (_racks.isEmpty) {
          LoggerUtil.warning('No racks available for this user/branch');
          emit(const OpnameError(
              'Tidak ada rak tersedia. Hubungi admin untuk setup rak.'));
          return;
        }

        String? raIdToUse = event.raId ?? _selectedRaId;
        if (raIdToUse == null || raIdToUse.isEmpty) {
          raIdToUse = _racks.first.raId.isEmpty ? null : _racks.first.raId;
        }
        if (raIdToUse != null && raIdToUse.isNotEmpty) {
          _selectedRaId = raIdToUse;
          LoggerUtil.debug(
            'Selected rack: $raIdToUse (${_findRackName(raIdToUse)})',
          );
        } else {
          LoggerUtil.warning('Auto-select failed: first rack has empty ra_id');
        }

        if (productResponse.statusCode == 200 && productResponse.data != null) {
          _opnameItems = productResponse.data!.map((p) {
            return OpnameItemModel(
              productId: p.id ?? '',
              productCode: p.pCode ?? '',
              productName: p.pName ?? '',
              systemStock: p.stock ?? '0',
              actualStock: '0',
              raId: raIdToUse,
              raName: _findRackName(raIdToUse),
            );
          }).toList();
        }

        emit(OpnameInProgress(
          items: _opnameItems,
          racks: _racks,
          selectedRaId: raIdToUse,
        ));
      } else {
        emit(OpnameError(
            '[${rackResponse.statusCode}] ${rackResponse.message ?? 'Failed to load racks'}'));
      }
    } catch (e, stack) {
      LoggerUtil.error('Error fetching opname products', e, stack);
      emit(OpnameError('Error: ${e.toString()}'));
    }
  }

  String? _findRackName(String? raId) {
    if (raId == null) return null;
    final match = _racks.where((r) => r.raId == raId);
    return match.isNotEmpty ? match.first.raName : null;
  }

  void _onUpdateActualStock(
      UpdateActualStockEvent event, Emitter<OpnameState> emit) async {
    if (state is! OpnameInProgress) return;
    final currentState = state as OpnameInProgress;

    final existingIndex =
        currentState.items.indexWhere((i) => i.productId == event.productId);
    if (existingIndex < 0) return;

    final updatedItems = currentState.items.map((item) {
      if (item.productId == event.productId) {
        return item.copyWith(actualStock: event.actualStock);
      }
      return item;
    }).toList();

    emit(currentState.copyWith(items: updatedItems));

    try {
      await opnameService.doSaveBarcode(
        pId: event.productId,
        qty: event.actualStock,
      );
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
            final updatedItems = currentState.items.map((item) {
              if (item.productId == event.productId) {
                final newQty = (int.tryParse(item.actualStock) ?? 0) +
                    (int.tryParse(event.qty) ?? 0);
                return item.copyWith(actualStock: newQty.toString());
              }
              return item;
            }).toList();
            emit(currentState.copyWith(items: updatedItems));
          } else {
            final newItem = OpnameItemModel(
              productId: event.productId,
              productCode: event.productCode ?? '',
              productName: event.productName ?? '',
              systemStock: '0',
              actualStock: event.qty,
            );
            emit(currentState.copyWith(items: [...currentState.items, newItem]));
          }
        } else {
          emit(OpnameError(response.message ?? 'Failed to save barcode'));
        }
      } catch (e, stack) {
        LoggerUtil.error('Error scanning barcode', e, stack);
        emit(OpnameError('Error: ${e.toString()}'));
      }
    }
  }

  void _onChangeRack(ChangeRackEvent event, Emitter<OpnameState> emit) async {
    _selectedRaId = event.raId;
    add(GetOpnameProductsEvent(raId: event.raId));
  }

  void _onScanFromGallery(ScanFromGalleryEvent event, Emitter<OpnameState> emit) async {
    if (state is OpnameInProgress) {
      emit(const OpnameError('Scan from gallery belum didukung oleh API'));
    }
  }

  void _onUndoScan(UndoScanEvent event, Emitter<OpnameState> emit) {
    if (state is OpnameInProgress) {
      final currentState = state as OpnameInProgress;

      final updatedItems = currentState.items.map((item) {
        if (item.productId == event.productId) {
          final newQty = (int.tryParse(item.actualStock) ?? 0) - 1;
          return item.copyWith(actualStock: newQty.toString());
        }
        return item;
      }).toList();

      emit(currentState.copyWith(items: updatedItems));
    }
  }

  void _onLoadRacks(LoadRacksEvent event, Emitter<OpnameState> emit) async {
    try {
      final response = await rackService.getRacks();

      if (response.statusCode == 200 && response.data != null) {
        _racks = response.data!;
        if (_racks.isNotEmpty && _selectedRaId == null) {
          _selectedRaId = _racks.first.raId;
        }
        if (state is OpnameInProgress) {
          emit((state as OpnameInProgress).copyWith(racks: _racks));
        }
      }
    } catch (e, stack) {
      LoggerUtil.error('Error loading racks', e, stack);
    }
  }

  Future<void> _onSubmitOpname(
      SubmitOpnameEvent event, Emitter<OpnameState> emit) async {
    if (state is! OpnameInProgress) return;

    final currentState = state as OpnameInProgress;

    if (_selectedRaId == null || _selectedRaId!.isEmpty) {
      emit(const OpnameError('Please select a rack'));
      return;
    }

    final hasItems = currentState.items.any(
      (i) => (int.tryParse(i.actualStock) ?? 0) > 0,
    );
    if (!hasItems) {
      emit(const OpnameError(
          'Tidak ada item yang akan di-submit (qty harus > 0)'));
      return;
    }

    emit(const OpnameSubmitting());

    final draftCheck = await opnameService.getDraft();
    if (draftCheck.statusCode != 200 ||
        draftCheck.data == null ||
        draftCheck.data!.isEmpty) {
      emit(OpnameError(
        'Draft kosong di server. Coba edit qty lagi lalu tunggu sebentar.',
      ));
      return;
    }

    try {
      final response = await opnameService.doFinish(
        raId: _selectedRaId!,
        jenis: 'TOKO',
      );

      if (response.statusCode == 200 && response.data != null) {
        await SharedPreferencesService.instance
            .setData(PreferenceKey.saleCompletedToday, false);

        _opnameItems = [];
        _selectedRaId = null;

        emit(OpnameSuccess(
          opnameId: response.data!.opnameId ?? '',
          opnameCode: response.data!.opnameId ?? '',
        ));
      } else {
        emit(OpnameError(
          '[${response.statusCode}] ${response.message ?? 'Failed to submit opname'}',
        ));
      }
    } catch (e, stack) {
      LoggerUtil.error('Error submitting opname', e, stack);
      emit(OpnameError('Error: ${e.toString()}'));
    }
  }

  void _onResetOpname(ResetOpnameEvent event, Emitter<OpnameState> emit) {
    _opnameItems = [];
    _selectedRaId = null;
    emit(const OpnameInitial());
  }

  void selectRack(String raId) {
    _selectedRaId = raId;
    if (state is OpnameInProgress) {
      emit((state as OpnameInProgress).copyWith(selectedRaId: raId));
    }
  }
}