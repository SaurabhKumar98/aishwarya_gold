// To parse this JSON data, do
//
//     final pauseModelsSip = pauseModelsSipFromJson(jsonString);

import 'dart:convert';

PauseModelsSip pauseModelsSipFromJson(String str) => PauseModelsSip.fromJson(json.decode(str));

String pauseModelsSipToJson(PauseModelsSip data) => json.encode(data.toJson());

class PauseModelsSip {
    bool success;
    String message;
    PauseData data;
    dynamic meta;

    PauseModelsSip({
        required this.success,
        required this.message,
        required this.data,
        required this.meta,
    });

    factory PauseModelsSip.fromJson(Map<String, dynamic> json) => PauseModelsSip(
        success: json["success"],
        message: json["message"],
        data: PauseData.fromJson(json["data"]),
        meta: json["meta"],
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data.toJson(),
        "meta": meta,
    };
}

class PauseData {
    dynamic resumedAt;
    String id;
    String userId;
    String planName;
    int investmentAmount;
    String frequency;
    DateTime startDate;
    DateTime nextExecutionDate;
    DateTime endDate;
    int totalInvested;
    int totalGoldAccumulated;
    String status;
    List<Installment> installments;
    List<Transaction> transactions;
    String razorpaySubscriptionId;
    String razorpayPlanId;
    String subscriptionStatus;
    DateTime subscriptionStartDate;
    DateTime subscriptionEndDate;
    dynamic subscriptionCurrentStart;
    dynamic subscriptionCurrentEnd;
    int subscriptionQuantity;
    DateTime createdAt;
    DateTime updatedAt;
    int v;
    int pauseDurationMonths;
    DateTime pauseEndDate;
    DateTime pausedAt;
    String message;

    PauseData({
        required this.resumedAt,
        required this.id,
        required this.userId,
        required this.planName,
        required this.investmentAmount,
        required this.frequency,
        required this.startDate,
        required this.nextExecutionDate,
        required this.endDate,
        required this.totalInvested,
        required this.totalGoldAccumulated,
        required this.status,
        required this.installments,
        required this.transactions,
        required this.razorpaySubscriptionId,
        required this.razorpayPlanId,
        required this.subscriptionStatus,
        required this.subscriptionStartDate,
        required this.subscriptionEndDate,
        required this.subscriptionCurrentStart,
        required this.subscriptionCurrentEnd,
        required this.subscriptionQuantity,
        required this.createdAt,
        required this.updatedAt,
        required this.v,
        required this.pauseDurationMonths,
        required this.pauseEndDate,
        required this.pausedAt,
        required this.message,
    });

    factory PauseData.fromJson(Map<String, dynamic> json) => PauseData(
        resumedAt: json["resumedAt"],
        id: json["_id"],
        userId: json["userId"],
        planName: json["planName"],
        investmentAmount: json["investmentAmount"],
        frequency: json["frequency"],
        startDate: DateTime.parse(json["startDate"]),
        nextExecutionDate: DateTime.parse(json["nextExecutionDate"]),
        endDate: DateTime.parse(json["endDate"]),
        totalInvested: json["totalInvested"],
        totalGoldAccumulated: json["totalGoldAccumulated"],
        status: json["status"],
        installments: List<Installment>.from(json["installments"].map((x) => Installment.fromJson(x))),
        transactions: List<Transaction>.from(json["transactions"].map((x) => Transaction.fromJson(x))),
        razorpaySubscriptionId: json["razorpaySubscriptionId"],
        razorpayPlanId: json["razorpayPlanId"],
        subscriptionStatus: json["subscriptionStatus"],
        subscriptionStartDate: DateTime.parse(json["subscriptionStartDate"]),
        subscriptionEndDate: DateTime.parse(json["subscriptionEndDate"]),
        subscriptionCurrentStart: json["subscriptionCurrentStart"],
        subscriptionCurrentEnd: json["subscriptionCurrentEnd"],
        subscriptionQuantity: json["subscriptionQuantity"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
        v: json["__v"],
        pauseDurationMonths: json["pauseDurationMonths"],
        pauseEndDate: DateTime.parse(json["pauseEndDate"]),
        pausedAt: DateTime.parse(json["pausedAt"]),
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "resumedAt": resumedAt,
        "_id": id,
        "userId": userId,
        "planName": planName,
        "investmentAmount": investmentAmount,
        "frequency": frequency,
        "startDate": startDate.toIso8601String(),
        "nextExecutionDate": nextExecutionDate.toIso8601String(),
        "endDate": endDate.toIso8601String(),
        "totalInvested": totalInvested,
        "totalGoldAccumulated": totalGoldAccumulated,
        "status": status,
        "installments": List<dynamic>.from(installments.map((x) => x.toJson())),
        "transactions": List<dynamic>.from(transactions.map((x) => x.toJson())),
        "razorpaySubscriptionId": razorpaySubscriptionId,
        "razorpayPlanId": razorpayPlanId,
        "subscriptionStatus": subscriptionStatus,
        "subscriptionStartDate": subscriptionStartDate.toIso8601String(),
        "subscriptionEndDate": subscriptionEndDate.toIso8601String(),
        "subscriptionCurrentStart": subscriptionCurrentStart,
        "subscriptionCurrentEnd": subscriptionCurrentEnd,
        "subscriptionQuantity": subscriptionQuantity,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
        "__v": v,
        "pauseDurationMonths": pauseDurationMonths,
        "pauseEndDate": pauseEndDate.toIso8601String(),
        "pausedAt": pausedAt.toIso8601String(),
        "message": message,
    };
}

class Installment {
    int installmentNumber;
    DateTime dueDate;
    int baseAmount;
    int gstPercent;
    double gstAmount;
    double totalAmount;
    Status status;
    DateTime? paidAt;
    String? razorpayOrderId;
    String? razorpayPaymentId;
    String? razorpaySignature;
    dynamic orderCreatedAt;
    String id;

    Installment({
        required this.installmentNumber,
        required this.dueDate,
        required this.baseAmount,
        required this.gstPercent,
        required this.gstAmount,
        required this.totalAmount,
        required this.status,
        required this.paidAt,
        required this.razorpayOrderId,
        required this.razorpayPaymentId,
        required this.razorpaySignature,
        required this.orderCreatedAt,
        required this.id,
    });

    factory Installment.fromJson(Map<String, dynamic> json) => Installment(
        installmentNumber: json["installmentNumber"],
        dueDate: DateTime.parse(json["dueDate"]),
        baseAmount: json["baseAmount"],
        gstPercent: json["gstPercent"],
        gstAmount: json["gstAmount"]?.toDouble(),
        totalAmount: json["totalAmount"]?.toDouble(),
        status: statusValues.map[json["status"]]!,
        paidAt: json["paidAt"] == null ? null : DateTime.parse(json["paidAt"]),
        razorpayOrderId: json["razorpayOrderId"],
        razorpayPaymentId: json["razorpayPaymentId"],
        razorpaySignature: json["razorpaySignature"],
        orderCreatedAt: json["orderCreatedAt"],
        id: json["_id"],
    );

    Map<String, dynamic> toJson() => {
        "installmentNumber": installmentNumber,
        "dueDate": dueDate.toIso8601String(),
        "baseAmount": baseAmount,
        "gstPercent": gstPercent,
        "gstAmount": gstAmount,
        "totalAmount": totalAmount,
        "status": statusValues.reverse[status],
        "paidAt": paidAt?.toIso8601String(),
        "razorpayOrderId": razorpayOrderId,
        "razorpayPaymentId": razorpayPaymentId,
        "razorpaySignature": razorpaySignature,
        "orderCreatedAt": orderCreatedAt,
        "_id": id,
    };
}

enum Status {
    PAID,
    PENDING
}

final statusValues = EnumValues({
    "PAID": Status.PAID,
    "PENDING": Status.PENDING
});

class Transaction {
    DateTime date;
    int goldPricePerGram;
    int investedAmount;
    int goldBoughtInGram;
    String id;

    Transaction({
        required this.date,
        required this.goldPricePerGram,
        required this.investedAmount,
        required this.goldBoughtInGram,
        required this.id,
    });

    factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        date: DateTime.parse(json["date"]),
        goldPricePerGram: json["goldPricePerGram"],
        investedAmount: json["investedAmount"],
        goldBoughtInGram: json["goldBoughtInGram"],
        id: json["_id"],
    );

    Map<String, dynamic> toJson() => {
        "date": date.toIso8601String(),
        "goldPricePerGram": goldPricePerGram,
        "investedAmount": investedAmount,
        "goldBoughtInGram": goldBoughtInGram,
        "_id": id,
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
