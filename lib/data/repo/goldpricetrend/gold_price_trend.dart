import 'dart:convert';
import 'package:aishwarya_gold/data/models/gold_price_trend_models.dart';
import 'package:aishwarya_gold/res/constants/urls.dart';
import 'package:aishwarya_gold/utils/exports/exports.dart';
import 'package:http/http.dart' as http;

class GoldPriceRepository {
  static const String _baseUrl = '${AppUrl.localUrl}/admin/goldprice/stats';

  Future<List<GoldPriceData>> fetchGoldPrices(TimePeriod period) async {
    try {
      final now = DateTime.now();
      final startDate = now.subtract(Duration(days: period.days));
      final url =
          '$_baseUrl?startDate=${_formatDate(startDate)}&endDate=${_formatDate(now)}';
      debugPrint('Fetching gold prices from: $url');

      final response = await http.get(Uri.parse(url));

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body) as Map<String, dynamic>;

        if (jsonResponse['success'] == true && jsonResponse['data'] is List) {
          final List<dynamic> data = jsonResponse['data'];
          return data.map((e) => GoldPriceData.fromJson(e)).toList();
        } else {
          debugPrint('Invalid response format: success=${jsonResponse['success']}, data=${jsonResponse['data']}');
          return [];
        }
      } else {
        throw Exception('Failed to load gold prices (Status: ${response.statusCode})');
      }
    } catch (e) {
      debugPrint('Error fetching gold prices: $e');
      throw Exception('Error fetching gold prices: $e');
    }
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${_twoDigits(date.month)}-${_twoDigits(date.day)}";
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');
}