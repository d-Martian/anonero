import 'package:anon_wallet/plugins/camera_view.dart';
import 'package:anon_wallet/screens/home/spend/spend_state.dart';
import 'package:anon_wallet/utils/app_haptics.dart';
import 'package:anon_wallet/utils/parsers.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class QRScannerView extends StatefulWidget {
  final Function(String value) onScanCallback;

  const QRScannerView({Key? key, required this.onScanCallback})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRScannerViewState();
}

class _QRScannerViewState extends State<QRScannerView> {
  bool isScanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterDocked,
      floatingActionButton: FloatingActionButton.extended(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8))),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        splashColor: Theme.of(context).primaryColor,
        onPressed: () {
          Navigator.pop(context);
        },
        label: const Text("Close"),
        icon: const Icon(Icons.close),
      ),
      body: _buildQrView(context),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    return CameraView(
      callBack: (value) async {
        if (!isScanned) {
          AppHaptics.lightImpact();
          widget.onScanCallback(value);
          Navigator.pop(context,value);
          isScanned = true;
        }
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

PersistentBottomSheetController showQRBottomSheet(BuildContext context, {Function(String value)? onScanCallback = null}) {
  return showBottomSheet(
      context: context,
      builder: (context) {
        return Consumer(
          builder: (context, ref, c) {
            return QRScannerView(
              onScanCallback: (value) {
                onScanCallback?.call(value);
                AppHaptics.lightImpact();
                var parsedAddress = Parser.parseAddress(value);
                if (parsedAddress[0] != null) {
                  ref.read(addressStateProvider.state).state = parsedAddress[0];
                }
                if (parsedAddress[1] != null) {
                  ref.read(amountStateProvider.state).state = parsedAddress[1];
                }
                if (parsedAddress[2] != null) {
                  ref.read(notesStateProvider.state).state = parsedAddress[2];
                }
              },
            );
          },
        );
      });
}
