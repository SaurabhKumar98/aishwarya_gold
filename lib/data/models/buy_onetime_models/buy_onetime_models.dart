class OneTimeInvestmentBuyRequest {
  final double goldQty;
  final double totalAmountToPay;
  final double gstAmount;
  final double discountAmount;
  final double amountPaid;
  final double currentDayGoldPrice;
  final String redeemCode;

  OneTimeInvestmentBuyRequest({
    required this.goldQty,
    required this.totalAmountToPay,
    required this.gstAmount,
    required this.discountAmount,
    required this.amountPaid,
    required this.currentDayGoldPrice,
    required this.redeemCode,
  });

  Map<String, dynamic> toJson() {
    return {
      "goldQty": goldQty,
      "totalAmountToPay": totalAmountToPay,
      "gstAmount": gstAmount,
      "discountAmount": discountAmount,
      "amountPaid": amountPaid,
      "currentDayGoldPrice": currentDayGoldPrice,
      "redeemCode": redeemCode,
    };
  }
}
