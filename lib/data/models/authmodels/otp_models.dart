// import 'dart:convert';

// OtpModel otpModelFromJson(String str) => OtpModel.fromJson(json.decode(str));

// String otpModelToJson(OtpModel data) => json.encode(data.toJson());

// class OtpModel {
//   bool success;
//   String? message;
//   Data? data;
//   dynamic meta;

//   OtpModel({
//     required this.success,
//     this.message,
//     this.data,
//     this.meta,
//   });

//   factory OtpModel.fromJson(Map<String, dynamic> json) => OtpModel(
//         success: json["success"] ?? false,
//         message: json["message"],
//         data: json["data"] != null ? Data.fromJson(json["data"]) : null,
//         meta: json["meta"],
//       );

//   Map<String, dynamic> toJson() => {
//         "success": success,
//         "message": message,
//         "data": data?.toJson(),
//         "meta": meta,
//       };
// }

// class Data {
//   User? user;
//   String? accessToken;
//   String? refreshToken;

//   Data({
//     this.user,
//     this.accessToken,
//     this.refreshToken,
//   });

//   factory Data.fromJson(Map<String, dynamic> json) => Data(
//         user: json["user"] != null ? User.fromJson(json["user"]) : null,
//         accessToken: json["accessToken"],
//         refreshToken: json["refreshToken"],
//       );

//   Map<String, dynamic> toJson() => {
//         "user": user?.toJson(),
//         "accessToken": accessToken,
//         "refreshToken": refreshToken,
//       };

//   void operator [](String other) {}
// }

// class User {
//   String? id;
//   String? name;
//   String? phone;
//   String? email;
//   String? pin;
//   List<dynamic>? pancard;
//   String? aadharcard;
//   String? profile;
//   DateTime? createdAt;
//   int? v;
//   String? refreshToken;

//   User({
//     this.id,
//     this.name,
//     this.phone,
//     this.email,
//     this.pin,
//     this.pancard,
//     this.aadharcard,
//     this.profile,
//     this.createdAt,
//     this.v,
//     this.refreshToken,
//   });

//   factory User.fromJson(Map<String, dynamic> json) => User(
//         id: json["_id"],
//         name: json["name"],
//         phone: json["phone"],
//         email: json["email"],
//         pin: json["pin"],
//         pancard: json["pancard"] != null ? List<dynamic>.from(json["pancard"]) : [],
//         aadharcard: json["Aadharcard"],
//         profile: json["profile"],
//         createdAt: json["createdAt"] != null ? DateTime.parse(json["createdAt"]) : null,
//         v: json["__v"],
//         refreshToken: json["refreshToken"],
//       );

//   Map<String, dynamic> toJson() => {
//         "_id": id,
//         "name": name,
//         "phone": phone,
//         "email": email,
//         "pin": pin,
//         "pancard": pancard != null ? List<dynamic>.from(pancard!) : [],
//         "Aadharcard": aadharcard,
//         "profile": profile,
//         "createdAt": createdAt?.toIso8601String(),
//         "__v": v,
//         "refreshToken": refreshToken,
//       };
// }
import 'dart:convert';

OtpModel otpModelFromJson(String str) => OtpModel.fromJson(json.decode(str));

String otpModelToJson(OtpModel data) => json.encode(data.toJson());

class OtpModel {
  bool success;
  String? message;
  Data? data;
  dynamic meta;

  OtpModel({
    required this.success,
    this.message,
    this.data,
    this.meta,
  });

  factory OtpModel.fromJson(Map<String, dynamic> json) => OtpModel(
        success: json["success"] ?? false,
        message: json["message"],
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
  User? user;
  String? accessToken;
  String? refreshToken;

  Data({
    this.user,
    this.accessToken,
    this.refreshToken,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        user: json["user"] != null ? User.fromJson(json["user"]) : null,
        accessToken: json["accessToken"],
        refreshToken: json["refreshToken"],
      );

  Map<String, dynamic> toJson() => {
        "user": user?.toJson(),
        "accessToken": accessToken,
        "refreshToken": refreshToken,
      };
}

class User {
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

  User({
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
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["_id"],
        name: json["name"],
        phone: json["phone"],
        email: json["email"],
        pin: json["pin"],
        pancard: json["pancard"] != null ? List<dynamic>.from(json["pancard"]) : [],
        aadharcard: json["Aadharcard"],
        profile: json["profile"],
        createdAt: json["createdAt"] != null ? DateTime.parse(json["createdAt"]) : null,
        v: json["__v"],
        refreshToken: json["refreshToken"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "phone": phone,
        "email": email,
        "pin": pin,
        "pancard": pancard != null ? List<dynamic>.from(pancard!) : [],
        "Aadharcard": aadharcard,
        "profile": profile,
        "createdAt": createdAt?.toIso8601String(),
        "__v": v,
        "refreshToken": refreshToken,
      };
}