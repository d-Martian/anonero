import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SpendMethodChannel {
  static const platform = MethodChannel('spend.channel');
  static final SpendMethodChannel _singleton = SpendMethodChannel._internal();

  SpendMethodChannel._internal();

  factory SpendMethodChannel() {
    return _singleton;
  }

  dynamic validateAddress(String amount, String address) async {
    return await platform
        .invokeMethod("validate", {"amount": amount, "address": address});
  }

  dynamic compose(String amount, String address, String notes) async {
    return await platform.invokeMethod("composeTransaction",
        {"amount": amount, "address": address, "notes": notes});
  }

  dynamic composeAndBroadcast(
      String amount, String address, String notes) async {
    return await platform.invokeMethod("composeAndBroadcast",
        {"amount": amount, "address": address, "notes": notes});
  }
}
