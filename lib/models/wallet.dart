import 'dart:convert';

import 'package:anon_wallet/models/sub_address.dart';
import 'package:anon_wallet/models/transaction.dart';

class Wallet {
  String name = "";
  String seedLanguage = "";
  String connection = "";
  String connectionError = "";
  String pin = "";
  String address = "";
  String spendKey = "";
  String secretViewKey = "";
  String connectionStatus = "";
  bool isSynchronized = false;
  String status = "";
  num blockChainHeight = 0;
  num height = 0;
  num balance = 0;
  num unlockedBalance = 0;
  num numSubaddresses = 0;
  num restoreHeight = 0;
  List<String> seed = [];
  SubAddress? currentAddress;
  List<Transaction> transactions = [];

  Wallet();

  Wallet.fromJson(dynamic json) {
    name = json['name'] ?? "";
    seedLanguage = json['seedLanguage'] ?? "";
    address = json['address'] ?? "";
    secretViewKey = json['secretViewKey'] ?? "";
    restoreHeight = json['restoreHeight'] ?? 0;
    currentAddress = SubAddress.fromJson(json['currentAddress']);
    connectionStatus = json['connectionStatus'] ?? "";
    status = json['status'] ?? "";
    blockChainHeight = json['blockChainHeight'] ?? 0;
    connection = json['connection'] ?? "";
    connectionError = json['connectionError'] ?? "";
    isSynchronized = json['isSynchronized'] ?? false;
    balance = json['balance'] ?? 0;
    unlockedBalance = json['unlockedBalance'] ?? 0;
    numSubaddresses = json['numSubaddresses'] ?? 0;
    height = json['height'] ?? 0;
    if (json.containsKey("seed")) {
      seed = (json['seed'] as String).split(" ");
    }
    if (json.containsKey("spendKey")) {
      spendKey = (json['spendKey'] as String);
    }
    if (json.containsKey("transactions")) {
      json['transactions'].forEach((v) {
        transactions.add(Transaction.fromJson(v));
      });
    }
  }

  bool isConnected() {
    return connection.contains("ConnectionStatus_Connected");
  }
}
