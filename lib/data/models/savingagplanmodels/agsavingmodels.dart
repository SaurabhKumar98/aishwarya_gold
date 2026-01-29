import 'dart:convert';

AgPlanSavingModels agPlanSavingModelsFromJson(String str) =>
    AgPlanSavingModels.fromJson(json.decode(str));

String agPlanSavingModelsToJson(AgPlanSavingModels data) =>
    json.encode(data.toJson());

class AgPlanSavingModels {
  bool? success;
  String? message;
  List<AgSaving>? data;
  dynamic meta;

  AgPlanSavingModels({this.success, this.message, this.data, this.meta});

  factory AgPlanSavingModels.fromJson(Map<String, dynamic> json) =>
      AgPlanSavingModels(
        success: json["success"],
        message: json["message"],
        data: json["data"] != null
            ? List<AgSaving>.from(json["data"].map((x) => AgSaving.fromJson(x)))
            : [],
        meta: json["meta"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data != null
            ? List<dynamic>.from(data!.map((x) => x.toJson()))
            : [],
        "meta": meta,
      };
}

class AgSaving {
  String? id;
  String? userId;  // Changed from UserId? enum to String?
  PlanId? planId;
  DateTime? startDate;
  DateTime? endDate;
  String? status;  // Changed from DatumStatus? enum to String?
  List<Installment>? installments;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;

  AgSaving({
    this.id,
    this.userId,
    this.planId,
    this.startDate,
    this.endDate,
    this.status,
    this.installments,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory AgSaving.fromJson(Map<String, dynamic> json) => AgSaving(
        id: json["_id"],
        userId: json["userId"],  // Direct string assignment
        planId: json["planId"] != null ? PlanId.fromJson(json["planId"]) : null,
        startDate: json["startDate"] != null
            ? DateTime.parse(json["startDate"])
            : null,
        endDate: json["endDate"] != null
            ? DateTime.parse(json["endDate"])
            : null,
        status: json["status"],  // Direct string assignment
        installments: json["installments"] != null
            ? List<Installment>.from(
                json["installments"].map((x) => Installment.fromJson(x)))
            : [],
        createdAt: json["createdAt"] != null
            ? DateTime.parse(json["createdAt"])
            : null,
        updatedAt: json["updatedAt"] != null
            ? DateTime.parse(json["updatedAt"])
            : null,
        v: json["__v"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "userId": userId,
        "planId": planId?.toJson(),
        "startDate": startDate?.toIso8601String(),
        "endDate": endDate?.toIso8601String(),
        "status": status,
        "installments": installments != null
            ? List<dynamic>.from(installments!.map((x) => x.toJson()))
            : [],
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
      };
}

class Installment {
  DateTime? dueDate;
  dynamic paidDate;
  int? amount;
  String? status;  // Changed from InstallmentStatus? enum to String?
  String? id;

  Installment({this.dueDate, this.paidDate, this.amount, this.status, this.id});

  factory Installment.fromJson(Map<String, dynamic> json) => Installment(
        dueDate: json["dueDate"] != null ? DateTime.parse(json["dueDate"]) : null,
        paidDate: json["paidDate"],
        amount: json["amount"],
        status: json["status"],  // Direct string assignment
        id: json["_id"],
      );

  Map<String, dynamic> toJson() => {
        "dueDate": dueDate?.toIso8601String(),
        "paidDate": paidDate,
        "amount": amount,
        "status": status,
        "_id": id,
      };
}

class PlanId {
  String? id;  // Changed from Id? enum to String?
  String? name;  // Changed from Name? enum to String?
  String? type;  // Changed from Type? enum to String?
  int? amount;
  int? durationMonths;
  int? totalInvestment;
  int? profitBonus;
  int? maturityAmount;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;

  PlanId({
    this.id,
    this.name,
    this.type,
    this.amount,
    this.durationMonths,
    this.totalInvestment,
    this.profitBonus,
    this.maturityAmount,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory PlanId.fromJson(Map<String, dynamic> json) => PlanId(
        id: json["_id"],  // Direct string assignment
        name: json["name"],  // Direct string assignment
        type: json["type"],  // Direct string assignment
        amount: json["amount"],
        durationMonths: json["durationMonths"],
        totalInvestment: json["totalInvestment"],
        profitBonus: json["profitBonus"],
        maturityAmount: json["maturityAmount"],
        createdAt: json["createdAt"] != null
            ? DateTime.parse(json["createdAt"])
            : null,
        updatedAt: json["updatedAt"] != null
            ? DateTime.parse(json["updatedAt"])
            : null,
        v: json["__v"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "type": type,
        "amount": amount,
        "durationMonths": durationMonths,
        "totalInvestment": totalInvestment,
        "profitBonus": profitBonus,
        "maturityAmount": maturityAmount,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
      };
}

// Remove all the enum definitions and EnumValues class
// They're no longer needed since we're using strings directly