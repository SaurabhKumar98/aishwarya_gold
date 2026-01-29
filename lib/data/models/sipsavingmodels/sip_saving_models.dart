import 'dart:convert';

SipSavingPlan sipSavingPlanFromJson(String str) => SipSavingPlan.fromJson(json.decode(str));

String sipSavingPlanToJson(SipSavingPlan data) => json.encode(data.toJson());

class SipSavingPlan {
  bool? success;
  String? message;
  List<SipSaving> data; // ✅ non-nullable list
  Meta? meta;

  SipSavingPlan({
    this.success,
    this.message,
    List<SipSaving>? data,
    this.meta,
  }) : data = data ?? []; // default to empty list

  factory SipSavingPlan.fromJson(Map<String, dynamic> json) => SipSavingPlan(
        success: json["success"],
        message: json["message"],
        data: json["data"] != null
            ? List<SipSaving>.from(json["data"].map((x) => SipSaving.fromJson(x)))
            : [],
        meta: json["meta"] != null ? Meta.fromJson(json["meta"]) : null,
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "meta": meta?.toJson(),
      };
}

class SipSaving {
  String? id;
  String? userId;
  String? planName;
  double? investmentAmount;
  String? frequency;
  DateTime? startDate;
  DateTime? nextExecutionDate;
  DateTime? endDate;
  double? totalInvested;
  double? totalGoldAccumulated;
  String? status;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;

  SipSaving({
    this.id,
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
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory SipSaving.fromJson(Map<String, dynamic> json) => SipSaving(
        id: json["_id"],
        userId: json["userId"],
        planName: json["planName"],
        // ✅ Convert to double, handling both int and double
        investmentAmount: json["investmentAmount"] != null 
            ? (json["investmentAmount"] as num).toDouble() 
            : null,
        frequency: json["frequency"],
        startDate: json["startDate"] != null ? DateTime.parse(json["startDate"]) : null,
        nextExecutionDate: json["nextExecutionDate"] != null ? DateTime.parse(json["nextExecutionDate"]) : null,
        endDate: json["endDate"] != null ? DateTime.parse(json["endDate"]) : null,
        // ✅ Convert to double, handling both int and double
        totalInvested: json["totalInvested"] != null 
            ? (json["totalInvested"] as num).toDouble() 
            : null,
        // ✅ Convert to double, handling both int and double
        totalGoldAccumulated: json["totalGoldAccumulated"] != null 
            ? (json["totalGoldAccumulated"] as num).toDouble() 
            : null,
        status: json["status"],
        createdAt: json["createdAt"] != null ? DateTime.parse(json["createdAt"]) : null,
        updatedAt: json["updatedAt"] != null ? DateTime.parse(json["updatedAt"]) : null,
        v: json["__v"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
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
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
      };
}
class Meta {
  int? page;
  int? limit;
  int? totalRecords;
  int? totalPages;

  Meta({
    this.page,
    this.limit,
    this.totalRecords,
    this.totalPages,
  });

  factory Meta.fromJson(Map<String, dynamic> json) => Meta(
        page: json["page"],
        limit: json["limit"],
        totalRecords: json["totalRecords"],
        totalPages: json["totalPages"],
      );

  Map<String, dynamic> toJson() => {
        "page": page,
        "limit": limit,
        "totalRecords": totalRecords,
        "totalPages": totalPages,
      };
}
