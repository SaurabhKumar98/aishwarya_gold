// To parse this JSON data, do
//
//     final redemptionStatusModels = redemptionStatusModelsFromJson(jsonString);

import 'dart:convert';

RedemptionStatusModels redemptionStatusModelsFromJson(String str) =>
    RedemptionStatusModels.fromJson(json.decode(str));

String redemptionStatusModelsToJson(RedemptionStatusModels data) =>
    json.encode(data.toJson());

class RedemptionStatusModels {
  bool success;
  String message;
  Data? data;
  dynamic meta;

  RedemptionStatusModels({
    required this.success,
    required this.message,
    this.data,
    this.meta,
  });

  factory RedemptionStatusModels.fromJson(Map<String, dynamic> json) =>
      RedemptionStatusModels(
        success: json["success"] ?? false,
        message: json["message"] ?? '',
        data: json["data"] != null ? Data.fromJson(json["data"]) : null,
        meta: json["meta"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data?.toJson(),
        "meta": meta,
      };
}

class Data {
  String? id;
  String? userId;
  StoreId? storeId;
  String? planId;
  String? planType;
  String? status;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;
  PlanDetails? planDetails;

  Data({
    this.id,
    this.userId,
    this.storeId,
    this.planId,
    this.planType,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.planDetails,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: json["_id"] ?? '',
        userId: json["userId"] ?? '',
        storeId:
            json["storeId"] != null ? StoreId.fromJson(json["storeId"]) : null,
        planId: json["planId"] ?? '',
        planType: json["planType"] ?? '',
        status: json["status"] ?? '',
        createdAt: json["createdAt"] != null
            ? DateTime.tryParse(json["createdAt"])
            : null,
        updatedAt: json["updatedAt"] != null
            ? DateTime.tryParse(json["updatedAt"])
            : null,
        v: json["__v"] ?? 0,
        planDetails: json["planDetails"] != null
            ? PlanDetails.fromJson(json["planDetails"])
            : null,
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "userId": userId,
        "storeId": storeId?.toJson(),
        "planId": planId,
        "planType": planType,
        "status": status,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
        "planDetails": planDetails?.toJson(),
      };
}

class PlanDetails {
  String? id;
  String? userId;
  double? goldQty;
  double? totalAmountToPay;
  double? gstAmount;
  double? discountAmount;
  double? amountPaid;
  double? currentDayGoldPrice;
  String? redeemCode;
  String? status;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;

  PlanDetails({
    this.id,
    this.userId,
    this.goldQty,
    this.totalAmountToPay,
    this.gstAmount,
    this.discountAmount,
    this.amountPaid,
    this.currentDayGoldPrice,
    this.redeemCode,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory PlanDetails.fromJson(Map<String, dynamic> json) => PlanDetails(
        id: json["_id"] ?? '',
        userId: json["userId"] ?? '',
        goldQty: (json["goldQty"] as num?)?.toDouble(),
        totalAmountToPay: (json["totalAmountToPay"] as num?)?.toDouble(),
        gstAmount: (json["gstAmount"] as num?)?.toDouble(),
        discountAmount: (json["discountAmount"] as num?)?.toDouble(),
        amountPaid: (json["amountPaid"] as num?)?.toDouble(),
        currentDayGoldPrice:
            (json["currentDayGoldPrice"] as num?)?.toDouble(),
        redeemCode: json["redeemCode"] ?? '',
        status: json["status"] ?? '',
        createdAt: json["createdAt"] != null
            ? DateTime.tryParse(json["createdAt"])
            : null,
        updatedAt: json["updatedAt"] != null
            ? DateTime.tryParse(json["updatedAt"])
            : null,
        v: json["__v"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "userId": userId,
        "goldQty": goldQty,
        "totalAmountToPay": totalAmountToPay,
        "gstAmount": gstAmount,
        "discountAmount": discountAmount,
        "amountPaid": amountPaid,
        "currentDayGoldPrice": currentDayGoldPrice,
        "redeemCode": redeemCode,
        "status": status,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
      };
}

class StoreId {
  String? id;
  String? storeId;
  String? name;
  String? location;
  String? map;
  String? number;
  String? status;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;
  String? storeImage;

  StoreId({
    this.id,
    this.storeId,
    this.name,
    this.location,
    this.map,
    this.number,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.storeImage,
  });

  factory StoreId.fromJson(Map<String, dynamic> json) => StoreId(
        id: json["_id"] ?? '',
        storeId: json["storeId"] ?? '',
        name: json["name"] ?? '',
        location: json["location"] ?? '',
        map: json["map"] ?? '',
        number: json["number"] ?? '',
        status: json["status"] ?? '',
        createdAt: json["createdAt"] != null
            ? DateTime.tryParse(json["createdAt"])
            : null,
        updatedAt: json["updatedAt"] != null
            ? DateTime.tryParse(json["updatedAt"])
            : null,
        v: json["__v"] ?? 0,
        storeImage: json["storeImage"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "storeId": storeId,
        "name": name,
        "location": location,
        "map": map,
        "number": number,
        "status": status,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
        "storeImage": storeImage,
      };
}
