import 'package:aishwarya_gold/data/models/gold_price_trend_models.dart';
import 'package:aishwarya_gold/res/constants/app_color.dart';
import 'package:aishwarya_gold/view_models/goldpricetrendprovider/gold_price_trend_provider.dart';
import 'package:aishwarya_gold/view_models/goldsummaryprovider/goldsummaryprovider.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class GoldPriceTrendScreen extends StatefulWidget {
  const GoldPriceTrendScreen({Key? key}) : super(key: key);

  @override
  State<GoldPriceTrendScreen> createState() => _GoldPriceTrendScreenState();
}

class _GoldPriceTrendScreenState extends State<GoldPriceTrendScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );

    // Initialize data
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context
          .read<GoldPriceProvider>()
          .initialize(); // 👈 load default 1-month data
      _animationController.forward();
      await context.read<GoldPriceSummaryProvider>().fetchGoldPriceSummary();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _changePeriod(TimePeriod period) {
    context.read<GoldPriceProvider>().changePeriod(period);
    _animationController.reset();
    _animationController.forward();
  }

  String _formatDate(DateTime date, TimePeriod period) {
    switch (period) {
      // case TimePeriod.oneDay:
      //   return DateFormat('HH:mm').format(date);
      // case TimePeriod.oneWeek:
      //   return DateFormat('E').format(date);
      case TimePeriod.oneMonth:
        return DateFormat('d MMM').format(date);
      case TimePeriod.threeMonths:
        return DateFormat('d MMM').format(date);
      case TimePeriod.sixMonths:
      case TimePeriod.oneYear:
        return DateFormat('MMM').format(date);
      // case TimePeriod.threeYears:
      // case TimePeriod.fiveYears:
      //   return DateFormat('MMM yy').format(date);
      default:
        return DateFormat('MMM').format(date);
    }
  }

  Widget _buildPeriodSelector(GoldPriceProvider provider) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: TimePeriod.values.map((period) {
          bool isSelected = provider.selectedPeriod == period;
          return Expanded(
            child: GestureDetector(
              onTap: () => _changePeriod(period),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFB8860B)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  period.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : Colors.grey.shade600,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildChart(GoldPriceProvider provider) {
    if (provider.isLoading) {
      return Container(
        height: 320,
        decoration: BoxDecoration(
          color: const Color(0xFF0A0E27),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB8860B)),
          ),
        ),
      );
    }

    if (provider.error != null) {
      return Container(
        height: 320,
        decoration: BoxDecoration(
          color: const Color(0xFF0A0E27),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Error loading data: ${provider.error}',
                style: TextStyle(color: Colors.grey.shade400),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => provider.initialize(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final prices = provider.prices;
    if (prices.isEmpty) {
      return Container(
        height: 320,
        decoration: BoxDecoration(
          color: const Color(0xFF0A0E27),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            'No data available for ${provider.selectedPeriod.label}',
            style: TextStyle(color: Colors.grey.shade400),
          ),
        ),
      );
    }

    final spots = prices.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.price);
    }).toList();

    final minY = spots.isNotEmpty
        ? spots.map((s) => s.y).reduce((a, b) => a < b ? a : b)
        : 0.0;
    final maxY = spots.isNotEmpty
        ? spots.map((s) => s.y).reduce((a, b) => a > b ? a : b)
        : 100.0;
    final yRange = maxY - minY > 0 ? maxY - minY : 100.0;
    final yPadding = yRange * 0.1;

    return Container(
      height: 320,
      decoration: BoxDecoration(
        color: const Color(0xFF0A0E27),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.fromLTRB(8, 24, 16, 16),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, _) {
          return LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: yRange / 4,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.white.withOpacity(0.05),
                    strokeWidth: 1,
                  );
                },
              ),
              titlesData: FlTitlesData(
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 32,
                    interval: spots.length > 5 ? spots.length / 5 : 1,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= prices.length) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          _formatDate(
                            prices[index].timestamp,
                            provider.selectedPeriod,
                          ),
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: yRange / 3,
                    reservedSize: 48,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '₹${(value / 1000).toStringAsFixed(1)}k',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              minX: 0,
              maxX: (spots.length - 1).toDouble(),
              minY: minY - yPadding,
              maxY: maxY + yPadding,
              lineTouchData: LineTouchData(
                enabled: true,
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots
                        .map((spot) {
                          final index = spot.x.toInt();
                          if (index >= prices.length) return null;
                          return LineTooltipItem(
                            '₹${spot.y.toStringAsFixed(2)}\n${_formatDate(prices[index].timestamp, provider.selectedPeriod)}',
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          );
                        })
                        .whereType<LineTooltipItem>()
                        .toList();
                  },
                  tooltipBorder: const BorderSide(color: Colors.transparent),
                  tooltipPadding: const EdgeInsets.all(10),
                  tooltipMargin: 8,
                  // getTooltipColor: (_) => const Color(0xFF1E2139),
                  fitInsideHorizontally: true,
                  fitInsideVertically: true,
                ),
                handleBuiltInTouches: true,
                getTouchLineStart: (data, index) => 0,
                getTouchLineEnd: (data, index) => 0,
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: spots
                      .take((spots.length * _animation.value).round())
                      .toList(),
                  isCurved: true,
                  curveSmoothness: 0.3,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFB8860B)],
                  ),
                  barWidth: 2.5,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFFFFD700).withOpacity(0.2),
                        const Color(0xFFB8860B).withOpacity(0.05),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black87,
            size: 16,
          ),
        ),
        title: const Text(
          'Gold Price Chart',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<GoldPriceProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Current Price Card
                Consumer<GoldPriceSummaryProvider>(
                  builder: (context, goldProvider, _) {
                    // ---- Loading / Error handling ----
                    if (goldProvider.isLoading) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFB8860B), Color(0xFFDAA520)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFB8860B).withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          ),
                        ),
                      );
                    }

                    if (goldProvider.errorMessage != null) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFB8860B), Color(0xFFDAA520)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            "Error: ${goldProvider.errorMessage}",
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }

                    // ---- Data is ready ----
                    final price = goldProvider.currentPricePerGram;
                    final changeAmount = goldProvider.difference;
                    final changePercent = goldProvider.percentageChange;
                    final isPositive = goldProvider.difference >= 0;

                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFB8860B), Color(0xFFDAA520)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFB8860B).withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Current Gold Price',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Current Price
                          Text(
                            '₹${goldProvider.currentPricePerGram.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Change Row: Arrow + Amount + Percent
                          Row(
                            children: [
                              Icon(
                                isPositive
                                    ? Icons.arrow_upward_rounded
                                    : Icons.arrow_downward_rounded,
                                color: isPositive
                                    ? Colors.white
                                    : AppColors.primaryRed,
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '₹${goldProvider.difference.abs().toStringAsFixed(0)} '
                                '(${goldProvider.difference >= 0? '+' : ''}${goldProvider.percentageChange.toStringAsFixed(2)}%)',
                                style: TextStyle(
                                  color:  goldProvider.difference >= 0
                                      ? Colors.white
                                      : AppColors.primaryRed,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                // Period Selector
                _buildPeriodSelector(provider),
                const SizedBox(height: 20),
                // Chart
                _buildChart(provider),
              ],
            ),
          );
        },
      ),
    );
  }
}
