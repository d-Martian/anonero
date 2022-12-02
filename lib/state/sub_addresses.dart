import 'package:anon_wallet/channel/wallet_events_channel.dart';
import 'package:anon_wallet/models/sub_address.dart';
import 'package:anon_wallet/models/transaction.dart';
import 'package:anon_wallet/state/wallet_state.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final getSubAddressesProvider = StreamProvider<List<SubAddress>>(
    (ref) => WalletEventsChannel().subAddresses());
final subAddressStateProvider =
    StateProvider((ref) => ref.watch(getSubAddressesProvider).value);

final subAddressDetails =
    Provider.family<List<Transaction>, SubAddress>((ref, address) {
  List<Transaction> transactions = ref.watch(walletTransactions);
  List<Transaction> selectedTxs = [];
  for (var element in transactions) {
    if (element.subAddress != null && address.address != null) {
      if (address.address == element.subAddress!.address) {
        selectedTxs.add(element);
      }
    }
  }
  return selectedTxs;
});

final getSpecificSubAddress =
    Provider.family<SubAddress, SubAddress>((ref, address) {
  List<SubAddress>? subAddresses = ref.watch(subAddressStateProvider);
  if (subAddresses == null) {
    return address;
  } else {
    for (var element in subAddresses) {
      if (element.address == address.address) {
        return element;
      }
    }
  }
  return address;
});
