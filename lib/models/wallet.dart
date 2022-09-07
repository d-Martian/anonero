class Wallet {
  String name = "";
  String seedLanguage = "";
  String pin = "";
  String address = "";
  String secretViewKey = "";
  num restoreHeight = 0;
  List<String> seed = [];

  Wallet();

  Wallet.fromJson(Map<dynamic, dynamic> json) {
    name = json['name'] ?? "";
    seedLanguage = json['seedLanguage'] ?? "";
    address = json['address'] ?? "";
    secretViewKey = json['secretViewKey'] ?? "";
    restoreHeight = json['restoreHeight'] ?? "";
    if (json.containsKey("seed")) {
      seed = (json['seed'] as String).split(" ");
    }
  }

}
