class TxState {
  String? errorString ="";
  int? fee;
  int? amount;
  int? txCount;
  String? txId;
  String? status;

  //Shows tx states preview,waiting,success
  String state = "preview";

  TxState();

  TxState.fromJson(dynamic json) {
    errorString = json['errorString'];
    fee = json['fee'];
    amount = json['amount'];
    txId = json['txId'];
    status = json['status'];
    txCount = json['txCount'];
    state = json['state'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['errorString'] = errorString;
    data['fee'] = fee;
    data['amount'] = amount;
    data['txId'] = txId;
    data['state'] = state;
    return data;
  }

  bool isLoading() {
    return state == "waiting";
  }

  bool hasError() {
    return errorString?.isNotEmpty ?? false;
  }

  bool isSuccess() {
    return state == "success";
  }
}
