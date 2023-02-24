import 'package:flutter/services.dart';

class BackUpRestoreChannel {
  static const platform = MethodChannel('backup.channel');
  static final BackUpRestoreChannel _singleton =
      BackUpRestoreChannel._internal();

  BackUpRestoreChannel._internal();

  factory BackUpRestoreChannel() {
    return _singleton;
  }

  Future<bool> makeBackup(String password) async {
    bool value =
        await platform.invokeMethod("backup", {"seedPassphrase": password});
    return value;
  }

  Future<String> parseBackUp(String backupFileUri, String passPhrase) async {
    String value = await platform.invokeMethod("parseBackup",
        {"backupFileUri": backupFileUri, "passphrase": passPhrase});
    return value;
  }

  Future initiateRestore() async {
    await platform.invokeMethod("restore");
  }

  Future<String> openBackUpFile() async {
    String value = await platform.invokeMethod(
      "openBackupFile",
    );
    return value;
  }

  Future restoreFromSeed(
      String seed, int height, String passPhrase, String pin) async {
    return platform.invokeMethod("restoreFromSeed",
        {"seed": seed, "height": height, "pin": pin, "passPhrase": passPhrase});
  }
}
