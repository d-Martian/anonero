import 'package:anon_wallet/state/wallet_state.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ReceiveWidget extends ConsumerWidget {
  final VoidCallback callback;

  const ReceiveWidget(this.callback, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    var subAddress = ref.watch(currentSubAddressProvider);
    var address = subAddress?.address ?? "";
    bool isWalletOpening = ref.watch(walletLoadingProvider) ?? true;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: BackButton(
          onPressed: callback,
        ),
      ),
      body: isWalletOpening ? const Center(child: CircularProgressIndicator()) : Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Padding(padding: EdgeInsets.all(8)),
            QrImage(
              backgroundColor: Colors.black,
              gapless: true,
              dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square),
              eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square),
              foregroundColor: Colors.white,
              data: address,
              version: QrVersions.auto,
              size: 280.0,
            ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              title: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  "${subAddress?.getLabel()} ",
                  style: Theme
                      .of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: Theme
                      .of(context)
                      .primaryColor),
                ),
              ),
              subtitle: SelectableText(
                address,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            )
          ],
        ),
      ),
    );
  }
}
