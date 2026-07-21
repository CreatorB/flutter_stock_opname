import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syathiby/core/constants/color_constants.dart';
import 'package:syathiby/features/product/models/product_model.dart';

class ProductDetailView extends StatelessWidget {
  final ProductModel product;

  const ProductDetailView({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    final brightness = CupertinoTheme.brightnessOf(context);
    final isDark = brightness == Brightness.dark;

    final Color scaffoldBg = isDark
        ? ColorConstants.darkBackground
        : const Color(0xFFF5F7FA);
    final Color cardBg = isDark ? ColorConstants.glassCardSolid : Colors.white;
    final Color imageBg = isDark ? const Color(0xFF162032) : const Color(0xFFE8ECF1);
    final Color imageIconColor = isDark ? ColorConstants.grayText : const Color(0xFF7A8A9A);
    final Color primaryText = isDark ? ColorConstants.whiteText : const Color(0xFF1A1A1A);
    final Color secondaryText = isDark ? ColorConstants.grayText : const Color(0xFF5A6A7A);
    final Color dividerColor = isDark ? ColorConstants.glassBorder : const Color(0xFFE0E5EB);
    final Color codeBg = (isDark ? ColorConstants.secondaryBlue : const Color(0xFF1e90ff))
        .withOpacity(0.12);
    final Color codeText = isDark ? ColorConstants.secondaryBlue : const Color(0xFF1565c0);
    final Color priceColor = isDark ? ColorConstants.greenPrice : const Color(0xFF2E7D32);
    final Color stockEmptyColor = ColorConstants.redError;
    final Color stockFilledColor = primaryText;
    final Color appBarFg = Colors.white;
    final Color appBarBg = const Color(0xFF1e88e5);

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        title: const Text('Product Detail'),
        backgroundColor: appBarBg,
        foregroundColor: appBarFg,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 200,
              color: imageBg,
              child: Center(
                child: Icon(
                  Icons.image_not_supported_outlined,
                  size: 64,
                  color: imageIconColor,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: dividerColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.pName ?? 'Unknown Product',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: primaryText,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: codeBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Code: ${product.pCode ?? '-'}',
                        style: TextStyle(
                          color: codeText,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Price',
                              style: TextStyle(
                                color: secondaryText,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              currencyFormat.format(double.tryParse(product.priceArea1 ?? '0') ?? 0),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: priceColor,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Stock',
                              style: TextStyle(
                                color: secondaryText,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              product.stock ?? '0',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: (double.tryParse(product.stock ?? '0') ?? 0) > 0
                                    ? stockFilledColor
                                    : stockEmptyColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Divider(color: dividerColor, height: 1),
                    ),

                    _buildDetailRow('Category', product.pcrName ?? '-',
                        secondaryText, primaryText),
                    _buildDetailRow('Unit', product.puCode ?? '-',
                        secondaryText, primaryText),
                    _buildDetailRow(
                        'Buy Price',
                        currencyFormat.format(double.tryParse(product.buyPrice ?? '0') ?? 0),
                        secondaryText, primaryText),
                    _buildDetailRow('Min Stock', product.minStock ?? '-',
                        secondaryText, primaryText),
                    _buildDetailRow('Max Stock', product.maxStock ?? '-',
                        secondaryText, primaryText),
                    _buildDetailRow('Created At', product.createdAt ?? '-',
                        secondaryText, primaryText),

                    const SizedBox(height: 16),
                    Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product.description ?? 'No description available.',
                      style: TextStyle(
                        color: secondaryText,
                        height: 1.5,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
      String label, String value, Color labelColor, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: labelColor,
              fontSize: 14,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: valueColor,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}