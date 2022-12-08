import 'package:anon_wallet/models/wallet.dart';
import 'package:anon_wallet/screens/home/settings/settings_state.dart';
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

  Future setProxy(String proxy, String port) async {
    dynamic value = await platform
        .invokeMethod("setProxy", {"proxyServer": proxy, "proxyPort": port});
  }

  Future<Proxy> getProxy() async {
    dynamic value = await platform.invokeMethod("getProxy");
    return Proxy.fromJson(value);
  }

  Future setNode(
      String host, int port, String? username, String? password) async {
    dynamic value = await platform.invokeMethod("setNode", {
      "host": host,
      "port": port,
      "password": password,
      "username": username
    });
    return Node.fromJson(value);
  }

  Future addNode(
      String host, int port, String? username, String? password) async {
    dynamic value = await platform.invokeMethod("addNewNode", {
      "host": host,
      "port": port,
      "password": password,
      "username": username
    });
    return Node.fromJson(value);
  }

  Future<Node?> getNodeFromPrefs() async {
    try {
      dynamic value = await platform.invokeMethod("getNodeFromPrefs");
      if (value != null) {
        return Node.fromJson(value);
      }
    } catch (e) {
      print(e);
      return null;
    }
    return null;
  }

  Future<Node?> testRpc(
      String? host, int? port, String? username, String? password) async {
    dynamic value = await platform.invokeMethod("testRpc", {
      "host": host,
      "port": port,
      "password": password,
      "username": username
    });
    return Node.fromJson(value);
  }

  Future<List<Node>> getAllNodes() async {
    dynamic value = await platform.invokeMethod("getAllNodes");
    List<Node> nodes = [];
    value.forEach((item) {
      nodes.add(Node.fromJson(item));
    });
    return nodes;
  }

  Future setCurrentNode(Node node) async {
    dynamic value = await platform.invokeMethod("setCurrentNode", {
      "host": node.host,
      "port": node.port,
      "password": node.password,
      "username": node.username
    });
  }

  Future removeNode(Node node) async {
    dynamic value = await platform.invokeMethod("removeNode", {
      "host": node.host,
      "port": node.port,
      "password": node.password,
      "username": node.username
    });
  }
}
