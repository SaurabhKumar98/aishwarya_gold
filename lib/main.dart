import 'package:aishwarya_gold/core/session/firebaseNotificationMessaging.dart';
import 'package:aishwarya_gold/data/repo/gift_repo/send_gigt_repo.dart';
import 'package:aishwarya_gold/utils/exports/exports.dart';
import 'package:aishwarya_gold/view_models/changepin_provider/changepin_provider.dart';
import 'package:aishwarya_gold/view_models/downloadStatementprovider/downloadStatementProvider.dart';
import 'package:aishwarya_gold/view_models/faq_provider/faq_provider.dart';
import 'package:aishwarya_gold/view_models/gift_provider/gift_provider.dart';
import 'package:aishwarya_gold/view_models/gift_rec_provider/giftData_provider.dart';
import 'package:aishwarya_gold/view_models/goldsummaryprovider/goldsummaryprovider.dart';
import 'package:aishwarya_gold/view_models/nominee_provider/nominee_details_provider.dart';
import 'package:aishwarya_gold/view_models/nominee_provider/nominee_provider.dart';
import 'package:aishwarya_gold/view_models/notification_provider/notification_provider.dart';
import 'package:aishwarya_gold/view_models/pauseagplan_provider/pauseagplan_provider.dart';
import 'package:aishwarya_gold/view_models/pausesip_provider/pausesip_provider.dart';
import 'package:aishwarya_gold/view_models/payment_faield_provider.dart/agplan_paymentfailed.dart';
import 'package:aishwarya_gold/view_models/payment_faield_provider.dart/sippaymentfailed_provider.dart';
import 'package:aishwarya_gold/view_models/profile_provider/edit_profile_provider.dart';
import 'package:aishwarya_gold/view_models/profile_provider/profiledetails_provider.dart';
import 'package:aishwarya_gold/view_models/redeemcode_provider/cancelredeemcodeprovider.dart';
import 'package:aishwarya_gold/view_models/redeemcode_provider/redeem_code_provider.dart';
import 'package:aishwarya_gold/view_models/reedemption_provider/reedemption_provider.dart';
import 'package:aishwarya_gold/view_models/refferandearn/refferearn_provider.dart';
import 'package:aishwarya_gold/view_models/sipsubscription_provider/sipsubscription_provider.dart';
import 'package:aishwarya_gold/view_models/store_provider/store_provider.dart';
import 'package:aishwarya_gold/view_models/supportmessage_provider/chatmessage_provider.dart';
import 'package:aishwarya_gold/view_models/video_provider/video_provider.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(); // IMPORTANT

  await initMessaging(); // AFTER Firebase init

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => OtpProvider()),
        ChangeNotifierProvider(create: (_) => GoldProvider()),
        ChangeNotifierProvider(create: (_) => InvestmentProvider()),
        ChangeNotifierProvider(create: (_) => KycStatusProvider()),
        ChangeNotifierProvider(create: (_) => HistoryProvider()),
        ChangeNotifierProvider(create: (_) => AgPlanProvider()),
        ChangeNotifierProvider(create: (_) => GoldPriceProvider()),
        ChangeNotifierProvider(create: (_) => LoginProvider()),
        ChangeNotifierProvider(create: (_) => RegistrationProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => RazorpayProvider()),
        ChangeNotifierProvider(create: (_) => SipSavingProvider()),
        ChangeNotifierProvider(create: (_) => OnetimeSavingProvider()),
        ChangeNotifierProvider(create: (_) => AgSavingProvider()),
        ChangeNotifierProvider(create: (_) => PauseAgPlanProvider()),
        ChangeNotifierProvider(create: (_) => EditProfileProvider()),
        ChangeNotifierProvider(create: (_) => ProfiledetailsProvider()),
        ChangeNotifierProvider(create: (_) => NomineeProvider()),
        ChangeNotifierProvider(create: (_) => NomineeDetailsProvider()),
        ChangeNotifierProvider(
          create: (_) => GiftProvider(repository: GiftRepository()),
        ),
        ChangeNotifierProvider(create: (_) => GiftsProvider()),
        ChangeNotifierProvider(create: (_) => FaqProvider()),
        ChangeNotifierProvider(create: (_) => StoreProvider()),
        ChangeNotifierProvider(create: (_) => SocketChatProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => RedeemCodeProvider()),
        ChangeNotifierProvider(create: (_) => GoldPriceSummaryProvider()),
        ChangeNotifierProvider(create: (_) => RefferAndEarnProvider()),
        ChangeNotifierProvider(create: (_) => ChangePinProvider()),
        ChangeNotifierProvider(create: (_) => RedemptionProvider()),
        ChangeNotifierProvider(create: (_) => PauseSipProvider()),
        ChangeNotifierProvider(create: (_) => SipsubscriptionProvider()),
        ChangeNotifierProvider(create: (_) => DownloadStatementProvider()),
        ChangeNotifierProvider(create: (_) => SipRetryPaymentProvider()),
        ChangeNotifierProvider(create: (_) => AgRetryPaymentProvider()),
        ChangeNotifierProvider(create: (_) => VideoProvider()),
        ChangeNotifierProvider(create: (_) => GiftCancelProvider()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(411.42857142857144, 867.4285714285714),
        builder: (context, child) => MaterialApp(
          title: 'Aishwarya Gold',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
            useMaterial3: true,
          ),
          home: const SplashScreen(),
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
