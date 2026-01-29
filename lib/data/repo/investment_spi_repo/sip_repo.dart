class SipRepository {
  final double goldPrice;

  SipRepository({required this.goldPrice});

  double calculateGrams(double amount) => amount / goldPrice;

  double calculateAnnualInvestment(double amount, int frequencyIndex) {
    // 0 = daily, 1 = weekly, 2 = monthly
    if (frequencyIndex == 0) return amount * 365;
    if (frequencyIndex == 1) return amount * 52;
    return amount * 12;
  }
}
