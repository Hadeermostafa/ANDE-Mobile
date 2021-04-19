class AddressToServerModel {
  int countryId, regionId, areaId, floor;
  String street, building, directions, flat;

  AddressToServerModel({this.countryId, this.regionId, this.areaId, this.floor,
    this.building, this.flat, this.directions, this.street});

  Map<String, dynamic> toJson() {
    return {
      'country_id': countryId,
      'region_id': regionId,
      'area_id': areaId,
      'floor': floor,
      'building': building,
      'street': street,
      'flat': flat,
      'directions': directions,
    };
  }
}