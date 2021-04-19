// class DeliveryRegion {
//   String regionName, cityName;
//
//   @override
//   String toString() {
//     return '$cityName, $cityId , $regionName , $regionId';
//   }
//
//   int regionId, cityId;
//   double deliveryFees;
//   DeliveryRegion(
//       {this.regionId,
//       this.cityId,
//       this.cityName,
//       this.deliveryFees,
//       this.regionName});
//
//   static List<DeliveryRegion> fromListJson(List<dynamic> regionsListJson) {
//     List<DeliveryRegion> regionsList = List();
//     if (regionsListJson != null && regionsListJson is List) {
//       for (int i = 0; i < regionsListJson.length; i++)
//         regionsList.add(DeliveryRegion.fromJson(regionsListJson[i]));
//     }
//     return regionsList;
//   }
//
//   static DeliveryRegion fromJson(Map<String, dynamic> deliveryRegionJson) {
//     return DeliveryRegion(
//       deliveryFees: deliveryRegionJson['cost'] != null
//           ? deliveryRegionJson['cost'] * 1.0
//           : 0.0,
//       regionId: deliveryRegionJson['region_id'] ?? 0,
//       regionName: deliveryRegionJson['region_name'] ?? '',
//       cityId: deliveryRegionJson['city_id'] ?? 0,
//       cityName: deliveryRegionJson['city_name'] ?? '',
//     );
//   }
// }
