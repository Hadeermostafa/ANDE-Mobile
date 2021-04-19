import 'package:ande_app/src/utilities/HelperFunctions.dart';

class PromoCodeViewModel {
  String promoCodeTitle;
  double discountValue;

  PromoCodeViewModel({this.promoCodeTitle, this.discountValue});

  static PromoCodeViewModel fromJson(Map<String, dynamic> json){
    return PromoCodeViewModel(
      promoCodeTitle: json[PromoCodeViewModelJsonKeys.PROMO_CODE_TITLE] ?? '',
      discountValue: ParseHelper.parseNumber(json[PromoCodeViewModelJsonKeys.PROMO_CODE_DISCOUNT_VALUE], toDouble: true),
    );
  }
}

class PromoCodeViewModelJsonKeys {
  static const String PROMO_CODE_TITLE = 'code';
  static const String PROMO_CODE_DISCOUNT_VALUE = 'discounted_value';
}