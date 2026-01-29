import 'dart:convert';

OneTimeByIdModels oneTimeByIdModelsFromJson(String str) =>
    OneTimeByIdModels.fromJson(json.decode(str));

String oneTimeByIdModelsToJson(OneTimeByIdModels data) =>
    json.encode(data.toJson());

class OneTimeByIdModels {
  bool? success;
  String? message;
  OneTimeData? data;
  dynamic meta;

  OneTimeByIdModels({
    this.success,
    this.message,
    this.data,
    this.meta,
  });

  factory OneTimeByIdModels.fromJson(Map<String, dynamic> json) =>
      OneTimeByIdModels(
        success: json["success"] ?? false,
        message: json["message"] ?? '',
        data: json["data"] != null ? OneTimeData.fromJson(json["data"]) : null,
        meta: json["meta"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data?.toJson(),
        "meta": meta,
      };
}

class OneTimeData {
  String? id;
  UserId? userId;
  double? goldQty;
  double? totalAmountToPay;
  double? gstAmount;
  double? discountAmount;
  double? amountPaid;
  double? currentDayGoldPrice;
  String? redeemCode;
  String? status;
  String? razorpayOrderId;
  String? razorpayPaymentId;
  String? razorpaySignature;
  String? paymentStatus;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;
  ProfitLoss? profitLoss;
  String? username;
  String? customInvestmentId;

  OneTimeData({
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
    this.razorpayOrderId,
    this.razorpayPaymentId,
    this.razorpaySignature,
    this.paymentStatus,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.profitLoss,
    this.username,
    this.customInvestmentId,
  });

  factory OneTimeData.fromJson(Map<String, dynamic> json) => OneTimeData(
        id: json["_id"] ?? '',
        userId: json["userId"] != null ? UserId.fromJson(json["userId"]) : null,
        goldQty: (json["goldQty"] ?? 0).toDouble(),
        totalAmountToPay: (json["totalAmountToPay"] ?? 0).toDouble(),
        gstAmount: (json["gstAmount"] ?? 0).toDouble(),
        discountAmount: (json["discountAmount"] ?? 0).toDouble(),
        amountPaid: (json["amountPaid"] ?? 0).toDouble(),
        currentDayGoldPrice: (json["currentDayGoldPrice"] ?? 0).toDouble(),
        redeemCode: json["redeemCode"] ?? '',
        status: json["status"] ?? '',
        razorpayOrderId: json["razorpayOrderId"] ?? '',
        razorpayPaymentId: json["razorpayPaymentId"] ?? '',
        razorpaySignature: json["razorpaySignature"] ?? '',
        paymentStatus: json["paymentStatus"] ?? '',
        createdAt: json["createdAt"] != null
            ? DateTime.tryParse(json["createdAt"])
            : null,
        updatedAt: json["updatedAt"] != null
            ? DateTime.tryParse(json["updatedAt"])
            : null,
        v: json["__v"] ?? 0,
        profitLoss: json["profitLoss"] != null 
            ? ProfitLoss.fromJson(json["profitLoss"]) 
            : null,
        username: json["username"] ?? '',
        customInvestmentId: json["customInvestmentId"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "userId": userId?.toJson(),
        "goldQty": goldQty,
        "totalAmountToPay": totalAmountToPay,
        "gstAmount": gstAmount,
        "discountAmount": discountAmount,
        "amountPaid": amountPaid,
        "currentDayGoldPrice": currentDayGoldPrice,
        "redeemCode": redeemCode,
        "status": status,
        "razorpayOrderId": razorpayOrderId,
        "razorpayPaymentId": razorpayPaymentId,
        "razorpaySignature": razorpaySignature,
        "paymentStatus": paymentStatus,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
        "profitLoss": profitLoss?.toJson(),
        "username": username,
        "customInvestmentId": customInvestmentId,
      };
}

class ProfitLoss {
  double? currentValue;
  double? investedAmount;
  double? profitLoss;
  double? profitLossPercentage;
  bool? isProfitable;
  bool? canCalculate;
  double? currentGoldPrice;
  double? purchaseGoldPrice;
  double? goldQty;

  ProfitLoss({
    this.currentValue,
    this.investedAmount,
    this.profitLoss,
    this.profitLossPercentage,
    this.isProfitable,
    this.canCalculate,
    this.currentGoldPrice,
    this.purchaseGoldPrice,
    this.goldQty,
  });

  factory ProfitLoss.fromJson(Map<String, dynamic> json) => ProfitLoss(
        currentValue: json["currentValue"] != null 
            ? (json["currentValue"] as num).toDouble() 
            : 0.0,
        investedAmount: json["investedAmount"] != null 
            ? (json["investedAmount"] as num).toDouble() 
            : 0.0,
        profitLoss: json["profitLoss"] != null 
            ? (json["profitLoss"] as num).toDouble() 
            : 0.0,
        profitLossPercentage: json["profitLossPercentage"] != null 
            ? (json["profitLossPercentage"] as num).toDouble() 
            : 0.0,
        isProfitable: json["isProfitable"] ?? false,
        canCalculate: json["canCalculate"] ?? false,
        currentGoldPrice: json["currentGoldPrice"] != null 
            ? (json["currentGoldPrice"] as num).toDouble() 
            : 0.0,
        purchaseGoldPrice: json["purchaseGoldPrice"] != null 
            ? (json["purchaseGoldPrice"] as num).toDouble() 
            : 0.0,
        goldQty: json["goldQty"] != null 
            ? (json["goldQty"] as num).toDouble() 
            : 0.0,
      );

  Map<String, dynamic> toJson() => {
        "currentValue": currentValue,
        "investedAmount": investedAmount,
        "profitLoss": profitLoss,
        "profitLossPercentage": profitLossPercentage,
        "isProfitable": isProfitable,
        "canCalculate": canCalculate,
        "currentGoldPrice": currentGoldPrice,
        "purchaseGoldPrice": purchaseGoldPrice,
        "goldQty": goldQty,
      };
}

class UserId {
  String? id;
  String? name;

  UserId({
    this.id,
    this.name,
  });

  factory UserId.fromJson(Map<String, dynamic> json) => UserId(
        id: json["_id"] ?? '',
        name: json["name"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
      };
}