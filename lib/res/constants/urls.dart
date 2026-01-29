class AppUrl{
  // static const String localUrl="http://192.168.0.171:8000";

  //hosted
   static const String localUrl ="https://api.aishwaryagold.shop";
  //auth screen
  static const String loginUrl="$localUrl/user/send-otp";
  static const String otpverfUrl ="$localUrl/user/verify-otp";
  static const String register="$localUrl/user/register";

  //investment
  static const String monthlyAgPlan ="$localUrl/admin/agplans?type=monthly&page=1&limit=10";
  static const String buyagPlan ="$localUrl/user/agplans/verify";
  static const String changePin ="$localUrl/user/change-pin";
  static const String buysipPlan ="$localUrl/user/sip/userid/buy";
  static const String sipSavingPlan ="$localUrl/user/sip/";
  static const String buyOneTimePlan ="$localUrl/user/onetime/userid/verify";
  static const String onetimeSaving = "$localUrl/user/onetime/";
  static const String reedemonetime= "$localUrl/user/onetime/";
  static const String reedemsip ="$localUrl/user/sip/";
  static const String agplanbyid ="$localUrl/admin/agplans/";
  static const String gsturl ="$localUrl/user/gst-settings";
  //gold price
  static const String goldprice ="$localUrl/admin/goldprice";

  //saving
  static const String savingagPlan="$localUrl/user/agplans/";
  static const String pauseAgplan ="$localUrl/user/agplans/";
  static const String resumeAgPlan ="$localUrl/user/purchases/";

  //Setting Screen
  static const String kycverf="$localUrl/user/user/verification/";
  static const String kycreject ="$localUrl/user/user/kyc/";
  static const String editprofile ="$localUrl/user/user/profile";
  static const String profdet ="$localUrl/user/user/";
  static const String historyurl ="$localUrl/user/plans/";
  static const String nominee ="$localUrl/user/plans/";
  static const String nomineeDet ="$localUrl/user/nominee?userId=";
  static const String giftCard ="$localUrl/user/gift/verify";
  static const String recgift ="$localUrl/user/gift/my";
  static const String faq = "$localUrl/user/faqs";
  static const String store ="$localUrl/user/stores";
  static const String logout ="$localUrl/user/logout";
  static const String refferurl ="$localUrl/user/my-referral-code";
  static const String refferhistory ="$localUrl/user/my-referral-history";
  static const String agpruchase ="$localUrl/user/agplans/purchase/";

  //Notification
  static const String notification ="$localUrl/user/notifications";

  //redeem code 
  static const String redeem ="$localUrl/user/gift/redeem";

  //gold price summary
  static const String goldSumm ="$localUrl/admin/goldprice/summary";
  static const String createRedemption = '$localUrl/user/redemption-request';
  static const String getRedemption = '$localUrl/user/redemption-request';
  static const String getUserRedemptions = '$localUrl/user/redemption-request';
  static const String cancelRedemption = '$localUrl/user/redemption-request';
  static const String pausesip ="$localUrl/user/sip/";
  static const String videourl ="$localUrl/user/videos";
  
}