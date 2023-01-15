class AnonBackupModel {
  NodeBackupModel? node;
  WalletBackupModel? wallet;
  Meta? meta;

  AnonBackupModel({this.node, this.wallet, this.meta});

  AnonBackupModel.fromJson(Map<String, dynamic> json) {
    node = json['node'] != null ? NodeBackupModel.fromJson(json['node']) : null;
    wallet = json['wallet'] != null
        ? WalletBackupModel.fromJson(json['wallet'])
        : null;
    meta = json['meta'] != null ? Meta.fromJson(json['meta']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (node != null) {
      data['node'] = node!.toJson();
    }
    if (wallet != null) {
      data['wallet'] = wallet!.toJson();
    }
    if (meta != null) {
      data['meta'] = meta!.toJson();
    }
    return data;
  }
}

class NodeBackupModel {
  String? host;
  String? password;
  String? username;
  int? rpcPort;
  String? networkType;
  bool? isOnion;

  NodeBackupModel(
      {this.host,
      this.password,
      this.username,
      this.rpcPort,
      this.networkType,
      this.isOnion});

  NodeBackupModel.fromJson(Map<String, dynamic> json) {
    host = json['host'];
    password = json['password'];
    username = json['username'];
    rpcPort = json['rpcPort'];
    networkType = json['networkType'];
    isOnion = json['isOnion'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['host'] = this.host;
    data['password'] = this.password;
    data['username'] = this.username;
    data['rpcPort'] = this.rpcPort;
    data['networkType'] = this.networkType;
    data['isOnion'] = this.isOnion;
    return data;
  }
}

class WalletBackupModel {
  String? address;
  String? seed;
  int? restoreHeight;
  int? balanceAll;
  int? numSubaddresses;
  int? numAccounts;
  bool? isWatchOnly;
  bool? isSynchronized;

  WalletBackupModel(
      {this.address,
      this.seed,
      this.restoreHeight,
      this.balanceAll,
      this.numSubaddresses,
      this.numAccounts,
      this.isWatchOnly,
      this.isSynchronized});

  WalletBackupModel.fromJson(Map<String, dynamic> json) {
    address = json['address'];
    seed = json['seed'];
    restoreHeight = json['restoreHeight'];
    balanceAll = json['balanceAll'];
    numSubaddresses = json['numSubaddresses'];
    numAccounts = json['numAccounts'];
    isWatchOnly = json['isWatchOnly'];
    isSynchronized = json['isSynchronized'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['address'] = this.address;
    data['seed'] = this.seed;
    data['restoreHeight'] = this.restoreHeight;
    data['balanceAll'] = this.balanceAll;
    data['numSubaddresses'] = this.numSubaddresses;
    data['numAccounts'] = this.numAccounts;
    data['isWatchOnly'] = this.isWatchOnly;
    data['isSynchronized'] = this.isSynchronized;
    return data;
  }
}

class Meta {
  int? timestamp;
  String? network;

  Meta({this.timestamp, this.network});

  Meta.fromJson(Map<String, dynamic> json) {
    timestamp = json['timestamp'];
    network = json['network'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['timestamp'] = this.timestamp;
    data['network'] = this.network;
    return data;
  }
}
