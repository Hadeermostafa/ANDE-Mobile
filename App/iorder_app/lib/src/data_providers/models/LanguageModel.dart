import 'package:ande_app/src/utilities/ApiParseKeys.dart';
import 'package:flutter/material.dart';
class LanguageModel {
  String localeCode, localeName, imageUrl;

  LanguageModel(
      {this.localeCode, this.localeName, this.imageUrl});

  static LanguageModel fromJson(Map<String, dynamic> mapJson) {
    return LanguageModel(
        localeName: mapJson[ApiParseKeys.LANGUAGE_NAME] ?? '',
        localeCode: mapJson[ApiParseKeys.LANGUAGE_CODE] ?? '',
        imageUrl: mapJson[ApiParseKeys.LANGUAGE_LOGO] ?? ''
    );
  }

  static List<LanguageModel> fromListJson(List<dynamic> countriesList) {
    List<LanguageModel> languages = List();
    try {
      for (int i = 0; i < countriesList.length; i++)
        languages.add(fromJson(countriesList[i]));
    } catch (exception) {
      debugPrint("Exception while parsing countries list");
    }
    return languages;
  }

  @override
  String toString() {
    return 'Locale name => $localeName , Locale code => $localeCode ';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LanguageModel &&
          runtimeType == other.runtimeType &&
          localeCode == other.localeCode &&
          localeName == other.localeName;

  @override
  int get hashCode => localeCode.hashCode ^ localeName.hashCode;

  static List<LanguageModel> fromCurrencyListJson(List<dynamic> currenciesRawResponse) {

    List<LanguageModel> languageModels = List<LanguageModel>();
    for(int i = 0 ; i < currenciesRawResponse.length ; i++){
      languageModels.add(LanguageModel(
        localeName: currenciesRawResponse[i]['sympol'],
        localeCode: currenciesRawResponse[i]['locale'],
      ));
    }
    return languageModels;

  }
}

class LanguageModelJsonKeys {
  static const String LANGUAGE_CODE = "locale";
  static const String LANGUAGE_NAME = "name";
  static const String LANGUAGE_ICON = "image";
  static const String LANGUAGE_ID = "id";
  static const String DIAL_CODE = "dial_code";
}
