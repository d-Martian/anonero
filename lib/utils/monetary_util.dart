import 'package:intl/intl.dart';

String formatMonero(num? value, {int minimumFractions = 4}) {
  if (value == null) {
    return "";
  }
  var formatter = NumberFormat("###.####");
  formatter.maximumFractionDigits = minimumFractions;
  formatter.minimumFractionDigits = minimumFractions;
  return formatter.format(value / 1e12);
}
