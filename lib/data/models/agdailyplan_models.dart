class AgDailyPlanModel {
  final String planId;
  final int dailyAmount;
  final int month;
  final double year;
  final double profitBonus;
  final double maturityAmount;
  final String goldGift;

  AgDailyPlanModel({
    required this.planId,
    required this.dailyAmount,
    required this.month,
    required this.year,
    required this.profitBonus,
    required this.maturityAmount,
    required this.goldGift,
  });

  factory AgDailyPlanModel.fromMap(Map<String, dynamic> map) {
    return AgDailyPlanModel(
      planId: map['planId']?.toString() ?? '',
      dailyAmount: _toInt(map['dailyAmount']),
      month: _toInt(map['month']),
      year: _toDouble(map['year']),
      profitBonus: _toDouble(map['profitBonus']),
      maturityAmount: _toDouble(map['maturityAmount']),
      goldGift: map['goldGift']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'planId': planId,
        'dailyAmount': dailyAmount,
        'month': month,
        'year': year,
        'profitBonus': profitBonus,
        'maturityAmount': maturityAmount,
        'goldGift': goldGift,
      };

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  static double _toDouble(dynamic v) {
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0.0;
    return 0.0;
  }
}