// To parse this JSON data, do
//
//     final purchaseAgModel = purchaseAgModelFromJson(jsonString);

import 'dart:convert';

PurchaseAgModel purchaseAgModelFromJson(String str) =>
    PurchaseAgModel.fromJson(json.decode(str));

String purchaseAgModelToJson(PurchaseAgModel data) =>
    json.encode(data.toJson());

class PurchaseAgModel {
  final bool? success;
  final String? message;
  final Data? data;
  final dynamic meta;

  PurchaseAgModel({
    this.success,
    this.message,
    this.data,
    this.meta,
  });

  factory PurchaseAgModel.fromJson(Map<String, dynamic> json) => PurchaseAgModel(
        success: json["success"] as bool?,
        message: json["message"] as String?,
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
  final String? userId;
  final String? planId;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? status;
  final List<Installment>? installments;
  final String? id;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;

  Data({
    this.userId,
    this.planId,
    this.startDate,
    this.endDate,
    this.status,
    this.installments,
    this.id,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        userId: json["userId"] as String?,
        planId: json["planId"] as String?,
        startDate: json["startDate"] != null
            ? DateTime.tryParse(json["startDate"])
            : null,
        endDate:
            json["endDate"] != null ? DateTime.tryParse(json["endDate"]) : null,
        status: json["status"] as String?,
        installments: json["installments"] != null
            ? List<Installment>.from(
                (json["installments"] as List)
                    .map((x) => Installment.fromJson(x)))
            : [],
        id: json["_id"] as String?,
        createdAt: json["createdAt"] != null
            ? DateTime.tryParse(json["createdAt"])
            : null,
        updatedAt: json["updatedAt"] != null
            ? DateTime.tryParse(json["updatedAt"])
            : null,
        v: json["__v"] != null ? json["__v"] as int : null,
      );

  Map<String, dynamic> toJson() => {
        "userId": userId,
        "planId": planId,
        "startDate": startDate?.toIso8601String(),
        "endDate": endDate?.toIso8601String(),
        "status": status,
        "installments":
            installments != null ? installments!.map((x) => x.toJson()).toList() : [],
        "_id": id,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
      };
}

class Installment {
  final DateTime? dueDate;
  final DateTime? paidDate;
  final int? amount;
  final Status? status;
  final String? id;

  Installment({
    this.dueDate,
    this.paidDate,
    this.amount,
    this.status,
    this.id,
  });

  factory Installment.fromJson(Map<String, dynamic> json) => Installment(
        dueDate: json["dueDate"] != null
            ? DateTime.tryParse(json["dueDate"])
            : null,
        paidDate: json["paidDate"] != null && json["paidDate"] != ""
            ? DateTime.tryParse(json["paidDate"])
            : null,
        amount: json["amount"] != null ? json["amount"] as int : null,
        status: json["status"] != null
            ? statusValues.map[json["status"]]
            : null,
        id: json["_id"] as String?,
      );

  Map<String, dynamic> toJson() => {
        "dueDate": dueDate?.toIso8601String(),
        "paidDate": paidDate?.toIso8601String(),
        "amount": amount,
        "status": statusValues.reverse[status],
        "_id": id,
      };
}

enum Status { pending }

final statusValues = EnumValues({
  "pending": Status.pending,
});

class EnumValues<T> {
  final Map<String, T> map;
  late final Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
