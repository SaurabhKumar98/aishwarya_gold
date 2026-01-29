

// To parse this JSON data, do
//
//     final redemptionRequestModel = redemptionRequestModelFromJson(jsonString);

import 'dart:convert';

RedemptionRequestModel redemptionRequestModelFromJson(String str) =>
    RedemptionRequestModel.fromJson(json.decode(str));

String redemptionRequestModelToJson(RedemptionRequestModel data) =>
    json.encode(data.toJson());

class RedemptionRequestModel {
  bool? success;
  String? message;
  RedemptionData? data;
  dynamic meta;

  RedemptionRequestModel({
    this.success,
    this.message,
    this.data,
    this.meta,
  });

  factory RedemptionRequestModel.fromJson(Map<String, dynamic> json) =>
      RedemptionRequestModel(
        success: json["success"] ?? false,
        message: json["message"] ?? "",
        data: json["data"] != null ? RedemptionData.fromJson(json["data"]) : null,
        meta: json["meta"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data?.toJson(),
        "meta": meta,
      };
}

class RedemptionData {
  String? userId;
  String? storeId;
  String? planId;
  String? planType;
  String? status;
  String? id;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;

  RedemptionData({
    this.userId,
    this.storeId,
    this.planId,
    this.planType,
    this.status,
    this.id,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory RedemptionData.fromJson(Map<String, dynamic> json) => RedemptionData(
        userId: json["userId"] ?? "",
        storeId: json["storeId"] ?? "",
        planId: json["planId"] ?? "",
        planType: json["planType"] ?? "",
        status: json["status"] ?? "",
        id: json["_id"] ?? "",
        createdAt: json["createdAt"] != null
            ? DateTime.tryParse(json["createdAt"])
            : null,
        updatedAt: json["updatedAt"] != null
            ? DateTime.tryParse(json["updatedAt"])
            : null,
        v: json["__v"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "userId": userId,
        "storeId": storeId,
        "planId": planId,
        "planType": planType,
        "status": status,
        "_id": id,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
      };
}
