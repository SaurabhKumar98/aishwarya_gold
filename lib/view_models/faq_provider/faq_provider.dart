import 'package:aishwarya_gold/data/models/settingmodels/faqmodels.dart';
import 'package:aishwarya_gold/data/repo/settingrepo/faq_repo/faq_repo.dart';
import 'package:flutter/foundation.dart';

class FaqProvider with ChangeNotifier {
  final FaqRepo _repo = FaqRepo();

  bool _isLoading = false;
  FaqModels? _faqData;
  String? _errorMessage;
  String _searchQuery = '';
  List<FaqData> _filteredFaqs = [];

  // Getters
  bool get isLoading => _isLoading;
  FaqModels? get faqData => _faqData;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  List<FaqData> get faqs => _searchQuery.isEmpty ? (_faqData?.data ?? []) : _filteredFaqs;

  /// Fetch FAQs from API
  Future<void> fetchFaqs() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repo.getFaq();
      _faqData = result;
      _filteredFaqs = _faqData?.data ?? [];
    } catch (e) {
      _errorMessage = e.toString();
      if (kDebugMode) {
        print("Error fetching FAQs: $_errorMessage");
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Search/filter FAQs by question or tag
  void searchFAQs(String query) {
    _searchQuery = query;
    if (_faqData != null && query.isNotEmpty) {
      _filteredFaqs = _faqData!.data
          .where((faq) =>
              faq.question.toLowerCase().contains(query.toLowerCase()) ||
              faq.tag.toLowerCase().contains(query.toLowerCase()))
          .toList();
    } else {
      _filteredFaqs = _faqData?.data ?? [];
    }
    notifyListeners();
  }

  /// Clear search
  void clearSearch() {
    _searchQuery = '';
    _filteredFaqs = _faqData?.data ?? [];
    notifyListeners();
  }

  /// Refresh FAQs manually
  Future<void> refreshFaqs() async {
    await fetchFaqs();
  }
}
