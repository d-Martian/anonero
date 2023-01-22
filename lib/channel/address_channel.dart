import 'package:flutter/services.dart';

class AddressChannel {
  static const platform = MethodChannel('address.channel');
  static final AddressChannel _singleton = AddressChannel._internal();

  AddressChannel._internal();

  factory AddressChannel() {
    return _singleton;
  }

  Future getSubAddresses() async {
    await platform.invokeMethod("getSubAddresses");
  }

  Future openBackupFile() async {
    await platform.invokeMethod("openBackupFile");
  }

  Future setSubAddressLabel(
      int addressIndex, int accountIndex, String label) async {
    await platform.invokeMethod("renameAddress", {
      "label": label,
      "addressIndex": addressIndex,
      "accountIndex": accountIndex,
    });
    return true;
  }
}
