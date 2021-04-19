import 'package:ande_app/src/utilities/ApiParseKeys.dart';

class CurrencyModel {

  String currencyName , currencyCode ;
  CurrencyModel({this.currencyCode , this.currencyName});

  static CurrencyModel fromJson(Map<String,dynamic> currencyMap){
    return CurrencyModel(
      currencyCode: currencyMap[ApiParseKeys.CURRENCY_CODE],
      currencyName: currencyMap[ApiParseKeys.CURRENCY_NAME],
    );
  }


}