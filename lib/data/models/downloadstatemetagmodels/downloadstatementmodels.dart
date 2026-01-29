// downloadstatementmodels.dart
import 'dart:convert';

DownloadStatementModels downloadStatementModelsFromJson(String str) =>
    DownloadStatementModels.fromJson(json.decode(str));

String downloadStatementModelsToJson(DownloadStatementModels data) =>
    json.encode(data.toJson());

class DownloadStatementModels {
  final bool? success;
  final String? message;
  final DownloadData? data;
  final dynamic meta;

  DownloadStatementModels({
    this.success,
    this.message,
    this.data,
    this.meta,
  });

  factory DownloadStatementModels.fromJson(Map<String, dynamic> json) =>
      DownloadStatementModels(
        success: json["success"],
        message: json["message"],
        data: json["data"] == null ? null : DownloadData.fromJson(json["data"]),
        meta: json["meta"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data?.toJson(),
        "meta": meta,
      };
}

class DownloadData {
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
  final dynamic pausedAt;
  final dynamic pauseEndDate;
  final dynamic pauseDurationMonths;
  final DateTime? resumedAt;
  final int? totalPaidAmount;
  final List<Transaction>? transactions;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;
  final String? customPurchaseId;

  DownloadData({
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

  factory DownloadData.fromJson(Map<String, dynamic> json) => DownloadData(
        id: json["_id"],
        userId: json["userId"],
        planId: json["planId"] == null ? null : PlanId.fromJson(json["planId"]),
        startDate: _tryParseDate(json["startDate"]),
        endDate: _tryParseDate(json["endDate"]),
        status: json["status"],
        installments: (json["installments"] as List?)
            ?.map((x) => Installment.fromJson(x))
            .toList(),
        nextExecutionDate: _tryParseDate(json["nextExecutionDate"]),
        razorpayPlanId: json["razorpayPlanId"],
        razorpaySubscriptionId: json["razorpaySubscriptionId"],
        subscriptionStatus: json["subscriptionStatus"],
        subscriptionStartDate: _tryParseDate(json["subscriptionStartDate"]),
        subscriptionEndDate: _tryParseDate(json["subscriptionEndDate"]),
        subscriptionCurrentStart: _tryParseDate(json["subscriptionCurrentStart"]),
        subscriptionCurrentEnd: _tryParseDate(json["subscriptionCurrentEnd"]),
        subscriptionQuantity: json["subscriptionQuantity"],
        pausedAt: json["pausedAt"],
        pauseEndDate: json["pauseEndDate"],
        pauseDurationMonths: json["pauseDurationMonths"],
        resumedAt: _tryParseDate(json["resumedAt"]),
        totalPaidAmount: json["totalPaidAmount"],
        transactions: (json["transactions"] as List?)
            ?.map((x) => Transaction.fromJson(x))
            .toList(),
        createdAt: _tryParseDate(json["createdAt"]),
        updatedAt: _tryParseDate(json["updatedAt"]),
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
        "pausedAt": pausedAt,
        "pauseEndDate": pauseEndDate,
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

enum Status { PAID, PENDING }

// FIXED: Case-insensitive status parser
Status? _parseStatus(dynamic status) {
  if (status == null) return null;
  final s = status.toString().toUpperCase();
  if (s == "PAID") return Status.PAID;
  if (s == "PENDING") return Status.PENDING;
  return Status.PENDING; // default fallback
}

class Installment {
  final int? installmentNumber;
  final DateTime? dueDate;
  final DateTime? paidDate;
  final double? baseAmount;
  final double? gstAmount;
  final double? totalAmount;
  final Status? status;
  final String? razorpayPaymentId;
  final String? id;

  Installment({
    this.installmentNumber,
    this.dueDate,
    this.paidDate,
    this.baseAmount,
    this.gstAmount,
    this.totalAmount,
    this.status,
    this.razorpayPaymentId,
    this.id,
  });

  factory Installment.fromJson(Map<String, dynamic> json) => Installment(
        installmentNumber: json["installmentNumber"],
        dueDate: _tryParseDate(json["dueDate"]),
        paidDate: _tryParseDate(json["paidAt"] ?? json["paidDate"]),
        baseAmount: (json["baseAmount"] ?? 0).toDouble(),
        gstAmount: (json["gstAmount"] ?? 0).toDouble(),
        totalAmount: (json["totalAmount"] ?? 0).toDouble(),
        status: _parseStatus(json["status"]), // ← FIXED HERE!
        razorpayPaymentId: json["razorpayPaymentId"],
        id: json["_id"],
      );

  Map<String, dynamic> toJson() => {
        "installmentNumber": installmentNumber,
        "dueDate": dueDate?.toIso8601String(),
        "paidAt": paidDate?.toIso8601String(),
        "baseAmount": baseAmount,
        "gstAmount": gstAmount,
        "totalAmount": totalAmount,
        "status": status.toString().split('.').last,
        "razorpayPaymentId": razorpayPaymentId,
        "_id": id,
      };
}

class PlanId {
  final String? id;
  final String? name;
  final String? type;
  final int? amount;
  final int? durationMonths;
  final int? totalInvestment;
  final int? profitBonus;
  final int? maturityAmount;

  PlanId({
    this.id,
    this.name,
    this.type,
    this.amount,
    this.durationMonths,
    this.totalInvestment,
    this.profitBonus,
    this.maturityAmount,
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

class Transaction {
  final DateTime? date;
  final double? amount;
  final String? razorpayPaymentId;
  final String? id;

  Transaction({
    this.date,
    this.amount,
    this.razorpayPaymentId,
    this.id,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        date: _tryParseDate(json["date"]),
        amount: (json["amount"] ?? 0).toDouble(),
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

// Safe date parser
DateTime? _tryParseDate(dynamic value) {
  if (value == null) return null;
  try {
    return DateTime.parse(value.toString());
  } catch (_) {
    return null;
  }
}