// To parse this JSON data, do
//
// final refferAndEarn = refferAndEarnFromJson(jsonString);

import 'dart:convert';

RefferAndEarn refferAndEarnFromJson(String str) =>
    RefferAndEarn.fromJson(json.decode(str));

String refferAndEarnToJson(RefferAndEarn data) =>
    json.encode(data.toJson());

class RefferAndEarn {
  bool success;
  String message;
  RefferData? data;
  dynamic meta;

  RefferAndEarn({
    required this.success,
    required this.message,
    this.data,
    this.meta,
  });

  factory RefferAndEarn.fromJson(Map<String, dynamic> json) {
    return RefferAndEarn(
      success: json["success"] ?? false,
      message: json["message"] ?? '',
      data: json["data"] != null
          ? RefferData.fromJson(json["data"])
          : null,
      meta: json["meta"],
    );
  }

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data?.toJson(),
        "meta": meta,
      };
}

class RefferData {
  String id;
  double walletBalance;
  String referralCode;

  RefferData({
    required this.id,
    required this.walletBalance,
    required this.referralCode,
  });

  factory RefferData.fromJson(Map<String, dynamic> json) {
    return RefferData(
      id: json["_id"] ?? '',
      walletBalance:
          (json["walletBalance"] as num?)?.toDouble() ?? 0.0,
      referralCode: json["referralCode"] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        "_id": id,
        "walletBalance": walletBalance,
        "referralCode": referralCode,
      };
}
