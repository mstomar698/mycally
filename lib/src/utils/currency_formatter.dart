import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

String formatCurrency(BuildContext context, double amount) {
  return NumberFormat.currency(
    locale: context.locale.toLanguageTag(),
    symbol: '₹',
    decimalDigits: 2,
  ).format(amount);
}
