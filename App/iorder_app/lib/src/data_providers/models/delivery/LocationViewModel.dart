import 'package:ande_app/src/utilities/HelperFunctions.dart';
import 'package:ande_app/src/data_providers/models/CountryModel.dart';
import '../LanguageModel.dart';

class LocationViewModel {
  int locationId;
  String countryId;
  String streetName, notes, flatNo, buildingNo, floorNo;
  double lat, lon;
  Region regionInformation;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationViewModel &&
          runtimeType == other.runtimeType &&
          countryId == other.countryId &&
          streetName == other.streetName &&
          notes == other.notes &&
          flatNo == other.flatNo &&
          lat == other.lat &&
          lon == other.lon &&
          floorNo == other.floorNo &&
          buildingNo == other.buildingNo &&
          regionInformation == other.regionInformation &&
          addressCountry == other.addressCountry;

  @override
  int get hashCode =>
      countryId.hashCode ^
      streetName.hashCode ^
      notes.hashCode ^
      flatNo.hashCode ^
      lat.hashCode ^
      lon.hashCode ^
      floorNo.hashCode ^
      buildingNo.hashCode ^
      regionInformation.hashCode ^
      addressCountry.hashCode;

  @override
  String toString() {
    return '${regionInformation.cityName}, ${regionInformation.regionName} ,$streetName Street \n FlatNo:  ${flatNo ?? ''}, floorNo: $floorNo, buildingNo: $buildingNo';
  }

  String toRegionString() {
    return regionInformation.toString();
  }

  CountryModel addressCountry;

  Map<String, dynamic> toJson() {
    return {
      "location_id": locationId,
      "country_id": countryId,
      "location_name": streetName,
      "floor_number": floorNo,
      "flat_number": flatNo,
      "notes": notes,
      "latitude": lat,
      "longitude": lon,
    };
  }

  static LocationViewModel fromJson(Map<String, dynamic> locationJson) {
    Region region;
    if (locationJson.containsKey('city'))
      region = Region.fromTwoJson(locationJson["city"], locationJson["region"]);
    else if (locationJson.containsKey('region_id') &&
        locationJson.containsKey('city_id')) {
      region = Region(
        regionId: locationJson['region_id'],
        cityId: locationJson['city_id'],
      );
    }

    return LocationViewModel(
      buildingNo: locationJson['building'].toString(),
      locationId: locationJson["id"] ?? 0,
      streetName: locationJson["street"],
      floorNo: locationJson["floor"],
      flatNo: locationJson["flat_number"] != null
          ? locationJson["flat_number"].toString()
          : '',
      lat: ParseHelper.parseNumber(locationJson["latitude"], toDouble: true),
      lon: ParseHelper.parseNumber(locationJson["magnitude"], toDouble: true),
      notes: locationJson["additional_directions"],
      addressCountry: CountryModel.fromJson(locationJson['country']),
      regionInformation: region,
    );
  }

  static List<LocationViewModel> fromListJson(List<dynamic> locationsListJson) {
    List<LocationViewModel> userLocations = List();
    for (int i = 0; i < locationsListJson.length; i++)
      userLocations.add(fromJson(locationsListJson[i]));
    return userLocations;
  }

  LocationViewModel(
      {this.locationId,
      this.countryId,
      this.streetName,
      this.regionInformation,
      this.notes,
      this.lat,
      this.lon,
      this.flatNo,
      this.addressCountry,
      this.buildingNo,
      this.floorNo});

  static LocationViewModel fromAnonymous() {
    return LocationViewModel();
  }
}

class Region {
  String regionName, cityName;
  int regionId, cityId;
  Region({this.regionName, this.regionId, this.cityId, this.cityName});

  @override
  String toString() {
    return '$cityName, $cityId , $regionName , $regionId';
  }

  static fromTwoJson(city, region) {
    return Region(
      cityName: city['name'],
      cityId: city['id'],
      regionName: region['name'],
      regionId: region['id'],
    );
  }
}
