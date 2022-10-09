import 'dart:async';
import 'dart:collection';

import 'package:anon_wallet/models/node.dart';
import 'package:anon_wallet/models/wallet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WalletEventsChannel {
  static const channel = EventChannel("wallet.events");
  late StreamSubscription _events;
  final StreamController<Node?> _nodeStream = StreamController<Node?>();
  final StreamController<Wallet?> _walletStream = StreamController<Wallet?>();
  final StreamController<bool> _walletOpenStateStream = StreamController<bool>();
  static final WalletEventsChannel _singleton = WalletEventsChannel._internal();

  Stream<Node?> nodeStream() {
    return _nodeStream.stream;
  }

  Stream<Wallet?> walletStream() {
    return _walletStream.stream;
  }


  Stream<bool> walletOpenStream() {
    return _walletOpenStateStream.stream;
  }

  WalletEventsChannel._internal() {
    _events = channel.receiveBroadcastStream().listen((event) {
      try {
        var type = event['EVENT_TYPE'];
        switch (type) {
          case "NODE":
            {
              _nodeStream.sink.add(Node.fromJson(event));
              break;
            }
          case "WALLET":
            {
              _walletStream.sink.add(Wallet.fromJson(event));
              break;
            }
          case "OPEN_WALLET":
            {
              bool isLoading = event['state'];
              _walletOpenStateStream.sink.add(isLoading);
              break;
            }
        }
      } catch (e) {
        print(e);
      }
    });
  }

  factory WalletEventsChannel() {
    return _singleton;
  }
}
