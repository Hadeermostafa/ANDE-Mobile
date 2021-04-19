import 'package:ande_app/src/data_providers/models/delivery/RestaurantDeliveryInformation.dart';
import 'package:ande_app/src/utilities/HelperFunctions.dart';

class DeliveryArea {
  int areaId, regionId;
  String areaName;
  DeliveryFeesType deliveryFeesType;
  double deliveryCost;

  DeliveryArea(
      {this.areaId,
      this.regionId,
      this.areaName,
      this.deliveryFeesType,
      this.deliveryCost});

  static DeliveryArea fromJson(Map<String, dynamic> json) {
    return DeliveryArea(
      areaId: ParseHelper.parseNumber(json[NewDeliveryAreaJsonKeys.AREA_ID]),
      areaName: json[NewDeliveryAreaJsonKeys.AREA_NAME] ?? '',
      regionId: ParseHelper.parseNumber(json[NewDeliveryAreaJsonKeys.AREA_REGION_ID]),
      deliveryCost: ParseHelper.parseNumber(json[NewDeliveryAreaJsonKeys.AREA_COST], toDouble: true),
      deliveryFeesType: getNewDeliveryFeesType(json[NewDeliveryAreaJsonKeys.AREA_DELIVERY_TYPE])
    );
  }

  static DeliveryFeesType getNewDeliveryFeesType(String deliveryFeesType) {
    if (deliveryFeesType == null || deliveryFeesType == "fixed") {
      return DeliveryFeesType.FIXED_COST;
    }
    if (deliveryFeesType == "percentage") {
      return DeliveryFeesType.PERCENTAGE_COST;
    }
    else {
      return DeliveryFeesType.AREA_BASED;
    }
  }
}

class NewDeliveryAreaJsonKeys {
  static const AREA_ID = 'id';
  static const AREA_NAME = 'name';
  static const AREA_REGION_ID = 'region_id';
  static const AREA_COST = 'cost';
  static const AREA_DELIVERY_TYPE = 'cost_type';
}
