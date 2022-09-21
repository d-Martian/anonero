import 'package:anon_wallet/state/wallet_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ReceiveWidget extends ConsumerWidget {
  const ReceiveWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    var address = ref.watch(walletAddressProvider);

    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Address",style: Theme.of(context).textTheme.headline6),
            const Padding(padding: EdgeInsets.all(8)),
            SelectableText(address)
          ],
        ),
      ),
    );
  }
}
