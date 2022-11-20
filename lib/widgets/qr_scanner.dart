import 'package:anon_wallet/plugins/camera_view.dart';
import 'package:anon_wallet/utils/app_haptics.dart';
import 'package:flutter/material.dart';

class QRScannerView extends StatefulWidget {
  final Function(String value) onScanCallback;

  const QRScannerView({Key? key, required this.onScanCallback})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRScannerViewState();
}

class _QRScannerViewState extends State<QRScannerView> {
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
      callBack: (value) {
        AppHaptics.lightImpact();
        Navigator.pop(context);
        widget.onScanCallback(value);
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
