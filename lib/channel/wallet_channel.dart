import 'package:anon_wallet/models/wallet.dart';
import 'package:flutter/services.dart';

class WalletChannel {
  static const platform = MethodChannel('wallet.channel');
  static final WalletChannel _singleton = WalletChannel._internal();

  WalletChannel._internal();

  factory WalletChannel() {
    return _singleton;
  }

  Future<Wallet> create(String password, String seedPhrase) async {
    dynamic value =
        await platform.invokeMethod("create", {"name": "default", "password": password, "seedPhrase": seedPhrase});
    return Wallet.fromJson(value);
  }

  Future<Wallet> generateSeed(String password, String seedPassPhrase) async {
    dynamic value =
        await platform.invokeMethod("generateSeed", {"seedPassPhrase": seedPassPhrase, "password": password});
    return Wallet.fromJson(value);
  }
}
