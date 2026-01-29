import 'dart:convert';

UpdateProfileModel updateProfileModelFromJson(String str) =>
    UpdateProfileModel.fromJson(json.decode(str));

String updateProfileModelToJson(UpdateProfileModel data) =>
    json.encode(data.toJson());

class UpdateProfileModel {
  final bool success;
  final String message;
  final dynamic data;
  final dynamic meta;

  UpdateProfileModel({
    required this.success,
    required this.message,
    this.data,
    this.meta,
  });

  factory UpdateProfileModel.fromJson(Map<String, dynamic> json) =>
      UpdateProfileModel(
        success: json["success"] ?? false,
        message: json["message"] ?? "",
        data: json["data"],
        meta: json["meta"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data,
        "meta": meta,
      };
}
class UserProfile {
  String name;
  String email;
  String? profilePath; // Local file path or image URL

  UserProfile({
    required this.name,
    required this.email,
    this.profilePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'profile': profilePath,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      profilePath: map['profile'],
    );
  }
}
