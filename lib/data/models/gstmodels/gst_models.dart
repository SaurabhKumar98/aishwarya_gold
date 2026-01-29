// To parse this JSON data, do
//
//     final gstModels = gstModelsFromJson(jsonString);

import 'dart:convert';

GstModels gstModelsFromJson(String str) => GstModels.fromJson(json.decode(str));

String gstModelsToJson(GstModels data) => json.encode(data.toJson());

class GstModels {
  bool? success;
  String? message;
  GstData? data;
  dynamic meta;

  GstModels({
    this.success,
    this.message,
    this.data,
    this.meta,
  });

  factory GstModels.fromJson(Map<String, dynamic> json) => GstModels(
        success: json["success"] ?? false,
        message: json["message"] ?? '',
        data: json["data"] != null ? GstData.fromJson(json["data"]) : null,
        meta: json["meta"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data?.toJson(),
        "meta": meta,
      };
}

class GstData {
  String? id;
  int? v;
  DateTime? createdAt;
  bool? isActive;
  int? percentage;
  DateTime? updatedAt;

  GstData({
    this.id,
    this.v,
    this.createdAt,
    this.isActive,
    this.percentage,
    this.updatedAt,
  });

  factory GstData.fromJson(Map<String, dynamic> json) => GstData(
        id: json["_id"] ?? '',
        v: json["__v"] ?? 0,
        createdAt: json["createdAt"] != null
            ? DateTime.tryParse(json["createdAt"])
            : null,
        isActive: json["isActive"] ?? false,
        percentage: json["percentage"] ?? 0,
        updatedAt: json["updatedAt"] != null
            ? DateTime.tryParse(json["updatedAt"])
            : null,
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "__v": v,
        "createdAt": createdAt?.toIso8601String(),
        "isActive": isActive,
        "percentage": percentage,
        "updatedAt": updatedAt?.toIso8601String(),
      };
}
