import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syathiby/core/services/shared_preferences_service.dart';
import 'package:syathiby/core/utils/logger_util.dart';
import 'package:syathiby/features/sale/bloc/sale_event.dart';
import 'package:syathiby/features/sale/bloc/sale_state.dart';
import 'package:syathiby/features/sale/models/cart_item_model.dart';
import 'package:syathiby/features/sale/service/sale_service.dart';

class SaleBloc extends Bloc<SaleEvent, SaleState> {
  final SaleService saleService;

  SaleBloc({required this.saleService}) : super(const SaleInitial()) {
    on<AddToCartEvent>(_onAddToCart);
    on<UpdateCartItemEvent>(_onUpdateCartItem);
    on<RemoveFromCartEvent>(_onRemoveFromCart);
    on<ClearCartEvent>(_onClearCart);
    on<TogglePriceModeEvent>(_onTogglePriceMode);
    on<SubmitSaleEvent>(_onSubmitSale);
  }

  List<CartItemModel> _cartItems = [];

  void _onAddToCart(AddToCartEvent event, Emitter<SaleState> emit) {
    final existingIndex =
        _cartItems.indexWhere((item) => item.productId == event.productId);

    if (existingIndex >= 0) {
      _cartItems[existingIndex].quantity++;
    } else {
      _cartItems.add(CartItemModel(
        productId: event.productId,
        productCode: event.productCode,
        productName: event.productName,
        priceArea1: event.priceArea1,
        priceArea2: event.priceArea2,
        priceArea3: event.priceArea3,
        buyPrice: event.buyPrice,
      ));
    }

    emit(SaleInProgress(
      cartItems: List.from(_cartItems),
      totalAmount: _calculateTotal(),
    ));
  }

  void _onUpdateCartItem(
      UpdateCartItemEvent event, Emitter<SaleState> emit) {
    final index =
        _cartItems.indexWhere((item) => item.productId == event.productId);

    if (index >= 0) {
      if (event.quantity > 0) {
        _cartItems[index].quantity = event.quantity;
      }

      if (event.priceMode != null) {
        _cartItems[index] = _cartItems[index].copyWith(
          priceMode: event.priceMode == 'grosir'
              ? PriceMode.grosir
              : PriceMode.retail,
        );
      }

      if (event.selectedPriceArea != null) {
        _cartItems[index] = _cartItems[index].copyWith(
          selectedPriceArea:
              PriceArea.values.firstWhere((e) => e.name == event.selectedPriceArea),
        );
      }

      if (event.manualPrice != null) {
        _cartItems[index] = _cartItems[index].copyWith(
          manualPrice: event.manualPrice,
        );
      }

      emit(SaleInProgress(
        cartItems: List.from(_cartItems),
        totalAmount: _calculateTotal(),
      ));
    }
  }

  void _onRemoveFromCart(RemoveFromCartEvent event, Emitter<SaleState> emit) {
    _cartItems.removeWhere((item) => item.productId == event.productId);
    emit(SaleInProgress(
      cartItems: List.from(_cartItems),
      totalAmount: _calculateTotal(),
    ));
  }

  void _onClearCart(ClearCartEvent event, Emitter<SaleState> emit) {
    _cartItems.clear();
    emit(const SaleInProgress(cartItems: [], totalAmount: 0));
  }

  void _onTogglePriceMode(TogglePriceModeEvent event, Emitter<SaleState> emit) {
    final index =
        _cartItems.indexWhere((item) => item.productId == event.productId);

    if (index >= 0) {
      _cartItems[index] = _cartItems[index].copyWith(
        priceMode: event.priceMode == 'grosir'
            ? PriceMode.grosir
            : PriceMode.retail,
      );
      emit(SaleInProgress(
        cartItems: List.from(_cartItems),
        totalAmount: _calculateTotal(),
      ));
    }
  }

  Future<void> _onSubmitSale(SubmitSaleEvent event, Emitter<SaleState> emit) async {
    if (_cartItems.isEmpty) {
      emit(const SaleError('Cart is empty'));
      return;
    }

    emit(const SaleSubmitting());

    try {
      final userId = SharedPreferencesService.instance
          .getData<String>(PreferenceKey.userId);
      final brId = SharedPreferencesService.instance
          .getData<String>(PreferenceKey.branchId);

      if (userId == null || brId == null) {
        emit(const SaleError('Unauthorized: Missing user data'));
        return;
      }

      final isGrosir = _cartItems.any((item) => item.priceMode == PriceMode.grosir) ? 1 : 0;

      final productIds = _cartItems.map((item) => item.productId).toList();
      final quantities = _cartItems.map((item) => item.quantity.toString()).toList();
      final prices = _cartItems.map((item) => item.selectedPrice.toString()).toList();

      String? dibayar = event.cashReceived;
      String? kembali;
      
      if (event.paymentMethod == 'edc') {
        final totalWithMdr = _calculateTotal() + (double.tryParse(event.mdr ?? '0') ?? 0);
        dibayar = totalWithMdr.toStringAsFixed(0);
        kembali = '0';
      } else if (event.paymentMethod == 'tunai') {
        kembali = _calculateChange(event.cashReceived);
      }

      final response = await saleService.createSale(
        userId: userId,
        brId: brId,
        isGrosir: isGrosir,
        productIds: productIds,
        quantities: quantities,
        prices: prices,
        paymentMethod: event.paymentMethod,
        dibayar: dibayar,
        kembali: kembali,
      );

      if (response.statusCode == 200 && response.data != null) {
        final saleData = response.data!.data;
        await SharedPreferencesService.instance
            .setData(PreferenceKey.saleCompletedToday, true);

        String printId = saleData?.id ?? response.data!.saleId ?? '';
        String printUrl =
            'https://banghasyim.net/ZAHIR4/sale/sale/prints/$printId';
        emit(SaleSuccess(sale: saleData, printUrl: printUrl));
      } else {
        emit(SaleError(response.message ?? 'Failed to submit sale'));
      }
    } catch (e, stack) {
      LoggerUtil.error('Error submitting sale', e, stack);
      emit(SaleError('Error: ${e.toString()}'));
    }
  }

  String? _calculateChange(String? cashReceived) {
    if (cashReceived == null) return null;
    final cash = double.tryParse(cashReceived);
    if (cash == null) return null;
    final change = cash - _calculateTotal();
    return change > 0 ? change.toStringAsFixed(0) : '0';
  }

  double _calculateTotal() {
    return _cartItems.fold(0, (sum, item) => sum + item.subtotal);
  }
}