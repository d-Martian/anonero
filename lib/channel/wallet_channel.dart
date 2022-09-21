import 'package:anon_wallet/models/wallet.dart';
import 'package:flutter/services.dart';

enum WalletState {
  walletNotInitialized,
  //Wallet exist not connected to node
  walletCreated,
  //Wallet exist and connected to node
  walletReady
}

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

  Future<Wallet?> openWallet(String password) async {
    dynamic value = await platform.invokeMethod("openWallet", {"password": password});
    return Wallet.fromJson(value);
  }

  Future<Wallet> generateSeed(String password, String seedPassPhrase) async {
    dynamic value =
        await platform.invokeMethod("generateSeed", {"seedPassPhrase": seedPassPhrase, "password": password});
    return Wallet.fromJson(value);
  }

  void startSync()async {
    dynamic value =
        await platform.invokeMethod("startSync");
  }

  Future<WalletState> getWalletState() async {
    int value = await platform.invokeMethod("walletState");
    if (value == 1) {
      return WalletState.walletCreated;
    }
    if (value == 2) {
      return WalletState.walletReady;
    }
    return WalletState.walletNotInitialized;
  }


}
