import 'package:anon_wallet/channel/wallet_events_channel.dart';
import 'package:anon_wallet/models/sub_address.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final getSubAddressesProvider =  StreamProvider<List<SubAddress>>((ref) => WalletEventsChannel().subAddresses());