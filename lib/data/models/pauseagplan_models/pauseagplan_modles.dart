import 'dart:convert';

// Pause Plan Models
PauseAgPlanModels pauseAgPlanModelsFromJson(String str) =>
    PauseAgPlanModels.fromJson(json.decode(str));

String pauseAgPlanModelsToJson(PauseAgPlanModels data) =>
    json.encode(data.toJson());

class PauseAgPlanModels {
  bool? success;
  String? message;
  PausePlanData? data;
  dynamic meta;

  PauseAgPlanModels({
    this.success,
    this.message,
    this.data,
    this.meta,
  });

  factory PauseAgPlanModels.fromJson(Map<String, dynamic> json) =>
      PauseAgPlanModels(
        success: json["success"],
        message: json["message"],
        data: json["data"] != null ? PausePlanData.fromJson(json["data"]) : null,
        meta: json["meta"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data?.toJson(),
        "meta": meta,
      };
}

class PausePlanData {
  Purchase? purchase;
  String? message;

  PausePlanData({
    this.purchase,
    this.message,
  });

  factory PausePlanData.fromJson(Map<String, dynamic> json) => PausePlanData(
        purchase: json["purchase"] != null
            ? Purchase.fromJson(json["purchase"])
            : null,
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "purchase": purchase?.toJson(),
        "message": message,
      };
}

class Purchase {
  String? id;
  String? userId;
  PlanInfo? planId;
  DateTime? startDate;
  DateTime? endDate;
  String? status;
  List<PlanInstallment>? installments;
  DateTime? nextExecutionDate;
  String? razorpayPlanId;
  String? razorpaySubscriptionId;
  String? subscriptionStatus;
  DateTime? pausedAt;
  DateTime? pauseEndDate;
  int? pauseDurationMonths;
  DateTime? resumedAt;
  int? totalPaidAmount;
  List<Transaction>? transactions;
  DateTime? createdAt;
  DateTime? updatedAt;

  Purchase({
    this.id,
    this.userId,
    this.planId,
    this.startDate,
    this.endDate,
    this.status,
    this.installments,
    this.nextExecutionDate,
    this.razorpayPlanId,
    this.razorpaySubscriptionId,
    this.subscriptionStatus,
    this.pausedAt,
    this.pauseEndDate,
    this.pauseDurationMonths,
    this.resumedAt,
    this.totalPaidAmount,
    this.transactions,
    this.createdAt,
    this.updatedAt,
  });

  factory Purchase.fromJson(Map<String, dynamic> json) => Purchase(
        id: json["_id"],
        userId: json["userId"],
        planId: json["planId"] != null ? PlanInfo.fromJson(json["planId"]) : null,
        startDate: json["startDate"] != null
            ? DateTime.parse(json["startDate"])
            : null,
        endDate:
            json["endDate"] != null ? DateTime.parse(json["endDate"]) : null,
        status: json["status"],
        installments: json["installments"] != null
            ? List<PlanInstallment>.from(
                json["installments"].map((x) => PlanInstallment.fromJson(x)))
            : [],
        nextExecutionDate: json["nextExecutionDate"] != null
            ? DateTime.parse(json["nextExecutionDate"])
            : null,
        razorpayPlanId: json["razorpayPlanId"],
        razorpaySubscriptionId: json["razorpaySubscriptionId"],
        subscriptionStatus: json["subscriptionStatus"],
        pausedAt: json["pausedAt"] != null
            ? DateTime.parse(json["pausedAt"])
            : null,
        pauseEndDate: json["pauseEndDate"] != null
            ? DateTime.parse(json["pauseEndDate"])
            : null,
        pauseDurationMonths: json["pauseDurationMonths"],
        resumedAt: json["resumedAt"] != null
            ? DateTime.parse(json["resumedAt"])
            : null,
        totalPaidAmount: json["totalPaidAmount"],
        transactions: json["transactions"] != null
            ? List<Transaction>.from(
                json["transactions"].map((x) => Transaction.fromJson(x)))
            : [],
        createdAt: json["createdAt"] != null
            ? DateTime.parse(json["createdAt"])
            : null,
        updatedAt: json["updatedAt"] != null
            ? DateTime.parse(json["updatedAt"])
            : null,
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
        "nextExecutionDate": nextExecutionDate?.toIso8601String(),
        "razorpayPlanId": razorpayPlanId,
        "razorpaySubscriptionId": razorpaySubscriptionId,
        "subscriptionStatus": subscriptionStatus,
        "pausedAt": pausedAt?.toIso8601String(),
        "pauseEndDate": pauseEndDate?.toIso8601String(),
        "pauseDurationMonths": pauseDurationMonths,
        "resumedAt": resumedAt?.toIso8601String(),
        "totalPaidAmount": totalPaidAmount,
        "transactions": transactions != null
            ? List<dynamic>.from(transactions!.map((x) => x.toJson()))
            : [],
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
      };
}

class PlanInfo {
  String? id;
  String? name;
  String? type;
  int? amount;
  int? durationMonths;
  int? totalInvestment;
  int? profitBonus;
  int? maturityAmount;

  PlanInfo({
    this.id,
    this.name,
    this.type,
    this.amount,
    this.durationMonths,
    this.totalInvestment,
    this.profitBonus,
    this.maturityAmount,
  });

  factory PlanInfo.fromJson(Map<String, dynamic> json) => PlanInfo(
        id: json["_id"],
        name: json["name"],
        type: json["type"],
        amount: json["amount"],
        durationMonths: json["durationMonths"],
        totalInvestment: json["totalInvestment"],
        profitBonus: json["profitBonus"],
        maturityAmount: json["maturityAmount"],
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
      };
}

class PlanInstallment {
  int? installmentNumber;
  DateTime? dueDate;
  dynamic paidDate;
  int? amount;
  String? status;
  String? id;

  PlanInstallment({
    this.installmentNumber,
    this.dueDate,
    this.paidDate,
    this.amount,
    this.status,
    this.id,
  });

  factory PlanInstallment.fromJson(Map<String, dynamic> json) =>
      PlanInstallment(
        installmentNumber: json["installmentNumber"],
        dueDate:
            json["dueDate"] != null ? DateTime.parse(json["dueDate"]) : null,
        paidDate: json["paidDate"],
        amount: json["amount"],
        status: json["status"],
        id: json["_id"],
      );

  Map<String, dynamic> toJson() => {
        "installmentNumber": installmentNumber,
        "dueDate": dueDate?.toIso8601String(),
        "paidDate": paidDate,
        "amount": amount,
        "status": status,
        "_id": id,
      };
}

class Transaction {
  DateTime? date;
  int? amount;
  String? razorpayPaymentId;
  String? id;

  Transaction({
    this.date,
    this.amount,
    this.razorpayPaymentId,
    this.id,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        date: json["date"] != null ? DateTime.parse(json["date"]) : null,
        amount: json["amount"],
        razorpayPaymentId: json["razorpayPaymentId"],
        id: json["_id"],
      );

  Map<String, dynamic> toJson() => {
        "date": date?.toIso8601String(),
        "amount": amount,
        "razorpayPaymentId": razorpayPaymentId,
        "_id": id,
      };
}

// Resume Plan Models
ResumeAgPlanModels resumeAgPlanModelsFromJson(String str) =>
    ResumeAgPlanModels.fromJson(json.decode(str));

String resumeAgPlanModelsToJson(ResumeAgPlanModels data) =>
    json.encode(data.toJson());

class ResumeAgPlanModels {
  bool? success;
  String? message;
  ResumePlanData? data;
  dynamic meta;

  ResumeAgPlanModels({
    this.success,
    this.message,
    this.data,
    this.meta,
  });

  factory ResumeAgPlanModels.fromJson(Map<String, dynamic> json) =>
      ResumeAgPlanModels(
        success: json["success"],
        message: json["message"],
        data: json["data"] != null ? ResumePlanData.fromJson(json["data"]) : null,
        meta: json["meta"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data?.toJson(),
        "meta": meta,
      };
}

class ResumePlanData {
  Purchase? purchase;
  String? message;

  ResumePlanData({
    this.purchase,
    this.message,
  });

  factory ResumePlanData.fromJson(Map<String, dynamic> json) => ResumePlanData(
        purchase: json["purchase"] != null
            ? Purchase.fromJson(json["purchase"])
            : null,
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "purchase": purchase?.toJson(),
        "message": message,
      };
}