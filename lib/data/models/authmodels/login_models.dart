import 'dart:convert';

LoginModel loginModelFromJson(String str) => LoginModel.fromJson(json.decode(str));

String loginModelToJson(LoginModel data) => json.encode(data.toJson());

class LoginModel {
  bool? success;
  String? message;
  Data? data;
  dynamic meta;

  LoginModel({
    this.success,
    this.message,
    this.data,
    this.meta,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) => LoginModel(
        success: json["success"] ?? false,
        message: json["message"] ?? "",
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
  String? otp;

  Data({
    this.otp,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        otp: json["otp"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "otp": otp,
      };
}
