import 'dart:convert';

HistoryModels historyModelsFromJson(String str) =>
    HistoryModels.fromJson(json.decode(str));

String historyModelsToJson(HistoryModels data) => json.encode(data.toJson());

int? parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

class HistoryModels {
  bool? success;
  String? message;
  Data? data;
  dynamic meta;

  HistoryModels({this.success, this.message, this.data, this.meta});

  factory HistoryModels.fromJson(Map<String, dynamic> json) => HistoryModels(
        success: json["success"],
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
  List<AgPlan>? agPlan;
  List<SipPlan>? sipPlan;
  List<OneTimeInvestment>? oneTimeInvestment;

  Data({this.agPlan, this.sipPlan, this.oneTimeInvestment});

factory Data.fromJson(Map<String, dynamic> json) => Data(
      agPlan: (json["AgPlan"] is List)
          ? List<AgPlan>.from(json["AgPlan"].map((x) => AgPlan.fromJson(x)))
          : [],
      sipPlan: (json["SIPPlan"] is List)
          ? List<SipPlan>.from(json["SIPPlan"].map((x) => SipPlan.fromJson(x)))
          : [],
      oneTimeInvestment: (json["OneTimeInvestment"] is List)
          ? List<OneTimeInvestment>.from(
              json["OneTimeInvestment"].map((x) => OneTimeInvestment.fromJson(x)))
          : [],
    );


  Map<String, dynamic> toJson() => {
        "AgPlan": agPlan != null
            ? List<dynamic>.from(agPlan!.map((x) => x.toJson()))
            : [],
        "SIPPlan": sipPlan != null
            ? List<dynamic>.from(sipPlan!.map((x) => x.toJson()))
            : [],
        "OneTimeInvestment": oneTimeInvestment != null
            ? List<dynamic>.from(oneTimeInvestment!.map((x) => x.toJson()))
            : [],
      };
}

class AgPlan {
  String? id;
  String? userId;
  PlanId? planId;
  DateTime? startDate;
  DateTime? endDate;
  String? status;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;

  AgPlan({
    this.id,
    this.userId,
    this.planId,
    this.startDate,
    this.endDate,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory AgPlan.fromJson(Map<String, dynamic> json) => AgPlan(
        id: json["_id"],
        userId: json["userId"],
        planId: json["planId"] != null ? PlanId.fromJson(json["planId"]) : null,
        startDate: json["startDate"] != null
            ? DateTime.parse(json["startDate"])
            : null,
        endDate: json["endDate"] != null ? DateTime.parse(json["endDate"]) : null,
        status: json["status"],
        createdAt: json["createdAt"] != null
            ? DateTime.parse(json["createdAt"])
            : null,
        updatedAt: json["updatedAt"] != null
            ? DateTime.parse(json["updatedAt"])
            : null,
        v: parseInt(json["__v"]),
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "userId": userId,
        "planId": planId?.toJson(),
        "startDate": startDate?.toIso8601String(),
        "endDate": endDate?.toIso8601String(),
        "status": status,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
      };
}

class PlanId {
  String? id;
  String? type;

  PlanId({this.id, this.type});

  factory PlanId.fromJson(Map<String, dynamic> json) => PlanId(
        id: json["_id"],
        type: json["type"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "type": type,
      };
}

class OneTimeInvestment {
  String? id;
  String? userId;
  int? goldQty;
  int? totalAmountToPay;
  double? gstAmount;
  int? discountAmount;
  double? amountPaid;
  double? currentDayGoldPrice;
  String? redeemCode;
  String? status;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;

  OneTimeInvestment({
    this.id,
    this.userId,
    this.goldQty,
    this.totalAmountToPay,
    this.gstAmount,
    this.discountAmount,
    this.amountPaid,
    this.currentDayGoldPrice,
    this.redeemCode,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory OneTimeInvestment.fromJson(Map<String, dynamic> json) =>
      OneTimeInvestment(
        id: json["_id"],
        userId: json["userId"],
        goldQty: parseInt(json["goldQty"]),
        totalAmountToPay: parseInt(json["totalAmountToPay"]),
        gstAmount: json["gstAmount"]?.toDouble(),
        discountAmount: parseInt(json["discountAmount"]),
        amountPaid: json["amountPaid"]?.toDouble(),
        currentDayGoldPrice: json["currentDayGoldPrice"]?.toDouble(),
        redeemCode: json["redeemCode"],
        status: json["status"],
        createdAt: json["createdAt"] != null
            ? DateTime.parse(json["createdAt"])
            : null,
        updatedAt: json["updatedAt"] != null
            ? DateTime.parse(json["updatedAt"])
            : null,
        v: parseInt(json["__v"]),
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "userId": userId,
        "goldQty": goldQty,
        "totalAmountToPay": totalAmountToPay,
        "gstAmount": gstAmount,
        "discountAmount": discountAmount,
        "amountPaid": amountPaid,
        "currentDayGoldPrice": currentDayGoldPrice,
        "redeemCode": redeemCode,
        "status": status,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
      };
}

class SipPlan {
  String? id;
  String? userId;
  String? planName;
  int? investmentAmount;
  String? frequency;
  DateTime? startDate;
  DateTime? nextExecutionDate;
  DateTime? endDate;
  int? totalInvested;
  double? totalGoldAccumulated;
  String? status;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;

  SipPlan({
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

  factory SipPlan.fromJson(Map<String, dynamic> json) => SipPlan(
        id: json["_id"],
        userId: json["userId"],
        planName: json["planName"],
        investmentAmount: parseInt(json["investmentAmount"]),
        frequency: json["frequency"],
        startDate: json["startDate"] != null
            ? DateTime.parse(json["startDate"])
            : null,
        nextExecutionDate: json["nextExecutionDate"] != null
            ? DateTime.parse(json["nextExecutionDate"])
            : null,
        endDate: json["endDate"] != null ? DateTime.parse(json["endDate"]) : null,
        totalInvested: parseInt(json["totalInvested"]),
        totalGoldAccumulated: json["totalGoldAccumulated"]?.toDouble(),
        status: json["status"],
        createdAt: json["createdAt"] != null
            ? DateTime.parse(json["createdAt"])
            : null,
        updatedAt: json["updatedAt"] != null
            ? DateTime.parse(json["updatedAt"])
            : null,
        v: parseInt(json["__v"]),
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
