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

  Future<void> rescan() async {
    dynamic value = await platform.invokeMethod("rescan");
  }

  Future<void> refresh() async {
    dynamic value = await platform.invokeMethod("refresh");
  }

  Future<Wallet?> openWallet(String password) async {
    dynamic value = await platform.invokeMethod("openWallet", {"password": password});
    return Wallet.fromJson(value);
  }

  Future<String?> getTxKey(String txId) async {
    String? value = await platform.invokeMethod("getTxKey", {"txId": txId});
    return value;
  }

  void startSync() async {
    dynamic value = await platform.invokeMethod("startSync");
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

  Future<Wallet>  getWalletPrivate(String seedPassphrase) async {
    dynamic value =
        await platform.invokeMethod("viewWalletInfo", {"seedPassphrase": seedPassphrase});
    return Wallet.fromJson(value);
  }
}
