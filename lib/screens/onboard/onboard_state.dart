
import 'package:anon_wallet/channel/node_channel.dart';
import 'package:anon_wallet/channel/wallet_channel.dart';
import 'package:anon_wallet/models/node.dart';
import 'package:anon_wallet/models/wallet.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final newWalletProvider =
    StateNotifierProvider.autoDispose<CreateWalletState, Wallet?>((ref) {
  return CreateWalletState(ref);
});

final nodeConnectionProvider =
    StateNotifierProvider<ConnectToNodeState, Node?>((ref) {
  return ConnectToNodeState(ref);
});

final navigatorState = StateProvider<int>((ref) => 0);
final walletSeedPhraseProvider = StateProvider<String>((ref) => "");
final walletLockPin = StateProvider<String>((ref) => "");
final remoteHost = StateProvider<String>((ref) => "");
final remoteUserName = StateProvider<String>((ref) => "");
final remotePassword = StateProvider<String>((ref) => "");

final nextButtonValidation = Provider<bool>((ref) {
  int navState = ref.watch(navigatorState);
  String seedPhrase = ref.watch(walletSeedPhraseProvider);
  if (navState == 1) {
    return seedPhrase.isNotEmpty;
  }
  if(navState == 2){
    return false;
  }
  return true;
});

class CreateWalletState extends StateNotifier<Wallet?> {
  CreateWalletState(this.ref) : super(null);
  final Ref ref;

  Future createWallet(String pin) async {
    String seedPhrase = ref.read(walletSeedPhraseProvider);
    state = await WalletChannel().create(pin, seedPhrase);
    ref.read(navigatorState.state).state = 2;
  }
}

class ConnectToNodeState extends StateNotifier<Node?> {
  ConnectToNodeState(this.ref) : super(null);
  final Ref ref;

  Future connect() async {
    String host = ref.read(remoteHost);
    String? username = ref.read(remoteUserName);
    String? password = ref.read(remotePassword);
    int port = 28081;
    Uri uri = Uri.parse(host);
    if (uri.hasPort) {
      port = uri.port;
    }
    state = await NodeChannel().setNode(uri.host, port, username, password);
  }
}
