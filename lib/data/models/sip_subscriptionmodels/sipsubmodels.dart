import 'dart:convert';

SIPSubscriptionResponse sipSubscriptionResponseFromJson(String str) =>
    SIPSubscriptionResponse.fromJson(json.decode(str));

class SIPSubscriptionResponse {
  bool? success;
  String? message;
  Data? data;

  SIPSubscriptionResponse({this.success, this.message, this.data});

  factory SIPSubscriptionResponse.fromJson(Map<String, dynamic> json) =>
      SIPSubscriptionResponse(
        success: json["success"],
        message: json["message"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );
}

class Data {
  String? message;
  PlanPreview? planPreview;
  Razorpay? razorpay;

  Data({this.message, this.planPreview, this.razorpay});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        message: json["message"],
        planPreview: json["planPreview"] == null
            ? null
            : PlanPreview.fromJson(json["planPreview"]),
        razorpay:
            json["razorpay"] == null ? null : Razorpay.fromJson(json["razorpay"]),
      );
}

class PlanPreview {
  String? planName;
  num? investmentAmount;
  String? frequency;
  String? startDate;
  List<Installment>? installments;

  PlanPreview({
    this.planName,
    this.investmentAmount,
    this.frequency,
    this.startDate,
    this.installments,
  });

  factory PlanPreview.fromJson(Map<String, dynamic> json) => PlanPreview(
        planName: json["planName"],
        investmentAmount: json["investmentAmount"]?.toDouble(),
        frequency: json["frequency"],
        startDate: json["startDate"],
        installments: json["installments"] == null
            ? []
            : List<Installment>.from(
                json["installments"].map((x) => Installment.fromJson(x))),
      );
}

class Installment {
  int? installmentNumber;
  String? dueDate;
  num? baseAmount;
  num? gstPercent;
  num? gstAmount;
  num? totalAmount;
  String? status;

  Installment({
    this.installmentNumber,
    this.dueDate,
    this.baseAmount,
    this.gstPercent,
    this.gstAmount,
    this.totalAmount,
    this.status,
  });

  factory Installment.fromJson(Map<String, dynamic> json) => Installment(
        installmentNumber: json["installmentNumber"],
        dueDate: json["dueDate"],
        baseAmount: (json["baseAmount"] as num?)?.toDouble(),
        gstPercent: (json["gstPercent"] as num?)?.toDouble(),
        gstAmount: (json["gstAmount"] as num?)?.toDouble(),
        totalAmount: (json["totalAmount"] as num?)?.toDouble(),
        status: json["status"],
      );
}

class Razorpay {
  String? planId;
  String? subscriptionId;
  String? shortUrl;
  String? status;

  Razorpay({
    this.planId,
    this.subscriptionId,
    this.shortUrl,
    this.status,
  });

  factory Razorpay.fromJson(Map<String, dynamic> json) => Razorpay(
        planId: json["planId"],
        subscriptionId: json["subscriptionId"],
        shortUrl: json["shortUrl"],
        status: json["status"],
      );
}
