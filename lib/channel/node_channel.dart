import 'package:anon_wallet/models/wallet.dart';
import 'package:flutter/services.dart';

import '../models/node.dart';

class NodeChannel {
  static const platform = MethodChannel('node.channel');
  static final NodeChannel _singleton = NodeChannel._internal();

  NodeChannel._internal();

  factory NodeChannel() {
    return _singleton;
  }

  Future<Wallet> testRPC() async {
    dynamic value = await platform.invokeMethod("testRPC");
    return Wallet.fromJson(value);
  }

  Future setNode(String host, int port, String? username, String? password) async {
    dynamic value = await platform.invokeMethod("setNode", {
      "host": host,
      "port": port,
      "password": password,
      "username": username
    });
    return Node.fromJson(value);
  }
}
