import 'dart:convert';

NotificationModels notificationModelsFromJson(String str) =>
    NotificationModels.fromJson(json.decode(str));

String notificationModelsToJson(NotificationModels data) =>
    json.encode(data.toJson());

class NotificationModels {
  final bool? success;
  final String? message;
  final List<NotficationData>? data;
  final dynamic meta;

  NotificationModels({
    this.success,
    this.message,
    this.data,
    this.meta,
  });

  factory NotificationModels.fromJson(Map<String, dynamic> json) {
    return NotificationModels(
      success: json["success"] ?? false,
      message: json["message"] ?? "",
      data: json["data"] == null
          ? []
          : List<NotficationData>.from(
              (json["data"] as List)
                  .map((x) => NotficationData.fromJson(x))
                  .where((e) => e != null),
            ),
      meta: json["meta"],
    );
  }

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
        "meta": meta,
      };
}

class NotficationData {
  
  final String? id;
  final String? user;
  final String? title;
  final String? message;
   bool? isRead;
  final int? v;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Data? data;

  NotficationData({
    this.id,
    this.user,
    this.title,
    this.message,
    this.isRead,
    this.v,
    this.createdAt,
    this.updatedAt,
    this.data,
  });

  factory NotficationData.fromJson(Map<String, dynamic> json) {
    return NotficationData(
      id: json["_id"] ?? "",
      user: json["user"] ?? "",
      title: json["title"] ?? "",
      message: json["message"] ?? "",
      isRead: json["isRead"] ?? false,
      v: json["__v"] ?? 0,
      createdAt: json["createdAt"] != null
          ? DateTime.tryParse(json["createdAt"])
          : null,
      updatedAt: json["updatedAt"] != null
          ? DateTime.tryParse(json["updatedAt"])
          : null,
      data: json["data"] != null ? Data.fromJson(json["data"]) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        "_id": id,
        "user": user,
        "title": title,
        "message": message,
        "isRead": isRead,
        "__v": v,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "data": data?.toJson(),
      };
}

class Data {
  final String? promoCode;

  Data({this.promoCode});

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      promoCode: json["promoCode"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
        "promoCode": promoCode,
      };
}
