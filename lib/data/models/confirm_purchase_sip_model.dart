class SipPurchaseModel {
  final String planType;       // Daily / Weekly / Monthly
  final DateTime startDate;
  final DateTime nextDueDate;
  final double amount;         // This installment
  final double accumulated;    // Total accumulated till now
  final String? orderId;

  SipPurchaseModel({
    required this.planType,
    required this.startDate,
    required this.nextDueDate,
    required this.amount,
    required this.accumulated,
   this.orderId,
  });

  /// Optional: convert from JSON
  factory SipPurchaseModel.fromJson(Map<String, dynamic> json) {
    return SipPurchaseModel(
      planType: json['planType'] ?? '',
      startDate: DateTime.parse(json['startDate']),
      nextDueDate: DateTime.parse(json['nextDueDate']),
      amount: (json['amount'] ?? 0).toDouble(),
      accumulated: (json['accumulated'] ?? 0).toDouble(),
      orderId: json['orderId']?.toString(),
    );
  }

  /// Optional: convert to JSON
  Map<String, dynamic> toJson() => {
        'planType': planType,
        'startDate': startDate.toIso8601String(),
        'nextDueDate': nextDueDate.toIso8601String(),
        'amount': amount,
        'accumulated': accumulated,
        'orderId': orderId,
      };
}
