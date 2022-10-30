import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:anon_wallet/channel/node_channel.dart';
import 'package:anon_wallet/channel/wallet_channel.dart';
import 'package:anon_wallet/models/wallet.dart';
import 'package:anon_wallet/state/wallet_state.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class Proxy {
  String serverUrl = "";
  String port = "";

  Proxy();

  Proxy.fromJson(value) {
    serverUrl = value['proxyServer'] ?? "";
    port = value['proxyPort'] ?? "";
  }

  isConnected() {
    return serverUrl.isNotEmpty && port.isNotEmpty;
  }
}

class ProxyStateNotifier extends StateNotifier<Proxy> {
  ProxyStateNotifier(super.state);

  Future getState() async {
    state = await NodeChannel().getProxy();
  }

  setProxy(String proxy, String port) async {
    await NodeChannel().setProxy(proxy, port);
    state = await NodeChannel().getProxy();
  }
}

class ViewWalletPrivateDetailsStateNotifier extends StateNotifier<Wallet?> {
  ViewWalletPrivateDetailsStateNotifier(super.state);

  Future getWallet(String seedPassphrase) async {
    state = await WalletChannel().getWalletPrivate(seedPassphrase);
  }

  clear() {
    state = null;
  }
}

final proxyStateProvider = StateNotifierProvider<ProxyStateNotifier, Proxy>((ref) => ProxyStateNotifier(Proxy()));

final viewPrivateWalletProvider = StateNotifierProvider<ViewWalletPrivateDetailsStateNotifier, Wallet?>(
    (ref) => ViewWalletPrivateDetailsStateNotifier(null));
