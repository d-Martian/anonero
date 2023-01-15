import 'package:flutter/services.dart';

class BackUpRestoreChannel {
  static const platform = MethodChannel('backup.channel');
  static final BackUpRestoreChannel _singleton =
      BackUpRestoreChannel._internal();

  BackUpRestoreChannel._internal();

  factory BackUpRestoreChannel() {
    return _singleton;
  }

  Future<String> getBackUp(String password) async {
    String value =
        await platform.invokeMethod("backup", {"seedPassphrase": password});
    return value;
  }

  Future<String> parseBackUp(String backup, String passPhrase) async {
    String value = await platform.invokeMethod(
        "parseBackup", {"backup": backup, "passphrase": passPhrase});
    return value;
  }

  Future<String> initiateRestore(String pin) async {
    String value = await platform.invokeMethod("restore", {"pin": pin});
    return value;
  }

  Future<String> openBackUpFile() async {
    String value = await platform.invokeMethod(
      "openBackupFile",
    );
    return value;
  }

  Future<String> shareBackUpAsFile(String backup) async {
    String value =
        await platform.invokeMethod("shareToFile", {"backup": backup});
    return value;
  }
}
