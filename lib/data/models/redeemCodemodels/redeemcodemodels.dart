class RedeemResponse {
  final bool success;
  final String message;
  final RedeemData? data;
  final dynamic meta;

  RedeemResponse({
    required this.success,
    required this.message,
    this.data,
    this.meta,
  });

  factory RedeemResponse.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return RedeemResponse(success: false, message: '', data: null, meta: null);
    }

    return RedeemResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: json['data'] != null
          ? RedeemData.fromJson(json['data'] as Map<String, dynamic>?)
          : null,
      meta: json['meta'],
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'message': message,
        'data': data?.toJson(),
        'meta': meta,
      };
}

class RedeemData {
  final bool giftRedeemed;
  final String? giftMessage;

  final bool referralRedeemed;
  final num? referralAmount;

  final PromoCodeResult? promoCodeResult;
  final String codeType;
  final num? giftValue;
  final String? message;

  RedeemData({
    required this.giftRedeemed,
    this.giftMessage,
    required this.referralRedeemed,
    this.referralAmount,
    this.promoCodeResult,
    required this.codeType,
    this.giftValue,
    this.message,
  });

  factory RedeemData.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return RedeemData(
        giftRedeemed: false,
        giftMessage: null,
        referralRedeemed: false,
        referralAmount: null,
        promoCodeResult: null,
        codeType: '',
        giftValue: null,
        message: null,
      );
    }

    return RedeemData(
      giftRedeemed: json['giftRedeemed'] == true,
      giftMessage: json['giftMessage']?.toString(),

      referralRedeemed: json['referralRedeemed'] == true,
      referralAmount: json['referralAmount'] is num
          ? json['referralAmount']
          : null,

      promoCodeResult: json['promoCodeResult'] != null
          ? PromoCodeResult.fromJson(
              json['promoCodeResult'] as Map<String, dynamic>?,
            )
          : null,
      codeType: json['codeType']?.toString() ?? '',
      giftValue: json['giftValue'] is num ? json['giftValue'] : null,
      message: json['message']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'giftRedeemed': giftRedeemed,
        'giftMessage': giftMessage,
        'referralRedeemed': referralRedeemed,
        'referralAmount': referralAmount,
        'promoCodeResult': promoCodeResult?.toJson(),
        'codeType': codeType,
        'giftValue': giftValue,
        'message': message,
      };
}

class PromoCodeResult {
  final String message;
  final Discount? discount;

  PromoCodeResult({
    required this.message,
    this.discount,
  });

  factory PromoCodeResult.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return PromoCodeResult(message: '', discount: null);
    }

    return PromoCodeResult(
      message: json['message']?.toString() ?? '',
      discount: json['discount'] != null
          ? Discount.fromJson(json['discount'] as Map<String, dynamic>?)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'message': message,
        'discount': discount?.toJson(),
      };
}

class Discount {
  final String type;
  final num value;

  Discount({
    required this.type,
    required this.value,
  });

  factory Discount.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return Discount(type: '', value: 0);
    }

    return Discount(
      type: json['type']?.toString() ?? '',
      value: json['value'] is num
          ? json['value']
          : num.tryParse(json['value']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'value': value,
      };
}