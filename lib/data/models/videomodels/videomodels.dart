// To parse this JSON data, do
//
//     final videoModels = videoModelsFromJson(jsonString);

import 'dart:convert';

VideoModels videoModelsFromJson(String str) =>
    VideoModels.fromJson(json.decode(str));

String videoModelsToJson(VideoModels data) => json.encode(data.toJson());

class VideoModels {
  bool success;
  String message;
  List<Datum> data;
  dynamic meta;

  VideoModels({
    required this.success,
    required this.message,
    required this.data,
    required this.meta,
  });

  factory VideoModels.fromJson(Map<String, dynamic>? json) => VideoModels(
        success: json?["success"] ?? false,
        message: json?["message"] ?? "",
        data: json?["data"] == null
            ? []
            : List<Datum>.from(
                json!["data"].map((x) => Datum.fromJson(x)),
              ),
        meta: json?["meta"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "meta": meta,
      };
}

class Datum {
  String id;
  String url;
  String title;
  String description;
  bool isActive;
  DateTime createdAt;
  DateTime updatedAt;
  int v;

  Datum({
    required this.id,
    required this.url,
    required this.title,
    required this.description,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory Datum.fromJson(Map<String, dynamic>? json) => Datum(
        id: json?["_id"] ?? "",
        url: json?["url"] ?? "",
        title: json?["title"] ?? "",
        description: json?["description"] ?? "",
        isActive: json?["isActive"] ?? false,
        createdAt: json?["createdAt"] != null
            ? DateTime.tryParse(json!["createdAt"]) ?? DateTime.now()
            : DateTime.now(),
        updatedAt: json?["updatedAt"] != null
            ? DateTime.tryParse(json!["updatedAt"]) ?? DateTime.now()
            : DateTime.now(),
        v: json?["__v"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "url": url,
        "title": title,
        "description": description,
        "isActive": isActive,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
        "__v": v,
      };
}
