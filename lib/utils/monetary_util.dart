import 'package:intl/intl.dart';

String formatMonero(num? value) {
  if (value == null) {
    return "";
  }
  var formatter = NumberFormat("###.####");
  formatter.minimumFractionDigits = 4;
  return formatter.format(value / 1e12);
}
