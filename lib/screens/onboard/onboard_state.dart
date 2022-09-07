import 'package:anon_wallet/channel/wallet_channel.dart';
import 'package:anon_wallet/models/wallet.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final newWalletProvider = StateNotifierProvider.autoDispose<CreateWalletState, Wallet?>((ref) {
  return CreateWalletState(ref);
});

final navigatorState = StateProvider<int>((ref) => 0);
final walletSeedPhraseProvider = StateProvider<String>((ref) => "");
final walletLockPin = StateProvider.autoDispose<String>((ref) => "");

final nextButtonValidation = Provider<bool>((ref) {
  int navState = ref.watch(navigatorState);
  String seedPhrase = ref.watch(walletSeedPhraseProvider);
  if (navState == 1) {
    return seedPhrase.isNotEmpty;
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
