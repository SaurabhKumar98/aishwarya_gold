import 'package:aishwarya_gold/core/storage/sharedpreference.dart';
import 'package:aishwarya_gold/utils/exports/exports.dart';
import 'package:aishwarya_gold/view_models/downloadStatementprovider/downloadStatementProvider.dart';
import 'package:aishwarya_gold/view_models/gift_rec_provider/giftData_provider.dart';
import 'package:aishwarya_gold/view_models/invest_provider/inverst_provider.dart';
import 'package:aishwarya_gold/view_models/reedemption_provider/reedemption_provider.dart';
import 'package:flutter/material.dart';
import 'package:aishwarya_gold/view_models/profile_provider/edit_profile_provider.dart';
import 'package:aishwarya_gold/view_models/profile_provider/profiledetails_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Centralized class for clearing all provider & local data during logout.
class ProviderCleaner {
  static Future<void> clearAll(BuildContext context) async {
    try {
      Provider.of<EditProfileProvider>(context, listen: false).clearData();
      Provider.of<ProfiledetailsProvider>(context, listen: false).clearProfileData();
      Provider.of<InvestmentProvider>(context, listen: false).clearAllData();
      Provider.of<OnetimeSavingProvider>(context, listen: false).clearData();
      Provider.of<SipSavingProvider>(context, listen: false).clearData();
      Provider.of<AgSavingProvider>(context, listen: false).clear();
      Provider.of<HistoryProvider>(context, listen: false).clearData();
      Provider.of<DownloadStatementProvider>(context, listen: false).clearData();
      Provider.of<GiftsProvider>(context, listen: false).clearGifts();

      // ✅ ONLY this for redemption
      await context.read<RedemptionProvider>().clearOnLogout();

      // ✅ Clear session keys only
      await SessionManager.clearAllPrefs();

      debugPrint("✅ All providers and session data cleared on logout.");
    } catch (e) {
      debugPrint("⚠️ Error clearing provider data: $e");
    }
  }
}
