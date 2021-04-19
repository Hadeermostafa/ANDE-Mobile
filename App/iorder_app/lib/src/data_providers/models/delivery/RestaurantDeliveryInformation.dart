import 'package:ande_app/src/data_providers/models/delivery/DeliveryArea.dart';

class RestaurantDeliveryInformation {
  DeliveryFeesType feesType;
  // List<DeliveryRegion> deliveryRegions;
  List<DeliveryArea> deliveryAreas;
  // double restaurantDeliveryFees;
  RestaurantDeliveryInformation(
      {this.feesType, this.deliveryAreas});

  static RestaurantDeliveryInformation fromJson(
      List<dynamic> deliverySectionJson) {
    List<DeliveryArea> areas = List();
    /*double percentage;
    DeliveryFeesType deliveryFeesType = DeliveryFeesType.AREA_BASED;
    if (deliverySectionJson['delivery_info'] != null) {
      String deliveryFeesString = deliverySectionJson['delivery_info']['type'];
      deliveryFeesType = getDeliveryFeesType(deliveryFeesString);
      percentage = ParseHelper.parseNumber(
          deliverySectionJson['delivery_info']['cost'],
          toDouble: true);
      if (deliveryFeesType == DeliveryFeesType.AREA_BASED) {
        if (deliverySectionJson.containsKey('delivery_regions')) {
          if (deliverySectionJson['delivery_regions'] is List)
            regions.addAll(DeliveryRegion.fromListJson(
                deliverySectionJson['delivery_regions']));
        }
      }
    }*/
    for (int i = 0; i < deliverySectionJson.length; i++) {
      areas.add(DeliveryArea.fromJson(deliverySectionJson[i]));
    }

    return RestaurantDeliveryInformation(
      deliveryAreas: areas,
      feesType: DeliveryFeesType.AREA_BASED,
    );
  }

  // static getDeliveryFeesType(String deliveryFeesType) {
  //   if (deliveryFeesType == null || deliveryFeesType == "Fixed cost")
  //     return DeliveryFeesType.FIXED_COST;
  //   if (deliveryFeesType == "Percentage cost")
  //     return DeliveryFeesType.PERCENTAGE_COST;
  //   if (deliveryFeesType == "Region") return DeliveryFeesType.AREA_BASED;
  // }
}

enum DeliveryFeesType { FIXED_COST, PERCENTAGE_COST, AREA_BASED }
