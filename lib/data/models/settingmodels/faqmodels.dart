// To parse this JSON data, do
//
//     final faqModels = faqModelsFromJson(jsonString);

import 'dart:convert';

FaqModels faqModelsFromJson(String str) => FaqModels.fromJson(json.decode(str));

String faqModelsToJson(FaqModels data) => json.encode(data.toJson());

class FaqModels {
  bool success;
  String message;
  List<FaqData> data;
  dynamic meta;

  FaqModels({
    required this.success,
    required this.message,
    required this.data,
    this.meta,
  });

  factory FaqModels.fromJson(Map<String, dynamic> json) => FaqModels(
        success: json["success"] ?? false,
        message: json["message"] ?? "",
        data: json["data"] == null
            ? []
            : List<FaqData>.from(json["data"].map((x) => FaqData.fromJson(x))),
        meta: json["meta"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "meta": meta,
      };
}

class FaqData {
  String id;
  String question;
  String answer;
  String tag;
  DateTime? createdAt;
  DateTime? updatedAt;
  int v;

  FaqData({
    required this.id,
    required this.question,
    required this.answer,
    required this.tag,
    this.createdAt,
    this.updatedAt,
    required this.v,
  });

  factory FaqData.fromJson(Map<String, dynamic> json) => FaqData(
        id: json["_id"] ?? "",
        question: json["question"] ?? "",
        answer: json["answer"] ?? "",
        tag: json["tag"] ?? "",
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
        "question": question,
        "answer": answer,
        "tag": tag,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
      };
}
