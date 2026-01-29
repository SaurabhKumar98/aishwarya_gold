// To parse this JSON data, do:
//
//     final reedemSipModels = reedemSipModelsFromJson(jsonString);

import 'dart:convert';

ReedemSipModels reedemSipModelsFromJson(String str) => ReedemSipModels.fromJson(json.decode(str));

String reedemSipModelsToJson(ReedemSipModels data) => json.encode(data.toJson());

class ReedemSipModels {
  bool? success;
  String? message;
  Data? data;
  dynamic meta;

  ReedemSipModels({this.success, this.message, this.data, this.meta});

  factory ReedemSipModels.fromJson(Map<String, dynamic> json) => ReedemSipModels(
        success: json["success"],
        message: json["message"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
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
  String? id;
  UserId? userId;
  String? planName;
  double? investmentAmount;
  String? frequency;
  DateTime? startDate;
  DateTime? nextExecutionDate;
  DateTime? endDate;
  double? totalInvested;
  double? totalGoldAccumulated;
  String? status;
  dynamic pausedAt;
  dynamic pauseEndDate;
  dynamic pauseDurationMonths;
  dynamic resumedAt;
  dynamic pauseReason;
  List<Installment>? installments;
  List<Transaction>? transactions;
  String? razorpaySubscriptionId;
  String? razorpayPlanId;
  String? razorpayCustomerId;
  String? subscriptionStatus;
  DateTime? subscriptionStartDate;
  DateTime? subscriptionEndDate;
  DateTime? subscriptionCurrentStart;
  DateTime? subscriptionCurrentEnd;
  double? subscriptionQuantity;
  DateTime? createdAt;
  DateTime? updatedAt;
  double? v;
  ProfitLoss? profitLoss;
  String? username;
  String? customPlanId;

  Data({
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
    this.pausedAt,
    this.pauseEndDate,
    this.pauseDurationMonths,
    this.resumedAt,
    this.pauseReason,
    this.installments,
    this.transactions,
    this.razorpaySubscriptionId,
    this.razorpayPlanId,
    this.razorpayCustomerId,
    this.subscriptionStatus,
    this.subscriptionStartDate,
    this.subscriptionEndDate,
    this.subscriptionCurrentStart,
    this.subscriptionCurrentEnd,
    this.subscriptionQuantity,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.profitLoss,
    this.username,
    this.customPlanId,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: json["_id"],
        userId: json["userId"] == null ? null : UserId.fromJson(json["userId"]),
        planName: json["planName"],
        investmentAmount: (json["investmentAmount"] ?? 0).toDouble(),
        frequency: json["frequency"],
        startDate: json["startDate"] == null ? null : DateTime.parse(json["startDate"]),
        nextExecutionDate: json["nextExecutionDate"] == null ? null : DateTime.parse(json["nextExecutionDate"]),
        endDate: json["endDate"] == null ? null : DateTime.parse(json["endDate"]),
        totalInvested: (json["totalInvested"] ?? 0).toDouble(),
        totalGoldAccumulated: (json["totalGoldAccumulated"] ?? 0).toDouble(),
        status: json["status"],
        pausedAt: json["pausedAt"],
        pauseEndDate: json["pauseEndDate"],
        pauseDurationMonths: json["pauseDurationMonths"],
        resumedAt: json["resumedAt"],
        pauseReason: json["pauseReason"],
        installments: json["installments"] == null
            ? []
            : List<Installment>.from(json["installments"].map((x) => Installment.fromJson(x))),
        transactions: json["transactions"] == null
            ? []
            : List<Transaction>.from(json["transactions"].map((x) => Transaction.fromJson(x))),
        razorpaySubscriptionId: json["razorpaySubscriptionId"],
        razorpayPlanId: json["razorpayPlanId"],
        razorpayCustomerId: json["razorpayCustomerId"],
        subscriptionStatus: json["subscriptionStatus"],
        subscriptionStartDate: json["subscriptionStartDate"] == null ? null : DateTime.parse(json["subscriptionStartDate"]),
        subscriptionEndDate: json["subscriptionEndDate"] == null ? null : DateTime.parse(json["subscriptionEndDate"]),
        subscriptionCurrentStart: json["subscriptionCurrentStart"] == null ? null : DateTime.parse(json["subscriptionCurrentStart"]),
        subscriptionCurrentEnd: json["subscriptionCurrentEnd"] == null ? null : DateTime.parse(json["subscriptionCurrentEnd"]),
        subscriptionQuantity: (json["subscriptionQuantity"] ?? 0).toDouble(),
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
        v: (json["__v"] ?? 0).toDouble(),
        profitLoss: json["profitLoss"] == null ? null : ProfitLoss.fromJson(json["profitLoss"]),
        username: json["username"],
        customPlanId: json["customPlanId"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "userId": userId?.toJson(),
        "planName": planName,
        "investmentAmount": investmentAmount,
        "frequency": frequency,
        "startDate": startDate?.toIso8601String(),
        "nextExecutionDate": nextExecutionDate?.toIso8601String(),
        "endDate": endDate?.toIso8601String(),
        "totalInvested": totalInvested,
        "totalGoldAccumulated": totalGoldAccumulated,
        "status": status,
        "pausedAt": pausedAt,
        "pauseEndDate": pauseEndDate,
        "pauseDurationMonths": pauseDurationMonths,
        "resumedAt": resumedAt,
        "pauseReason": pauseReason,
        "installments": installments?.map((x) => x.toJson()).toList(),
        "transactions": transactions?.map((x) => x.toJson()).toList(),
        "razorpaySubscriptionId": razorpaySubscriptionId,
        "razorpayPlanId": razorpayPlanId,
        "razorpayCustomerId": razorpayCustomerId,
        "subscriptionStatus": subscriptionStatus,
        "subscriptionStartDate": subscriptionStartDate?.toIso8601String(),
        "subscriptionEndDate": subscriptionEndDate?.toIso8601String(),
        "subscriptionCurrentStart": subscriptionCurrentStart?.toIso8601String(),
        "subscriptionCurrentEnd": subscriptionCurrentEnd?.toIso8601String(),
        "subscriptionQuantity": subscriptionQuantity,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
        "profitLoss": profitLoss?.toJson(),
        "username": username,
        "customPlanId": customPlanId,
      };
}

class Installment {
  double? installmentNumber;
  DateTime? dueDate;
  double? baseAmount;
  double? gstPercent;
  double? gstAmount;
  double? totalAmount;
  Status? status;
  DateTime? paidAt;
  String? id;

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

  factory Installment.fromJson(Map<String, dynamic> json) => Installment(
        installmentNumber: (json["installmentNumber"] ?? 0).toDouble(),
        dueDate: json["dueDate"] == null ? null : DateTime.parse(json["dueDate"]),
        baseAmount: (json["baseAmount"] ?? 0).toDouble(),
        gstPercent: (json["gstPercent"] ?? 0).toDouble(),
        gstAmount: (json["gstAmount"] ?? 0).toDouble(),
        totalAmount: (json["totalAmount"] ?? 0).toDouble(),
        status: statusValues.map[json["status"]],
        paidAt: json["paidAt"] == null ? null : DateTime.parse(json["paidAt"]),
        id: json["_id"],
      );

  Map<String, dynamic> toJson() => {
        "installmentNumber": installmentNumber,
        "dueDate": dueDate?.toIso8601String(),
        "baseAmount": baseAmount,
        "gstPercent": gstPercent,
        "gstAmount": gstAmount,
        "totalAmount": totalAmount,
        "status": statusValues.reverse[status],
        "paidAt": paidAt?.toIso8601String(),
        "_id": id,
      };
}

class Transaction {
  DateTime? date;
  double? goldPricePerGram;
  double? investedAmount;
  double? goldBoughtInGram;
  String? razorpayPaymentId;  // This was missing!
  String? id;

  Transaction({
    this.date,
    this.goldPricePerGram,
    this.investedAmount,
    this.goldBoughtInGram,
    this.razorpayPaymentId,
    this.id,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        date: json["date"] == null ? null : DateTime.parse(json["date"]),
        goldPricePerGram: (json["goldPricePerGram"] ?? 0).toDouble(),
        investedAmount: (json["investedAmount"] ?? 0).toDouble(),
        goldBoughtInGram: (json["goldBoughtInGram"] ?? 0).toDouble(),
        razorpayPaymentId: json["razorpayPaymentId"],
        id: json["_id"],
      );

  Map<String, dynamic> toJson() => {
        "date": date?.toIso8601String(),
        "goldPricePerGram": goldPricePerGram,
        "investedAmount": investedAmount,
        "goldBoughtInGram": goldBoughtInGram,
        "razorpayPaymentId": razorpayPaymentId,
        "_id": id,
      };
}

enum Status { PAID, PENDING }

final statusValues = EnumValues({
  "PAID": Status.PAID,
  "PENDING": Status.PENDING,
});

class ProfitLoss {
  double? currentValue;
  double? profitLoss;
  double? profitLossPercentage;
  bool? isProfitable;
  bool? canCalculate;
  double? currentGoldPrice;

  ProfitLoss({
    this.currentValue,
    this.profitLoss,
    this.profitLossPercentage,
    this.isProfitable,
    this.canCalculate,
    this.currentGoldPrice,
  });

  factory ProfitLoss.fromJson(Map<String, dynamic> json) => ProfitLoss(
        currentValue: (json["currentValue"] ?? 0).toDouble(),
        profitLoss: (json["profitLoss"] ?? 0).toDouble(),
        profitLossPercentage: (json["profitLossPercentage"] ?? 0).toDouble(),
        isProfitable: json["isProfitable"],
        canCalculate: json["canCalculate"],
        currentGoldPrice: (json["currentGoldPrice"] ?? 0).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "currentValue": currentValue,
        "profitLoss": profitLoss,
        "profitLossPercentage": profitLossPercentage,
        "isProfitable": isProfitable,
        "canCalculate": canCalculate,
        "currentGoldPrice": currentGoldPrice,
      };
}

class UserId {
  String? id;
  String? name;

  UserId({this.id, this.name});

  factory UserId.fromJson(Map<String, dynamic> json) => UserId(
        id: json["_id"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
      };
}

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}