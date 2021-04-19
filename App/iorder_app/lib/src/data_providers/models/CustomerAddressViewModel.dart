import 'package:ande_app/src/data_providers/models/CountryModel.dart';
import 'package:ande_app/src/data_providers/models/delivery/CityViewModel.dart';
import 'package:ande_app/src/utilities/HelperFunctions.dart';
import 'package:ande_app/src/utilities/LocalKeys.dart';
import 'package:easy_localization/easy_localization.dart';

class CustomerAddressViewModel {
  int id, floor;
  CountryModel countryModel;
  RegionViewModel regionViewModel;
  AreaViewModel areaViewModel;
  String buildingNumber, streetNumber, flatNumber, directions;

  CustomerAddressViewModel(
      {this.id,
      this.floor,
      this.countryModel,
      this.regionViewModel,
      this.areaViewModel,
      this.buildingNumber,
      this.streetNumber,
      this.flatNumber,
      this.directions});

  static CustomerAddressViewModel fromJson(Map<String, dynamic> json) {
    CountryModel countryModel = CountryModel.fromJson(json['country']);
    RegionViewModel regionViewModel = RegionViewModel.fromJson(json['region']);
    AreaViewModel areaViewModel = AreaViewModel.fromJson(json['area']);
    return CustomerAddressViewModel(
      id: ParseHelper.parseNumber(json['id']),
      floor: ParseHelper.parseNumber(json['floor']),
      buildingNumber: json['building'],
      streetNumber: json['street'],
      flatNumber: json['flat'],
      directions: json['directions'],
      countryModel: countryModel,
      regionViewModel: regionViewModel,
      areaViewModel: areaViewModel,
    );
  }

  @override
  String toString() {
    return '${regionViewModel.regionName}, ${areaViewModel.areaName} ,${streetNumber != null ? streetNumber + ' ${tr(LocalKeys.STREET)}' : ''} \n${tr(LocalKeys.FLAT)}: ${flatNumber ?? ''}, ${tr(LocalKeys.FLOOR)}: $floor\n${tr(LocalKeys.BUILDING)}: $buildingNumber\n${tr(LocalKeys.ADDITIONAL)}: ${directions ?? tr(LocalKeys.NONE_LABEL)}';
  }
}
