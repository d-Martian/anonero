import 'package:anon_wallet/channel/spend_channel.dart';
import 'package:anon_wallet/models/broadcast_tx_state.dart';
import 'package:anon_wallet/utils/app_haptics.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SpendValidationNotifier extends ChangeNotifier {
  bool? validAddress;
  bool? validAmount;

  Future<bool> validate(String amount, String address) async {
    dynamic response =
        await SpendMethodChannel().validateAddress(amount, address);
    validAddress = response['address'] == true;
    validAmount = response['amount'] == true;
    notifyListeners();
    return validAddress == true && validAmount == true;
  }

  clear() {
    validAddress = null;
    validAmount = null;
    notifyListeners();
  }
}

class TransactionStateNotifier extends StateNotifier<TxState> {
  TransactionStateNotifier() : super(TxState());

  createPreview(String amount, String address, String notes) async {
    var broadcastState = TxState();
    broadcastState.state = "waiting";
    state = broadcastState;
    try {
      var returnValue =
          await SpendMethodChannel().compose(amount, address, notes);
      state = TxState.fromJson(returnValue);
    } catch (e, s) {
      debugPrintStack(stackTrace: s);
      print(e);
    }
  }

  broadcast(String amount, String address, String notes) async {
    var broadcastState = TxState();
    broadcastState.state = "waiting";
    state = broadcastState;
    var returnValue =
        await SpendMethodChannel().composeAndBroadcast(amount, address, notes);
    state = TxState.fromJson(returnValue);
    AppHaptics.mediumImpact();
  }
}

final transactionStateProvider =
    StateNotifierProvider<TransactionStateNotifier, TxState>(
        (ref) => TransactionStateNotifier());

final validationProvider =
    ChangeNotifierProvider((ref) => SpendValidationNotifier());

final addressStateProvider = StateProvider((ref) => "");
final amountStateProvider = StateProvider((ref) => "");
final notesStateProvider = StateProvider((ref) => "");
