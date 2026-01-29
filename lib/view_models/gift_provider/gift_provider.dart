// lib/providers/gift_provider.dart

import 'package:aishwarya_gold/data/repo/gift_repo/send_gigt_repo.dart';
import 'package:flutter/material.dart';
import 'package:aishwarya_gold/data/models/giftmodels/send_giftmodels.dart';
import 'package:aishwarya_gold/data/models/giftmodels/giftmodels_myself.dart';

class GiftProvider with ChangeNotifier {
  final GiftRepository repository;

  GiftProvider({required this.repository});

  bool _isLoading = false;
  String? _message;

  bool get isLoading => _isLoading;
  String? get message => _message;

  /// ✅ Send gift to someone else
  Future<bool> sendGift(GiftRequest request) async {
    _isLoading = true;
    _message = null;
    notifyListeners();

    try {
      print("🎁 [GiftProvider] Sending Gift Request → ${request.toJson()}");

      final response = await repository.createGift(request);

      print("✅ [GiftProvider] Gift Response → ${response.toJson()}");

      _message = response.message ?? "Gift sent successfully!";
      return response.success;
    } catch (e, stackTrace) {
      print("❌ [GiftProvider] Error → $e");
      print(stackTrace);
      _message = 'Error: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ✅ Send gift to self
  Future<bool> sendMySelfGift(MySelfGiftRequest request) async {
    _isLoading = true;
    _message = null;
    notifyListeners();

    try {
      print("🎁 [GiftProvider] Sending MySelf Gift → ${request.toJson()}");

      final response = await repository.createMySelfGift(request);

      print("✅ [GiftProvider] MySelf Gift Response → ${response.toJson()}");

      _message = response.message ?? "Gift (Myself) created successfully!";
      return response.success;
    } catch (e, stackTrace) {
      print("❌ [GiftProvider] MySelf Error → $e");
      print(stackTrace);
      _message = 'Error: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
