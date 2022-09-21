import 'dart:math';

import 'package:anon_wallet/channel/wallet_events_channel.dart';
import 'package:anon_wallet/models/node.dart';
import 'package:anon_wallet/models/wallet.dart';
import 'package:anon_wallet/state/wallet_state.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

enum NodeConnectionState { connected, disconnected }

final connectedNode = StateProvider<Node?>((ref) => null);
final nodeConnectionState = StreamProvider((ref) => WalletEventsChannel().nodeStream());
final connectingToNodeStateProvider = Provider<bool>((ref) {
  var connectionState = ref.watch(nodeConnectionState).value;
  if (connectionState != null) {
    return connectionState.isConnecting();
  } else {
    return false;
  }
});

final syncProgressStateProvider = Provider<Map<String,num>?>((ref) {
  var connectionState = ref.watch(nodeConnectionState).value;
  Wallet? wallet = ref.watch(walletStateStreamProvider).value;
  if (connectionState != null) {
    if (connectionState.syncBlock != 0 &&  connectionState.height != 0) {
      num blockChainHeight =   connectionState.height;
      num remaining = (blockChainHeight - connectionState.syncBlock ) ;
      num progress = connectionState.syncBlock / blockChainHeight;
      if(progress >= 1){
        return null;
      }
      return {
        "remaining" : remaining,
        "progress":progress
      };
    } else {
      return null;
    }
  } else {
    return null;
  }
});
final nodeSyncProgress = StateProvider<NodeConnectionState>((ref) => NodeConnectionState.disconnected);
