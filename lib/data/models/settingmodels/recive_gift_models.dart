import 'dart:convert';

ReciveGiftModels reciveGiftModelsFromJson(String str) =>
    ReciveGiftModels.fromJson(json.decode(str));

String reciveGiftModelsToJson(ReciveGiftModels data) =>
    json.encode(data.toJson());

class ReciveGiftModels {
  bool? success;
  String? message;
  List<GiftData>? data;
  dynamic meta;

  ReciveGiftModels({
    this.success,
    this.message,
    this.data,
    this.meta,
  });

  factory ReciveGiftModels.fromJson(Map<String, dynamic> json) =>
      ReciveGiftModels(
        success: json["success"] ?? false,
        message: json["message"] ?? "",
        data: json["data"] == null
            ? []
            : List<GiftData>.from(
                json["data"].map((x) => GiftData.fromJson(x))),
        meta: json["meta"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data?.map((x) => x.toJson()).toList() ?? [],
        "meta": meta,
      };
}

class GiftData {
  OtherDetails? otherDetails;
  String? id;
  int? giftValue;
  String? giftType;
  String? redeemCode;
  bool? isRedeemed;
  String? message;
  Creator? createdBy;
  String? giftFor;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;
  String? creatorName;

  GiftData({
    this.otherDetails,
    this.id,
    this.giftValue,
    this.giftType,
    this.redeemCode,
    this.isRedeemed,
    this.message,
    this.createdBy,
    this.giftFor,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.creatorName,
  });

  factory GiftData.fromJson(Map<String, dynamic> json) => GiftData(
        otherDetails: json["otherDetails"] != null
            ? OtherDetails.fromJson(json["otherDetails"])
            : null,
        id: json["_id"] ?? "",
        giftValue: json["giftValue"] ?? 0,
        giftType: json["giftType"] ?? "",
        redeemCode: json["redeemCode"] ?? "",
        isRedeemed: json["isRedeemed"] ?? false,
        message: json["message"] ?? "",
        createdBy: _parseCreatedBy(json["createdBy"]),
        giftFor: json["giftFor"] ?? "",
        createdAt: _parseDate(json["createdAt"]),
        updatedAt: _parseDate(json["updatedAt"]),
        v: json["__v"] ?? 0,
        creatorName: json["creatorName"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "otherDetails": otherDetails?.toJson(),
        "_id": id,
        "giftValue": giftValue,
        "giftType": giftType,
        "redeemCode": redeemCode,
        "isRedeemed": isRedeemed,
        "message": message,
        "createdBy": createdBy?.toJson(),
        "giftFor": giftFor,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
        "creatorName": creatorName,
      };
}

/// Handles "createdBy" which can be either an object or string
Creator? _parseCreatedBy(dynamic json) {
  if (json == null) return null;

  if (json is Map<String, dynamic>) {
    return Creator.fromJson(json);
  } else if (json is String) {
    // if only ID string is returned
    return Creator(id: json);
  }
  return null;
}

/// Creator model for "createdBy" field
class Creator {
  String? id;
  String? name;

  Creator({this.id, this.name});

  factory Creator.fromJson(Map<String, dynamic> json) => Creator(
        id: json["_id"] ?? "",
        name: json["name"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
      };
}

/// Nested user details
class OtherDetails {
  String? name;
  String? email;
  String? phone;

  OtherDetails({
    this.name,
    this.email,
    this.phone,
  });

  factory OtherDetails.fromJson(Map<String, dynamic> json) => OtherDetails(
        name: json["name"] ?? "",
        email: json["email"] ?? "",
        phone: json["phone"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "email": email,
        "phone": phone,
      };
}

/// Helper for safely parsing dates
DateTime? _parseDate(String? date) {
  if (date == null || date.isEmpty) return null;
  return DateTime.tryParse(date);
}
