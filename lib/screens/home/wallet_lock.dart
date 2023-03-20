import 'package:anon_wallet/channel/wallet_channel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';


final walletLockProvider = FutureProvider((ref) => WalletChannel().lock());

class WalletLock extends ConsumerWidget {
  const WalletLock({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lockAsync  = ref.watch(walletLockProvider);

    return Scaffold(
      body: Center(
        child:lockAsync.isLoading ?  Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Hero(
                  tag: "lock",
                  child: Icon(Icons.lock,
                      size: (MediaQuery
                          .of(context)
                          .size
                          .width / 3.5)),
                ),
                const SizedBox(
                  width: 180,
                  height: 180,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              ],
            ),
             Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("Closing wallet",style: Theme.of(context).textTheme.caption?.copyWith(fontSize: 11),),
            )
          ],
        ) : lockAsync.error != null ? Text(
          "${(lockAsync.error as PlatformException).message}",
        ) : const Icon(Icons.check_circle_outline_sharp),
      ),
    );
  }
}
