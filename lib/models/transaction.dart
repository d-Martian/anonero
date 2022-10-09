
import 'package:flutter/material.dart';

class Transaction {
  String? displayLabel;
  String? subaddressLabel;
  String? address;
  String? notes;
  int? fee;
  int? confirmations;
  bool isPending = false;
  int? blockheight;
  int? accountIndex;
  String? paymentId;
  num? amount = 0;
  int? timeStamp;
  int? addressIndex;
  bool? isConfirmed;
  String? hash;

  Transaction(
      {this.displayLabel,
      this.subaddressLabel,
      this.address,
      this.notes,
      this.fee,
      this.confirmations,
      required this.isPending,
      this.blockheight,
      this.accountIndex,
      this.paymentId,
      this.addressIndex,
      this.isConfirmed,
      this.hash});

  Transaction.fromJson(Map json) {
    try {
      displayLabel = json['displayLabel'];
      subaddressLabel = json['subaddressLabel'];
      address = json['address'];
      notes = json['notes'];
      fee = json['fee'];
      confirmations = json['confirmations'];
      isPending = json['isPending'] ?? true;
      blockheight = json['blockheight'];
      amount = json['amount'] ?? 0;
      accountIndex = json['accountIndex'];
      timeStamp = json['timestamp'];
      paymentId = json['paymentId'];
      addressIndex = json['addressIndex'];
      isConfirmed = json['isConfirmed'];
      hash = json['hash'];
    } catch (e,s) {
      debugPrintStack(stackTrace: s);
      print(e);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['displayLabel'] = displayLabel;
    data['subaddressLabel'] = subaddressLabel;
    data['address'] = address;
    data['notes'] = notes;
    data['fee'] = fee;
    data['confirmations'] = confirmations;
    data['isPending'] = isPending;
    data['blockheight'] = blockheight;
    data['amount'] = amount;
    data['accountIndex'] = accountIndex;
    data['paymentId'] = paymentId;
    data['addressIndex'] = addressIndex;
    data['isConfirmed'] = isConfirmed;
    data['hash'] = hash;
    return data;
  }
}
