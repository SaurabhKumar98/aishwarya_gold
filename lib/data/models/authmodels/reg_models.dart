// import 'dart:convert';

// // To parse this JSON data
// // final regModel = regModelFromJson(jsonString);

// RegModel regModelFromJson(String str) => RegModel.fromJson(json.decode(str));

// String regModelToJson(RegModel data) => json.encode(data.toJson());

// class RegModel {
//   bool? success;
//   String? message;
//   Data? data;
//   dynamic meta;

//   RegModel({
//     this.success,
//     this.message,
//     this.data,
//     this.meta,
//   });

//   factory RegModel.fromJson(Map<String, dynamic> json) => RegModel(
//         success: json["success"] ?? false,
//         message: json["message"] ?? "",
//         data: json["data"] != null ? Data.fromJson(json["data"]) : null,
//         meta: json["meta"],
//       );

//   Map<String, dynamic> toJson() => {
//         "success": success ?? false,
//         "message": message ?? "",
//         "data": data?.toJson(),
//         "meta": meta,
//       };
// }

// class Data {
//   User? user;

//   Data({this.user});

//   factory Data.fromJson(Map<String, dynamic> json) => Data(
//         user: json["user"] != null ? User.fromJson(json["user"]) : null,
//       );

//   Map<String, dynamic> toJson() => {
//         "user": user?.toJson(),
//       };
// }

// class User {
//   String? name;
//   String? phone;
//   String? email;
//   String? pin;
//   List<String>? pancard;
//   String? aadharcard;
//   String? profile;
//   String? refreshToken;
//   String? id;
//   DateTime? createdAt;
//   int? v;

//   User({
//     this.name,
//     this.phone,
//     this.email,
//     this.pin,
//     this.pancard,
//     this.aadharcard,
//     this.profile,
//     this.refreshToken,
//     this.id,
//     this.createdAt,
//     this.v,
//   });

//   factory User.fromJson(Map<String, dynamic> json) => User(
//         name: json["name"],
//         phone: json["phone"],
//         email: json["email"],
//         pin: json["pin"],
//         pancard: json["pancard"] != null
//             ? List<String>.from(json["pancard"].map((x) => x.toString()))
//             : [],
//         aadharcard: json["Aadharcard"],
//         profile: json["profile"],
//         refreshToken: json["refreshToken"],
//         id: json["_id"],
//         createdAt: json["createdAt"] != null
//             ? DateTime.tryParse(json["createdAt"])
//             : null,
//         v: json["__v"],
//       );

//   Map<String, dynamic> toJson() => {
//         "name": name,
//         "phone": phone,
//         "email": email,
//         "pin": pin,
//         "pancard": pancard != null ? List<dynamic>.from(pancard!.map((x) => x)) : [],
//         "Aadharcard": aadharcard,
//         "profile": profile,
//         "refreshToken": refreshToken,
//         "_id": id,
//         "createdAt": createdAt?.toIso8601String(),
//         "__v": v,
//       };
// }
import 'dart:convert';

// To parse this JSON data
// final regModel = regModelFromJson(jsonString);

RegModel regModelFromJson(String str) => RegModel.fromJson(json.decode(str));

String regModelToJson(RegModel data) => json.encode(data.toJson());

class RegModel {
  bool? success;
  String? message;
  Data? data;
  dynamic meta;

  RegModel({
    this.success,
    this.message,
    this.data,
    this.meta,
  });

  factory RegModel.fromJson(Map<String, dynamic> json) => RegModel(
        success: json["success"] ?? false,
        message: json["message"] ?? "",
        data: json["data"] != null ? Data.fromJson(json["data"]) : null,
        meta: json["meta"],
      );

  Map<String, dynamic> toJson() => {
        "success": success ?? false,
        "message": message ?? "",
        "data": data?.toJson(),
        "meta": meta,
      };
}

class Data {
  User? user;

  Data({this.user});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        user: json["user"] != null ? User.fromJson(json["user"]) : null,
      );

  Map<String, dynamic> toJson() => {
        "user": user?.toJson(),
      };
}

class User {
  String? name;
  String? phone;
  String? email;
  String? pin;
  List<String>? pancard;
  String? aadharcard;
  String? profile;
  String? refreshToken;
  String? referralCode;
  String? id;
  DateTime? createdAt;
  int? v;

  User({
    this.name,
    this.phone,
    this.email,
    this.pin,
    this.pancard,
    this.aadharcard,
    this.profile,
    this.refreshToken,
    this.referralCode,
    this.id,
    this.createdAt,
    this.v,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        name: json["name"],
        phone: json["phone"],
        email: json["email"],
        pin: json["pin"],
        pancard: json["pancard"] != null
            ? List<String>.from(json["pancard"].map((x) => x.toString()))
            : [],
        aadharcard: json["Aadharcard"],
        profile: json["profile"],
        refreshToken: json["refreshToken"],
        referralCode: json["referralCode"],
        id: json["_id"],
        createdAt: json["createdAt"] != null
            ? DateTime.tryParse(json["createdAt"])
            : null,
        v: json["__v"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "phone": phone,
        "email": email,
        "pin": pin,
        "pancard": pancard != null ? List<dynamic>.from(pancard!.map((x) => x)) : [],
        "Aadharcard": aadharcard,
        "profile": profile,
        "refreshToken": refreshToken,
        "referralCode":referralCode,
        "_id": id,
        "createdAt": createdAt?.toIso8601String(),
        "__v": v,
      };
}