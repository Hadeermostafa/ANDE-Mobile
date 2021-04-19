
import 'package:ande_app/src/data_providers/models/delivery/CityViewModel.dart';
import 'package:ande_app/src/utilities/ApiParseKeys.dart';

class CountryModel {

  String countryId, countryName , countryDialCode , countryIconImagePath ;
  List<RegionViewModel> cities;

  CountryModel({this.countryId, this.countryName, this.countryDialCode,
      this.countryIconImagePath, this.cities});


  static fromListJson(List<dynamic> countries){

    List<CountryModel> countriesList = List<CountryModel>();
    for(int i = 0 ; i <countries.length  ; i++)
      countriesList.add(fromJson(countries[i]));
    return countriesList;
  }
  static CountryModel fromJson(Map<String,dynamic> country) {
    List<RegionViewModel> cities = [];
    if (country[ApiParseKeys.COUNTRY_REGIONS] != null) {
      cities = RegionViewModel.fromListJson(country[ApiParseKeys.COUNTRY_REGIONS]);
    }
    return CountryModel(
      countryDialCode: country[ApiParseKeys.COUNTRY_DIAL_CODE] ?? '',
      countryIconImagePath: country[ApiParseKeys.COUNTRY_ICON] ?? '',
      countryId: (country[ApiParseKeys.COUNTRY_ID] ?? '').toString(),
      countryName: country[ApiParseKeys.COUNTRY_NAME] ?? '',
      cities: cities,
    );
  }

  Map<String,dynamic> toJson() {
    List<Map> cities = this.cities != null ? this.cities.map((e) => e.toJson()).toList(): null;
    return {
      ApiParseKeys.COUNTRY_DIAL_CODE : this.countryDialCode ,
      ApiParseKeys.COUNTRY_ICON : this.countryIconImagePath,
      ApiParseKeys.COUNTRY_ID: this.countryId,
      ApiParseKeys.COUNTRY_NAME : this.countryName,
      ApiParseKeys.COUNTRY_REGIONS: cities,
    };
  }

  @override
  String toString() =>
      'CountryModel {countryId: $countryId, countryName: $countryName, countryDialCode: $countryDialCode, cities: $cities';

}