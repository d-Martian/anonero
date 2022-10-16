import 'dart:convert';

import 'package:flutter/material.dart';

class Node {
  int height=0;
  int responseCode = 500;
  String? host;
  bool? isActive;
  int? port;
  int? majorVersion;
  int? levinPort;
  bool? favourite;
  num syncBlock = 0;
  String? username;
  String? password;
  String? proxyServer;
  String? proxyPort;
  String status = "disconnected";
  String connectionError = "";

  Node(
      {required this.height,
      this.host,
      this.port,
      this.majorVersion,
      this.levinPort,
      this.favourite,
      this.username,
      this.password});

  Node.fromJson(Map json) {
    try {
      height = json['height'] ?? 0;
      isActive = json['isActive'] ?? false;
      status = json['status'] ?? "disconnected";
      connectionError = json['connection_error'] ?? "";
      responseCode = json['responseCode'] ?? 1000;
      host = json['host'];
      port = json['rpcPort'];
      majorVersion = json['majorVersion'];
      levinPort = json['levinPort'];
      syncBlock = json['syncBlock'] ?? 0;
      favourite = json['favourite'];
      username = json['username'];
      password = json['password'];
      proxyServer = json['proxyServer'];
      proxyPort= json['proxyPort'];
    } catch (e, s) {
      debugPrintStack(stackTrace: s);
    }
  }

  bool isConnecting() {
    return status == "connecting";
  }

  bool isConnected() {
    return status == "connected";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['height'] = height;
    data['responseCode'] = responseCode;
    data['host'] = host;
    data['port'] = port;
    data['majorVersion'] = majorVersion;
    data['levinPort'] = levinPort;
    data['levinPort'] = levinPort;
    data['favourite'] = favourite;
    data['username'] = username;
    data['password'] = password;
    return data;
  }
}
