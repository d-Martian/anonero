import 'package:intl/intl.dart';

String formatMonero(num? value,{int minimumFractions=4}) {
  if (value == null) {
    return "";
  }
  if(value == 0){
    return "0";
  }
  var formatter = NumberFormat("###.####");
  formatter.maximumFractionDigits = minimumFractions;
  formatter.minimumFractionDigits = minimumFractions;
  try {
    return formatter.format(value / 1e12);
  } catch (e) {
    print(e);
    return "";
  }
}
