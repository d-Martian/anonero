import 'dart:convert';

import 'package:flutter/material.dart';

class SubAddress {
  int? accountIndex;
  String? address;
  String? squashedAddress;
  int? addressIndex;
  num? totalAmount;
  String? label;
  String? displayLabel;

  SubAddress({this.accountIndex, this.address, this.squashedAddress, this.addressIndex, this.label});

  SubAddress.fromJson(dynamic json) {
    print("SubAddress :: ${jsonEncode(json)}");
    try {
      accountIndex = json['accountIndex'];
      address = json['address'];
      squashedAddress = json['squashedAddress'];
      addressIndex = json['addressIndex'];
      totalAmount = json['totalAmount'];
      label = json['label'];
    } catch (e,s) {
      debugPrintStack(stackTrace: s);
      print(e);
    }
  }

  String getLabel() {
    if (label != null && label!.isNotEmpty) {
      return label!;
    } else {
      return "SUBADDRESS #$addressIndex";
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['accountIndex'] = accountIndex;
    data['address'] = address;
    data['squashedAddress'] = squashedAddress;
    data['addressIndex'] = addressIndex;
    data['label'] = label;
    return data;
  }
}

class SubAdress {
  int? accountIndex;
  String? address;
  String? squashedAddress;
  int? addressIndex;
  String? label;

  SubAdress({this.accountIndex, this.address, this.squashedAddress, this.addressIndex, this.label});

  SubAdress.fromJson(Map<String, dynamic> json) {
    accountIndex = json['accountIndex'];
    address = json['address'];
    squashedAddress = json['squashedAddress'];
    addressIndex = json['addressIndex'];
    label = json['label'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['accountIndex'] = this.accountIndex;
    data['address'] = this.address;
    data['squashedAddress'] = this.squashedAddress;
    data['addressIndex'] = this.addressIndex;
    data['label'] = this.label;
    return data;
  }
}
