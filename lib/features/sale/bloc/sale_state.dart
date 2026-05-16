import 'package:equatable/equatable.dart';
import 'package:syathiby/features/sale/models/cart_item_model.dart';
import 'package:syathiby/features/sale/models/sale_model.dart';

abstract class SaleState extends Equatable {
  const SaleState();

  @override
  List<Object?> get props => [];
}

class SaleInitial extends SaleState {
  const SaleInitial();
}

class SaleLoading extends SaleState {
  const SaleLoading();
}

class SaleInProgress extends SaleState {
  final List<CartItemModel> cartItems;
  final double totalAmount;

  const SaleInProgress({
    this.cartItems = const [],
    this.totalAmount = 0,
  });

  SaleInProgress copyWith({
    List<CartItemModel>? cartItems,
    double? totalAmount,
  }) {
    return SaleInProgress(
      cartItems: cartItems ?? this.cartItems,
      totalAmount: totalAmount ?? this.totalAmount,
    );
  }

  @override
  List<Object?> get props => [cartItems, totalAmount];
}

class SaleSubmitting extends SaleState {
  const SaleSubmitting();
}

class SaleSuccess extends SaleState {
  final SaleModel? sale;
  final String printUrl;

  const SaleSuccess({this.sale, required this.printUrl});

  @override
  List<Object?> get props => [sale, printUrl];
}

class SaleError extends SaleState {
  final String message;

  const SaleError(this.message);

  @override
  List<Object?> get props => [message];
}