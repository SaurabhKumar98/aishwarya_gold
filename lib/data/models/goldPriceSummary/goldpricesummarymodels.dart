import 'dart:convert';

GoldPriceSummary goldPriceSummaryFromJson(String str) =>
    GoldPriceSummary.fromJson(json.decode(str));

String goldPriceSummaryToJson(GoldPriceSummary data) =>
    json.encode(data.toJson());

class GoldPriceSummary {
  final bool success;
  final String message;
  final Data? data;
  final dynamic meta;

  GoldPriceSummary({
    required this.success,
    required this.message,
    required this.data,
    this.meta,
  });

  factory GoldPriceSummary.fromJson(Map<String, dynamic> json) =>
      GoldPriceSummary(
        success: json["success"] ?? false,
        message: json["message"] ?? "",
        data: json["data"] != null ? Data.fromJson(json["data"]) : null,
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
  final num currentPrice;        // ✅ Changed from int → num
  final num previousPrice;       // ✅ Changed from int → num
  final num difference;          // ✅ Changed from int → num
  final double percentageChange;
  final String trend;

  Data({
    required this.currentPrice,
    required this.previousPrice,
    required this.difference,
    required this.percentageChange,
    required this.trend,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        currentPrice: (json["currentPrice"] ?? 0),
        previousPrice: (json["previousPrice"] ?? 0),
        difference: (json["difference"] ?? 0),
        percentageChange: (json["percentageChange"] ?? 0).toDouble(),
        trend: json["trend"] ?? "stable",
      );

  Map<String, dynamic> toJson() => {
        "currentPrice": currentPrice,
        "previousPrice": previousPrice,
        "difference": difference,
        "percentageChange": percentageChange,
        "trend": trend,
      };
}
