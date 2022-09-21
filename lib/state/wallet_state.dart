import 'package:anon_wallet/channel/wallet_events_channel.dart';
import 'package:anon_wallet/models/wallet.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final walletStateStreamProvider = StreamProvider<Wallet?>((ref) => WalletEventsChannel().walletStream());

final walletAddressProvider = Provider((ref) {
  var walletAsync = ref.watch(walletStateStreamProvider);
  Wallet? wallet = walletAsync.value;
  return wallet != null ? wallet.address :  "";
});

final walletBalanceProvider = Provider((ref) {
  var walletAsync = ref.watch(walletStateStreamProvider);
  Wallet? wallet = walletAsync.value;
  if (wallet == null) {
    return 0;
  } else {
    return wallet.balance;
  }
});
