enum TimePeriod {
  oneMonth(label: '1M', days: 30),
  threeMonths(label: '3M',days: 90),
  sixMonths(label: '6M', days: 180),
  oneYear(label: '1Y', days: 365);

  final String label;
  final int days;

  const TimePeriod({required this.label, required this.days});
}

class GoldPriceData {
  final DateTime timestamp;
  final double price;

  GoldPriceData({required this.timestamp, required this.price});

  factory GoldPriceData.fromJson(Map<String, dynamic> json) {
    final date = json['date'];
    if (date == null || date is! String) {
      throw Exception('Invalid or missing "date" field in JSON');
    }
    return GoldPriceData(
      timestamp: DateTime.parse(date),
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class GoldPriceStats {
  final double currentPrice;
  final double highPrice;
  final double lowPrice;
  final double openPrice;
  final double changeAmount;
  final double changePercent;

  GoldPriceStats({
    required this.currentPrice,
    required this.highPrice,
    required this.lowPrice,
    required this.openPrice,
    required this.changeAmount,
    required this.changePercent,
  });

  factory GoldPriceStats.fromPriceList(List<GoldPriceData> prices) {
    if (prices.isEmpty) {
      return GoldPriceStats(
        currentPrice: 0.0,  // Explicit double literal
        highPrice: 0.0,
        lowPrice: 0.0,
        openPrice: 0.0,
        changeAmount: 0.0,
        changePercent: 0.0,
      );
    }
    final currentPrice = prices.last.price;
    final highPrice = (prices.map((p) => p.price).reduce((a, b) => a > b ? a : b)) as double;  // Explicit cast
    final lowPrice = (prices.map((p) => p.price).reduce((a, b) => a < b ? a : b)) as double;   // Explicit cast
    final openPrice = prices.first.price;
    final changeAmount = currentPrice - openPrice;
    final changePercent = openPrice != 0.0 ? ((changeAmount / openPrice) * 100.0) as double : 0.0;  // Explicit double

    return GoldPriceStats(
      currentPrice: currentPrice,
      highPrice: highPrice,
      lowPrice: lowPrice,
      openPrice: openPrice,
      changeAmount: changeAmount,
      changePercent: changePercent,
    );
  }
}