import 'package:ande_app/src/resources/Constants.dart';
import 'package:flutter/material.dart';
import 'OrderViewModel.dart';

class OrderHistoryListViewModel {
  String restaurantLogoPath,
      restaurantName,
      orderSummary,
      orderId,
      orderCurrency;
  ORDER_STATUES orderStatues;
  OrderType orderType;

  OrderHistoryListViewModel({
    this.orderType,
    this.restaurantLogoPath,
    this.restaurantName,
    this.orderSummary,
    this.orderId,
    this.orderCurrency,
    this.orderTotal,
    this.orderStatues,
  });
  double orderTotal;
  static OrderHistoryListViewModel fromJson(json) {
    ORDER_STATUES statues =
        getOrderStatues(json[OrderHistoryListModelJsonKeys.ORDER_STATUES]);
    var restaurantInfo =
        json[OrderHistoryListModelJsonKeys.RESTAURANT_INFO_SECTION];

    List<String> itemNames = List();
    if (json[OrderHistoryListModelJsonKeys.ITEM_INFO_SECTION] != null) {
      for (int i = 0;
          i < json[OrderHistoryListModelJsonKeys.ITEM_INFO_SECTION].length;
          i++) {
        var itemJson = json[OrderHistoryListModelJsonKeys.ITEM_INFO_SECTION][i];
        if (itemJson[OrderHistoryListModelJsonKeys.ITEM_NAME] != null &&
            itemJson[OrderHistoryListModelJsonKeys.ITEM_NAME]
                    .toString()
                    .toLowerCase() !=
                'null')
          itemNames.add(itemJson[OrderHistoryListModelJsonKeys.ITEM_NAME]);
      }
    }

    String currencyName;
    try {
      for (int i = 0; i < restaurantInfo['currency_translations'].length; i++) {
        if (restaurantInfo['currency_translations'][i]['locale'] ==
            Constants.currentAppLocale) {
          currencyName = restaurantInfo['currency_translations'][i]['name'];
          break;
        }
      }
    } catch (exception) {
      debugPrint("Exception accured while parsing Currency => $exception");
    }

    OrderType _orderType = OrderType.DINING;
    try {
      String orderTypeStr = json['orderType'].toString().toLowerCase() ?? '';
      if (orderTypeStr == 'delivery') {
        _orderType = OrderType.DELIVERY;
      }
    } catch (exception) {
      debugPrint("Exception in parsing Order type => $exception");
    }

    OrderHistoryListViewModel orderItem = OrderHistoryListViewModel(
      orderType: _orderType,
      orderCurrency: currencyName ?? Constants.currentRestaurantCurrency,
      orderSummary: itemNames.join(',') != null ? itemNames.join(',') : '',
      orderStatues: statues,
      orderTotal:
          double.parse(json[OrderHistoryListModelJsonKeys.ORDER_TOTAL_KEY]),
      orderId: json[OrderHistoryListModelJsonKeys.ORDER_ID_KEY].toString(),
      restaurantName:
          restaurantInfo[OrderHistoryListModelJsonKeys.RESTAURANT_NAME_KEY] ??
              '',
      restaurantLogoPath:
          restaurantInfo[OrderHistoryListModelJsonKeys.RESTAURANT_LOGO_KEY]
              .toString(),
    );

    return orderItem;
  }

  static getOrderStatues(String orderStatues) {
    switch (orderStatues) {
      case OrderViewModelJsonKeys.ORDER_STATUES_PENDING:
        return ORDER_STATUES.PENDING;
      case OrderViewModelJsonKeys.ORDER_STATUES_ACCEPTED:
        return ORDER_STATUES.ACCEPTED;
      case OrderViewModelJsonKeys.ORDER_STATUES_PREPARING:
        return ORDER_STATUES.PREPARING;
      case OrderViewModelJsonKeys.ORDER_STATUES_SERVED:
        return ORDER_STATUES.SERVED;
      case OrderViewModelJsonKeys.ORDER_STATUES_COMPLETED:
        return ORDER_STATUES.COMPLETED;
      case OrderViewModelJsonKeys.ORDER_STATUES_CANCELED:
        return ORDER_STATUES.CANCELLED;
    }
  }

  static fromListJson(listJson) {
    List<OrderHistoryListViewModel> orders = List<OrderHistoryListViewModel>();
    if (listJson is List) {
      for (int i = 0; i < listJson.length; i++) {
        orders.add(OrderHistoryListViewModel.fromJson(listJson[i]));
      }
    }

    return orders;
  }
}

class OrderHistoryListModelJsonKeys {
  static const String RESTAURANT_INFO_SECTION = "restaurant";
  static const String RESTAURANT_NAME_KEY = "name";
  static const String RESTAURANT_LOGO_KEY = "logoUrl";

  static const String ITEM_INFO_SECTION = "items";
  static const String ITEM_NAME = "name";

  static const String ORDER_ID_KEY = "id";
  static const String ORDER_TOTAL_KEY = "userSharePrice";
  static const String ORDER_STATUES = "status";
  static const String ORDER_CURRENCY = "currency_translations";
}
