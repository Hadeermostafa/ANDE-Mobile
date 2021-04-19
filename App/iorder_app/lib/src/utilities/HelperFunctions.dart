import 'package:ande_app/src/data_providers/models/LanguageModel.dart';
import 'package:ande_app/src/data_providers/models/product/ProductCategoryViewModel.dart';
import 'package:ande_app/src/resources/external_resource/AndeImageNetwork.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
class DirectionalityHelper {
  static TextDirection getDirectionalityForLocale(
      BuildContext context, Locale locale) {
    return intl.Bidi.isRtlLanguage(locale.languageCode)
        ? TextDirection.rtl
        : TextDirection.ltr;
  }
}

class ImageHelper {
  static Widget getImage(String url) {
    return AndeImageNetwork(url, constrained: true, height: 60, width: 60,);
  }

}


class LanguageHelper {
  static List<LanguageModel> getSystemLanguages() {
    return [
      LanguageModel(
          localeName: 'English',
          localeCode: 'en',
          imageUrl: ''),
      LanguageModel(
          localeName: 'العربيه',
          localeCode: 'ar',
          imageUrl: ''),
    ];
  }

  static LanguageModel getLangModelFromLocaleCode(String local) {
    try {
      return getSystemLanguages()
          .where((lang) => lang.localeCode == local)
          .toList()[0];
    } catch (ex) {
      return getSystemLanguages()[0];
    }
  }
}

class ParseHelper {
  static dynamic parseNumber(number, {bool toDouble}) {

    toDouble = toDouble ?? false;

    if(number == null || number == "null" || number == '')
      return 0.0;

    if (number is String) {
      if (number.contains('.')) {
        double parsedNumber = double.tryParse(number);
        return toDouble ? double.parse((parsedNumber * 1.0).toStringAsFixed(2)) : parsedNumber.round();
      } else {
        int parsedNumber = int.tryParse(number);
        return toDouble ? double.parse((parsedNumber * 1.0).toStringAsFixed(2)) * 1.0 : parsedNumber;
      }
    } else {
      return toDouble ? double.parse((number * 1.0).toStringAsFixed(2)) : number;
    }
  }
}

class UIHelper {

  static String getCategoriesAsList(List<ProductCategoryViewModel> categories){
    List<String> kitchensList = List();
    if(categories == null || categories.isEmpty) return "";

    for(int i = 0 ; i < categories.length ; i++){
      if(categories[i].categoryId != '-1'){
        kitchensList.add(categories[i].categoryName);
      }
    }
    return kitchensList.join(',');
  }


}