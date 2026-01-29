// To parse this JSON data, do
//
//     final profileDetailModels = profileDetailModelsFromJson(jsonString);

import 'dart:convert';

ProfileDetailModels profileDetailModelsFromJson(String str) =>
    ProfileDetailModels.fromJson(json.decode(str));

String profileDetailModelsToJson(ProfileDetailModels data) =>
    json.encode(data.toJson());

class ProfileDetailModels {
  bool? success;
  String? message;
  ProfileDet? data;
  dynamic meta;

  ProfileDetailModels({
    this.success,
    this.message,
    this.data,
    this.meta,
  });

  factory ProfileDetailModels.fromJson(Map<String, dynamic> json) =>
      ProfileDetailModels(
        success: json["success"] ?? false,
        message: json["message"] ?? '',
        data: json["data"] != null ? ProfileDet.fromJson(json["data"]) : null,
        meta: json["meta"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data?.toJson(),
        "meta": meta,
      };
}

class ProfileDet {
  String? id;
  String? name;
  String? phone;
  String? email;
  String? pin;
  List<dynamic>? pancard;
  String? aadharcard;
  String? profile;
  DateTime? createdAt;
  int? v;
  String? refreshToken;
  String? kycStatus;

  ProfileDet({
    this.id,
    this.name,
    this.phone,
    this.email,
    this.pin,
    this.pancard,
    this.aadharcard,
    this.profile,
    this.createdAt,
    this.v,
    this.refreshToken,
    this.kycStatus,
  });

  factory ProfileDet.fromJson(Map<String, dynamic> json) => ProfileDet(
        id: json["_id"] ?? '',
        name: json["name"] ?? '',
        phone: json["phone"] ?? '',
        email: json["email"] ?? '',
        pin: json["pin"] ?? '',
        pancard: json["pancard"] != null
            ? List<dynamic>.from(json["pancard"].map((x) => x))
            : [],
        aadharcard: json["Aadharcard"] ?? '',
        profile: json["profile"] ?? '',
        createdAt: json["createdAt"] != null
            ? DateTime.tryParse(json["createdAt"])
            : null,
        v: json["__v"] ?? 0,
        refreshToken: json["refreshToken"] ?? '',
        kycStatus: json["kycStatus"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "phone": phone,
        "email": email,
        "pin": pin,
        "pancard": pancard != null
            ? List<dynamic>.from(pancard!.map((x) => x))
            : [],
        "Aadharcard": aadharcard,
        "profile": profile,
        "createdAt": createdAt?.toIso8601String(),
        "__v": v,
        "refreshToken": refreshToken,
        "kycStatus": kycStatus,
      };
}
