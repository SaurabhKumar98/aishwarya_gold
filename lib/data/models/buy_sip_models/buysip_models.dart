// To parse this JSON data safely
//
//     final sipBuyPlan = sipBuyPlanFromJson(jsonString);

import 'dart:convert';

SipBuyPlan sipBuyPlanFromJson(String str) =>
    SipBuyPlan.fromJson(json.decode(str));

String sipBuyPlanToJson(SipBuyPlan data) => json.encode(data.toJson());

class SipBuyPlan {
  final bool? success;
  final String? message;
  final Data? data;
  final dynamic meta;

  SipBuyPlan({
    this.success,
    this.message,
    this.data,
    this.meta,
  });

  factory SipBuyPlan.fromJson(Map<String, dynamic>? json) => SipBuyPlan(
        success: json?["success"] ?? false,
        message: json?["message"] ?? '',
        data: json?["data"] != null ? Data.fromJson(json!["data"]) : null,
        meta: json?["meta"],
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
  final String? planName;
  final int? investmentAmount;
  final String? frequency;
  final DateTime? startDate;
  final DateTime? nextExecutionDate;
  final DateTime? endDate;
  final int? totalInvested;
  final int? totalGoldAccumulated;
  final String? status;
  final List<Installment>? installments;
  final String? id;
  final List<dynamic>? transactions;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;

  Data({
    this.userId,
    this.planName,
    this.investmentAmount,
    this.frequency,
    this.startDate,
    this.nextExecutionDate,
    this.endDate,
    this.totalInvested,
    this.totalGoldAccumulated,
    this.status,
    this.installments,
    this.id,
    this.transactions,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory Data.fromJson(Map<String, dynamic>? json) => Data(
        userId: json?["userId"] ?? '',
        planName: json?["planName"] ?? '',
        investmentAmount: json?["investmentAmount"] ?? 0,
        frequency: json?["frequency"] ?? '',
        startDate: json?["startDate"] != null
            ? DateTime.tryParse(json?["startDate"])
            : null,
        nextExecutionDate: json?["nextExecutionDate"] != null
            ? DateTime.tryParse(json?["nextExecutionDate"])
            : null,
        endDate: json?["endDate"] != null
            ? DateTime.tryParse(json?["endDate"])
            : null,
        totalInvested: json?["totalInvested"] ?? 0,
        totalGoldAccumulated: json?["totalGoldAccumulated"] ?? 0,
        status: json?["status"] ?? '',
        installments: (json?["installments"] as List?)
                ?.map((x) => Installment.fromJson(x))
                .toList() ??
            [],
        id: json?["_id"] ?? '',
        transactions:
            (json?["transactions"] as List?)?.map((x) => x).toList() ?? [],
        createdAt: json?["createdAt"] != null
            ? DateTime.tryParse(json?["createdAt"])
            : null,
        updatedAt: json?["updatedAt"] != null
            ? DateTime.tryParse(json?["updatedAt"])
            : null,
        v: json?["__v"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "userId": userId,
        "planName": planName,
        "investmentAmount": investmentAmount,
        "frequency": frequency,
        "startDate": startDate?.toIso8601String(),
        "nextExecutionDate": nextExecutionDate?.toIso8601String(),
        "endDate": endDate?.toIso8601String(),
        "totalInvested": totalInvested,
        "totalGoldAccumulated": totalGoldAccumulated,
        "status": status,
        "installments": installments?.map((x) => x.toJson()).toList(),
        "_id": id,
        "transactions": transactions,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
      };
}

class Installment {
  final int? installmentNumber;
  final DateTime? dueDate;
  final int? baseAmount;
  final int? gstPercent;
  final int? gstAmount;
  final int? totalAmount;
  final Status? status;
  final dynamic paidAt;
  final String? id;

  Installment({
    this.installmentNumber,
    this.dueDate,
    this.baseAmount,
    this.gstPercent,
    this.gstAmount,
    this.totalAmount,
    this.status,
    this.paidAt,
    this.id,
  });

  factory Installment.fromJson(Map<String, dynamic>? json) => Installment(
        installmentNumber: json?["installmentNumber"] ?? 0,
        dueDate: json?["dueDate"] != null
            ? DateTime.tryParse(json?["dueDate"])
            : null,
        baseAmount: json?["baseAmount"] ?? 0,
        gstPercent: json?["gstPercent"] ?? 0,
        gstAmount: json?["gstAmount"] ?? 0,
        totalAmount: json?["totalAmount"] ?? 0,
        status: statusValues.map[json?["status"]] ?? Status.PENDING,
        paidAt: json?["paidAt"],
        id: json?["_id"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "installmentNumber": installmentNumber,
        "dueDate": dueDate?.toIso8601String(),
        "baseAmount": baseAmount,
        "gstPercent": gstPercent,
        "gstAmount": gstAmount,
        "totalAmount": totalAmount,
        "status": statusValues.reverse[status],
        "paidAt": paidAt,
        "_id": id,
      };
}

enum Status { PENDING }

final statusValues = EnumValues({
  "PENDING": Status.PENDING,
});

class EnumValues<T> {
  final Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
