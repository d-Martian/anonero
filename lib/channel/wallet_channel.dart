import 'package:flutter/services.dart';

class WalletChannel {
  static const platform = MethodChannel('wallet.channel');
  static final WalletChannel _singleton = new WalletChannel._internal();

  WalletChannel._internal();

  factory WalletChannel() {
    return _singleton;
  }

  //TODO:
  create() {
    platform.invokeMethod("create");
  }
}
