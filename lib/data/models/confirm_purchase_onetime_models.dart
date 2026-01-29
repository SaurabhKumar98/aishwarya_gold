class ConfirmPurchaseModel {
  final String goldWeight;       // e.g. "0.3912"
  final double goldPricePerGram; // e.g. 5400.50
  final double subtotal;         // goldPricePerGram * goldWeight
  final double gst;              // e.g. 3% of subtotal
  double totalWithGst;           // subtotal + gst - redeemDiscount
  double redeemDiscount;     // subtotal + gst

  ConfirmPurchaseModel({
    required this.goldWeight,
    required this.goldPricePerGram,
    required this.subtotal,
    required this.gst,
    required this.totalWithGst,
    this.redeemDiscount = 0.0,
  });

    void applyRedeemCode(String code) {
    // Example: define codes and their discount values
    Map<String, double> validCodes = {
      'AISW1234': 1000, // reduces ₹100
      'AISW5678': 500,  // reduces ₹50
    };

    if (validCodes.containsKey(code)) {
      redeemDiscount = validCodes[code]!;
      totalWithGst = subtotal + gst - redeemDiscount;
    } else {
      redeemDiscount = 0.0;
      totalWithGst = subtotal + gst;
    }
  }

  /// Optional: If you need to convert from JSON
  factory ConfirmPurchaseModel.fromJson(Map<String, dynamic> json) {
    return ConfirmPurchaseModel(
      goldWeight: json['goldWeight'] ?? '',
      goldPricePerGram: (json['goldPricePerGram'] ?? 0).toDouble(),
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      gst: (json['gst'] ?? 0).toDouble(),
      totalWithGst: (json['totalWithGst'] ?? 0).toDouble(),
    );
  }

  /// Optional: To send data to API
  Map<String, dynamic> toJson() => {
        'goldWeight': goldWeight,
        'goldPricePerGram': goldPricePerGram,
        'subtotal': subtotal,
        'gst': gst,
        'totalWithGst': totalWithGst,
      };
}