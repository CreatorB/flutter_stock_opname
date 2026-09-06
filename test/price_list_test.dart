import 'package:flutter_test/flutter_test.dart';
import 'package:syathiby/features/product/models/price_list_model.dart';
import 'package:syathiby/features/sale/models/cart_item_model.dart';

void main() {
  group('PriceListModel parsing', () {
    test('parses list of price entries', () {
      final json = {
        'status': true,
        'result': [
          {'p_id': '12907', 'price': '10000', 'qty': '1'},
          {'p_id': '12907', 'price': '9000', 'qty': '5'},
          {'p_id': '12907', 'price': '8000', 'qty': '10'},
        ],
      };

      final model = PriceListModel.fromJson(json);

      expect(model.items.length, 3);
      expect(model.items[0].priceDouble, 10000);
      expect(model.items[0].qtyInt, 1);
      expect(model.items[1].priceDouble, 9000);
      expect(model.items[2].priceDouble, 8000);
    });

    test('parses object with price_area1/2/3 fields', () {
      final json = {
        'result': {
          'p_id': '12907',
          'price_area1': '10000',
          'price_area2': '9000',
          'price_area3': '8000',
        },
      };

      final model = PriceListModel.fromJson(json);

      expect(model.items.length, 3);
      expect(model.items[0].priceDouble, 10000);
      expect(model.items[2].priceDouble, 8000);
    });

    test('retailDisplay returns items as-is', () {
      final json = {
        'result': [
          {'price': '10000'},
          {'price': '9000'},
          {'price': '8000'},
        ],
      };
      final model = PriceListModel.fromJson(json);

      expect(model.retailDisplay[0].priceDouble, 10000);
      expect(model.retailDisplay[1].priceDouble, 9000);
      expect(model.retailDisplay[2].priceDouble, 8000);
    });

    test('parses API response with id/text as price', () {
      final json = {
        'status': true,
        'result': [
          {'id': 60000, 'text': '60000'},
          {'id': 57500, 'text': '57500'},
          {'id': 57000, 'text': '57000'},
        ],
      };

      final model = PriceListModel.fromJson(json);

      expect(model.items.length, 3);
      expect(model.items[0].priceDouble, 60000);
      expect(model.items[1].priceDouble, 57500);
      expect(model.items[2].priceDouble, 57000);
    });

    test('grosirDisplay returns items as-is (server already sorted)', () {
      final json = {
        'result': [
          {'id': 57000},
          {'id': 57500},
          {'id': 60000},
        ],
      };
      final model = PriceListModel.fromJson(json);

      expect(model.grosirDisplay[0].priceDouble, 57000);
      expect(model.grosirDisplay[1].priceDouble, 57500);
      expect(model.grosirDisplay[2].priceDouble, 60000);
    });
  });

  group('CartItemModel selectedPrice', () {
    test('uses retail price list when set', () {
      final cart = CartItemModel(
        productId: '1',
        productCode: 'P1',
        productName: 'Test',
        priceMode: PriceMode.retail,
        retailPriceList: PriceListModel.fromJson({
          'result': [
            {'price': '10000'},
            {'price': '9000'},
            {'price': '8000'},
          ],
        }),
        selectedPriceListIndex: 1,
      );

      expect(cart.selectedPrice, '9000');
      expect(cart.selectedPriceDouble, 9000);
    });

    test('uses grosir price list as-is (server pre-sorted)', () {
      final cart = CartItemModel(
        productId: '1',
        productCode: 'P1',
        productName: 'Test',
        priceMode: PriceMode.grosir,
        grosirPriceList: PriceListModel.fromJson({
          'result': [
            {'id': 57000},
            {'id': 57500},
            {'id': 60000},
          ],
        }),
        selectedPriceListIndex: 0,
      );

      expect(cart.selectedPrice, '57000');
    });

    test('falls back to priceArea fields when no price list', () {
      final cart = CartItemModel(
        productId: '1',
        productCode: 'P1',
        productName: 'Test',
        priceMode: PriceMode.retail,
        selectedPriceArea: PriceArea.area2,
        priceArea1: '10000',
        priceArea2: '9000',
        priceArea3: '8000',
      );

      expect(cart.selectedPrice, '9000');
    });

    test('subtotal = price * qty', () {
      final cart = CartItemModel(
        productId: '1',
        productCode: 'P1',
        productName: 'Test',
        priceMode: PriceMode.retail,
        retailPriceList: PriceListModel.fromJson({
          'result': [
            {'price': '10000'},
          ],
        }),
        quantity: 3,
      );

      expect(cart.subtotal, 30000);
    });

    test('isValidGrosirPrice checks against HPP', () {
      final cart = CartItemModel(
        productId: '1',
        productCode: 'P1',
        productName: 'Test',
        priceMode: PriceMode.grosir,
        buyPrice: '5000',
        grosirPriceList: PriceListModel.fromJson({
          'result': [{'price': '4000'}],
        }),
        selectedPriceListIndex: 0,
      );

      expect(cart.isValidGrosirPrice(), false);
    });

    test('isValidGrosirPrice passes when >= HPP', () {
      final cart = CartItemModel(
        productId: '1',
        productCode: 'P1',
        productName: 'Test',
        priceMode: PriceMode.grosir,
        buyPrice: '5000',
        grosirPriceList: PriceListModel.fromJson({
          'result': [{'price': '6000'}],
        }),
        selectedPriceListIndex: 0,
      );

      expect(cart.isValidGrosirPrice(), true);
    });
  });

  group('CartItemModel copyWith', () {
    test('preserves price lists when not provided', () {
      final original = CartItemModel(
        productId: '1',
        productCode: 'P1',
        productName: 'Test',
        retailPriceList: PriceListModel.fromJson({
          'result': [{'price': '10000'}],
        }),
      );

      final updated = original.copyWith(quantity: 5);

      expect(updated.quantity, 5);
      expect(updated.retailPriceList, isNotNull);
      expect(updated.retailPriceList!.items.length, 1);
    });
  });
}
