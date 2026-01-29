// To parse this JSON data, do
//
//     final agPlanByIdModels = agPlanByIdModelsFromJson(jsonString);

import 'dart:convert';

AgPlanByIdModels agPlanByIdModelsFromJson(String str) =>
    AgPlanByIdModels.fromJson(json.decode(str));

String agPlanByIdModelsToJson(AgPlanByIdModels data) =>
    json.encode(data.toJson());

class AgPlanByIdModels {
  final bool? success;
  final String? message;
  final AgPlanModels? data;
  final dynamic meta;

  AgPlanByIdModels({this.success, this.message, this.data, this.meta});

  factory AgPlanByIdModels.fromJson(Map<String, dynamic> json) =>
      AgPlanByIdModels(
        success: json["success"],
        message: json["message"],
        data: json["data"] == null ? null : AgPlanModels.fromJson(json["data"]),
        meta: json["meta"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data?.toJson(),
        "meta": meta,
      };
}

class AgPlanModels {
  final String? id;
  final String? userId;
  final PlanId? planId;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? status;
  final List<Installment>? installments;
  final DateTime? nextExecutionDate;
  final String? razorpayPlanId;
  final String? razorpaySubscriptionId;
  final String? subscriptionStatus;
  final DateTime? subscriptionStartDate;
  final DateTime? subscriptionEndDate;
  final DateTime? subscriptionCurrentStart;
  final DateTime? subscriptionCurrentEnd;
  final int? subscriptionQuantity;
  final bool? manualPaymentRequired;
  final dynamic failedInstallmentNumber;
  final int? retryAttempts;
  final DateTime? pausedAt;
  final DateTime? pauseEndDate;
  final int? pauseDurationMonths;
  final DateTime? resumedAt;
  final int? totalPaidAmount;
  final List<Transaction>? transactions;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;
  final String? customPurchaseId;

  AgPlanModels({
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
    this.subscriptionStartDate,
    this.subscriptionEndDate,
    this.subscriptionCurrentStart,
    this.subscriptionCurrentEnd,
    this.subscriptionQuantity,
    this.manualPaymentRequired,
    this.failedInstallmentNumber,
    this.retryAttempts,
    this.pausedAt,
    this.pauseEndDate,
    this.pauseDurationMonths,
    this.resumedAt,
    this.totalPaidAmount,
    this.transactions,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.customPurchaseId,
  });

  factory AgPlanModels.fromJson(Map<String, dynamic> json) => AgPlanModels(
        id: json["_id"],
        userId: json["userId"],
        planId: json["planId"] == null ? null : PlanId.fromJson(json["planId"]),
        startDate: json["startDate"] == null ? null : DateTime.parse(json["startDate"]),
        endDate: json["endDate"] == null ? null : DateTime.parse(json["endDate"]),
        status: json["status"],
        installments: json["installments"] == null
            ? []
            : List<Installment>.from(json["installments"].map((x) => Installment.fromJson(x))),
        nextExecutionDate: json["nextExecutionDate"] == null
            ? null
            : DateTime.parse(json["nextExecutionDate"]),
        razorpayPlanId: json["razorpayPlanId"],
        razorpaySubscriptionId: json["razorpaySubscriptionId"],
        subscriptionStatus: json["subscriptionStatus"],
        subscriptionStartDate: json["subscriptionStartDate"] == null
            ? null
            : DateTime.parse(json["subscriptionStartDate"]),
        subscriptionEndDate: json["subscriptionEndDate"] == null
            ? null
            : DateTime.parse(json["subscriptionEndDate"]),
        subscriptionCurrentStart: json["subscriptionCurrentStart"] == null
            ? null
            : DateTime.parse(json["subscriptionCurrentStart"]),
        subscriptionCurrentEnd: json["subscriptionCurrentEnd"] == null
            ? null
            : DateTime.parse(json["subscriptionCurrentEnd"]),
        subscriptionQuantity: json["subscriptionQuantity"],
        manualPaymentRequired: json["manualPaymentRequired"],
        failedInstallmentNumber: json["failedInstallmentNumber"],
        retryAttempts: json["retryAttempts"],
        pausedAt: json["pausedAt"] == null ? null : DateTime.parse(json["pausedAt"]),
        pauseEndDate: json["pauseEndDate"] == null ? null : DateTime.parse(json["pauseEndDate"]),
        pauseDurationMonths: json["pauseDurationMonths"],
        resumedAt: json["resumedAt"] == null ? null : DateTime.parse(json["resumedAt"]),
        totalPaidAmount: json["totalPaidAmount"],
        transactions: json["transactions"] == null
            ? []
            : List<Transaction>.from(json["transactions"].map((x) => Transaction.fromJson(x))),
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
        v: json["__v"],
        customPurchaseId: json["customPurchaseId"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "userId": userId,
        "planId": planId?.toJson(),
        "startDate": startDate?.toIso8601String(),
        "endDate": endDate?.toIso8601String(),
        "status": status,
        "installments": installments?.map((x) => x.toJson()).toList(),
        "nextExecutionDate": nextExecutionDate?.toIso8601String(),
        "razorpayPlanId": razorpayPlanId,
        "razorpaySubscriptionId": razorpaySubscriptionId,
        "subscriptionStatus": subscriptionStatus,
        "subscriptionStartDate": subscriptionStartDate?.toIso8601String(),
        "subscriptionEndDate": subscriptionEndDate?.toIso8601String(),
        "subscriptionCurrentStart": subscriptionCurrentStart?.toIso8601String(),
        "subscriptionCurrentEnd": subscriptionCurrentEnd?.toIso8601String(),
        "subscriptionQuantity": subscriptionQuantity,
        "manualPaymentRequired": manualPaymentRequired,
        "failedInstallmentNumber": failedInstallmentNumber,
        "retryAttempts": retryAttempts,
        "pausedAt": pausedAt?.toIso8601String(),
        "pauseEndDate": pauseEndDate?.toIso8601String(),
        "pauseDurationMonths": pauseDurationMonths,
        "resumedAt": resumedAt?.toIso8601String(),
        "totalPaidAmount": totalPaidAmount,
        "transactions": transactions?.map((x) => x.toJson()).toList(),
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
        "customPurchaseId": customPurchaseId,
      };
}

class Installment {
  final int? installmentNumber;
  final DateTime? dueDate;
  final double? baseAmount;
  final double? gstPercent;
  final double? gstAmount;
  final double? totalAmount;
  final Status? status;
  final DateTime? paidAt;
  final String? razorpayPaymentId;
  final String? razorpayInvoiceId;
  final String? razorpaySubscriptionId;
  final String? razorpayOrderId;
  final String? failureReason;
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
    this.razorpayPaymentId,
    this.razorpayInvoiceId,
    this.razorpaySubscriptionId,
    this.razorpayOrderId,
    this.failureReason,
    this.id,
  });

  factory Installment.fromJson(Map<String, dynamic> json) => Installment(
        installmentNumber: json["installmentNumber"] as int?,
        dueDate: json["dueDate"] == null ? null : DateTime.parse(json["dueDate"]),
        baseAmount: (json["baseAmount"] as num?)?.toDouble(),
        gstPercent: (json["gstPercent"] as num?)?.toDouble(),
        gstAmount: (json["gstAmount"] as num?)?.toDouble(),
        totalAmount: (json["totalAmount"] as num?)?.toDouble(),
        status: json["status"] == null ? null : _parseStatus(json["status"]),
        paidAt: json["paidAt"] == null ? null : DateTime.parse(json["paidAt"]),
        razorpayPaymentId: json["razorpayPaymentId"] as String?,
        razorpayInvoiceId: json["razorpayInvoiceId"] as String?,
        razorpaySubscriptionId: json["razorpaySubscriptionId"] as String?,
        razorpayOrderId: json["razorpayOrderId"] as String?,
        failureReason: json["failureReason"] as String?,
        id: json["_id"] as String?,
      );

  static Status? _parseStatus(String status) {
    switch (status.toUpperCase()) {
      case 'PAID':
        return Status.PAID;
      case 'PENDING':
        return Status.PENDING;
      default:
        return null;
    }
  }

  Map<String, dynamic> toJson() => {
        "installmentNumber": installmentNumber,
        "dueDate": dueDate?.toIso8601String(),
        "baseAmount": baseAmount,
        "gstPercent": gstPercent,
        "gstAmount": gstAmount,
        "totalAmount": totalAmount,
        "status": status?.toString().split('.').last,
        "paidAt": paidAt?.toIso8601String(),
        "razorpayPaymentId": razorpayPaymentId,
        "razorpayInvoiceId": razorpayInvoiceId,
        "razorpaySubscriptionId": razorpaySubscriptionId,
        "razorpayOrderId": razorpayOrderId,
        "failureReason": failureReason,
        "_id": id,
      };
}

enum Status { PAID, PENDING }

class PlanId {
  final String? id;
  final String? name;
  final String? type;
  final int? amount;
  final int? durationMonths;
  final int? totalInvestment;
  final int? profitBonus;
  final int? maturityAmount;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;

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
        id: json["_id"],
        name: json["name"],
        type: json["type"],
        amount: json["amount"],
        durationMonths: json["durationMonths"],
        totalInvestment: json["totalInvestment"],
        profitBonus: json["profitBonus"],
        maturityAmount: json["maturityAmount"],
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
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

class Transaction {
  final DateTime? date;
  final int? amount;
  final String? razorpayPaymentId;
  final String? id;

  Transaction({this.date, this.amount, this.razorpayPaymentId, this.id});

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        date: json["date"] == null ? null : DateTime.parse(json["date"]),
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