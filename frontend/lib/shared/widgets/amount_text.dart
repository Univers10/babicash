import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_text_styles.dart';

final _fcfaFormat = NumberFormat('#,###', 'fr_FR');

/// Affiche un montant FCFA formaté : "12 500 FCFA"
class AmountText extends StatelessWidget {
  const AmountText({
    super.key,
    required this.amount,
    this.style,
    this.showCurrency = true,
    this.compact = false,
  });

  final double amount;
  final TextStyle? style;
  final bool showCurrency;
  final bool compact;

  static String format(double amount, {bool showCurrency = true}) {
    final formatted = _fcfaFormat.format(amount.round());
    return showCurrency ? '$formatted FCFA' : formatted;
  }

  @override
  Widget build(BuildContext context) {
    final text = format(amount, showCurrency: showCurrency);
    return Text(text, style: style ?? AppTextStyles.amountMedium);
  }
}
