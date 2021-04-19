import 'package:ande_app/src/data_providers/models/CurrencyModel.dart';
import 'package:ande_app/src/data_providers/models/OrderItemViewModel.dart';
import 'package:ande_app/src/data_providers/models/PromocodeViewModel.dart';
import 'package:ande_app/src/data_providers/models/RestaurantListViewModel.dart';
import 'package:ande_app/src/data_providers/models/product/ProductViewModel.dart';
import 'package:ande_app/src/utilities/HelperFunctions.dart';
import 'package:flutter/material.dart';

import 'PaymentMethodViewModel.dart';
import 'RestaurantViewModel.dart';
import 'TableViewModel.dart';
import 'UserViewModel.dart';
import 'delivery/DeliveryOrderExtraInformationModel.dart';
class OrderViewModel {
  List<OrderItemViewModel> orderItems = List();
  List<OrderItemViewModel> otherPeopleOrderItems = List();
  Map<OrderItemViewModel, int> itemsRating = Map();
  PaymentMethodViewModel paymentMethod;
  int restaurantUserRating;
  UserViewModel userModel;
  RestaurantViewModel restaurantViewModel;
  TableViewModel tableViewModel;
  ORDER_STATUES statues;
  String orderID, orderUserNumber;
  DeliveryOrderExtraInformationModel deliveryOrderInfo;
  OrderType orderType;
  double totalPrice, subTotal;
  PromoCodeViewModel promoCodeViewModel;

  OrderViewModel.clone(OrderViewModel orderViewModel): this(
      orderID: orderViewModel.orderID,
      orderUserNumber: orderViewModel.orderUserNumber,
      statues: orderViewModel.statues,
      restaurantViewModel: orderViewModel.restaurantViewModel,
      tableViewModel: orderViewModel.tableViewModel,
      orderItems: orderViewModel.orderItems,
      otherPeopleOrderItems: orderViewModel.otherPeopleOrderItems ?? [],
      totalPrice: orderViewModel.totalPrice,
      subTotal: orderViewModel.subTotal,
      deliveryOrderInfo: orderViewModel.deliveryOrderInfo,
      promoCodeViewModel: orderViewModel.promoCodeViewModel
  );

  static OrderViewModel fromJson(Map<String, dynamic> passedJson) {
    var restaurant = passedJson['restaurant'];
    RestaurantListViewModel restaurantListViewModel = RestaurantListViewModel(
      restaurantId: restaurant[RestaurantListViewModelJsonKeys.RESTAURANT_LIST_ID].toString(),
      restaurantName: restaurant[RestaurantListViewModelJsonKeys.RESTAURANT_LIST_NAME],
      restaurantImagePath: restaurant[RestaurantListViewModelJsonKeys.RESTAURANT_LIST_IMAGE],
    );
    RestaurantViewModel restaurantViewModel = RestaurantViewModel(
      restaurantTaxes: ParseHelper.parseNumber(passedJson[RestaurantJsonKeys.RESTAURANT_TAX], toDouble: true),
      restaurantService: ParseHelper.parseNumber(passedJson[RestaurantJsonKeys.RESTAURANT_SERVICE_FEES], toDouble: true),
      restaurantListViewModel: restaurantListViewModel,
      restaurantCurrency: CurrencyModel.fromJson(restaurant[RestaurantJsonKeys.RESTAURANT_SUPPORTED_CURRENCY])
    );

    /// current user items
    List<OrderItemViewModel> customerOrderItems = List();
    var currentItems = passedJson[OrderViewModelJsonKeys.CURRENT_CUSTOMER_ITEMS];
      customerOrderItems.addAll(getItemsFromList(currentItems));


    /// rest of the table
    List<OrderItemViewModel> tableOrderItems = List();
    var currentTableItems = passedJson[OrderViewModelJsonKeys.TABLE_ITEMS];
      tableOrderItems.addAll(getItemsFromList(currentTableItems));


    DeliveryOrderExtraInformationModel deliveryInfo = DeliveryOrderExtraInformationModel();
    if (passedJson[OrderViewModelJsonKeys.DELIVERY_FEES] != null) {
      deliveryInfo.deliveryCost = ParseHelper.parseNumber(passedJson[OrderViewModelJsonKeys.DELIVERY_FEES], toDouble: true);
    }

    PromoCodeViewModel promoCodeViewModel = PromoCodeViewModel();
    var promoCodes = passedJson[OrderViewModelJsonKeys.PROMO_CODE];
    if (promoCodes != null) {
      promoCodeViewModel = PromoCodeViewModel.fromJson(promoCodes);
    }
    return OrderViewModel(
      orderID: passedJson[OrderViewModelJsonKeys.ORDER_ID].toString(),
      orderUserNumber: passedJson[OrderViewModelJsonKeys.CODE],
      statues: getOrderStatues(passedJson['status']),
      restaurantViewModel: restaurantViewModel,
      tableViewModel: TableViewModel(tableId: passedJson['table_id'].toString()),
      orderItems: customerOrderItems,
      otherPeopleOrderItems: tableOrderItems ?? [],
      totalPrice: ParseHelper.parseNumber(passedJson[OrderViewModelJsonKeys.ORDER_TOTAL_PRICE] , toDouble: true),
      subTotal: ParseHelper.parseNumber(passedJson[OrderViewModelJsonKeys.ORDER_SUB_TOTAL_PRICE], toDouble: true),
      deliveryOrderInfo: deliveryInfo,
      promoCodeViewModel: promoCodeViewModel
    );
  }

  OrderViewModel({
    this.deliveryOrderInfo,
    this.userModel,
    this.orderID,
    this.orderType,
    this.otherPeopleOrderItems,
    this.statues,
    this.orderUserNumber,
    this.restaurantViewModel,
    this.tableViewModel,
    this.orderItems,
    this.totalPrice,
    this.subTotal,
    this.promoCodeViewModel
  });

  static getOrderStatues(String orderStatues) {
    switch (orderStatues) {
      case OrderViewModelJsonKeys.ORDER_STATUES_PENDING:
        return ORDER_STATUES.PENDING;
      case OrderViewModelJsonKeys.ORDER_STATUES_SENT:
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
      case OrderViewModelJsonKeys.ORDER_STATUES_CONFIRMED:
        return ORDER_STATUES.CONFIRMED;
      case OrderViewModelJsonKeys.ORDER_STATUES_NEW:
        return ORDER_STATUES.NEW;
      case OrderViewModelJsonKeys.ORDER_STATUES_PAID:
        return ORDER_STATUES.COMPLETED;
      case OrderViewModelJsonKeys.ORDER_STATUES_DELIVERED:
        return ORDER_STATUES.DELIVERED;
      case OrderViewModelJsonKeys.ORDER_STATUES_ON_ITS_WAY:
        return ORDER_STATUES.ON_ITS_WAY;
      default :
        return ORDER_STATUES.PENDING;
    }
  }

  void sortItems() {
    orderItems.sort((item, other) {
      if (item.itemStatues.statuesRank == other.itemStatues.statuesRank)
        return 0;
      else if (item.itemStatues.statuesRank > other.itemStatues.statuesRank)
        return 1;
      else
        return -1;
    });

    otherPeopleOrderItems.sort((item, other) {
      if (item.itemStatues.statuesRank == other.itemStatues.statuesRank)
        return 0;
      else if (item.itemStatues.statuesRank > other.itemStatues.statuesRank)
        return 1;
      else
        return -1;
    });
  }


  @override
  String toString() =>
      'OrderViewModel {id: ${orderID?.toString()}, table_id: ${tableViewModel
          ?.tableId.toString()}, status: ${statues?.toString()}';

  double calculateOrderNet() {
    double netValue = 0.0;
    for (int i = 0; i < orderItems.length; i++)
      netValue += orderItems[i].calculateItemPrice();

    for (int i = 0; i < otherPeopleOrderItems.length; i++)
      netValue += otherPeopleOrderItems[i].calculateItemPrice();

    return netValue;
  }

  double calculateOrderGross() {
    double netValue = calculateOrderNet();
    double tax = 0.0;
    tax =
        ((restaurantViewModel.restaurantTaxes ?? 0.0 * netValue) / 100) ?? 0.0;
    double service = 0.0;
    if (restaurantViewModel.deliveryInformation == null) {
      service = (restaurantViewModel.restaurantService) ?? 0.0;
    } /*else {
      if (restaurantViewModel.deliveryInformation.feesType ==
          DeliveryFeesType.PERCENTAGE_COST) {
        service =
            ((restaurantViewModel.deliveryInformation.restaurantDeliveryFees *
                netValue) / 100) ?? 0.0;
      } else {
        service =
            (restaurantViewModel.deliveryInformation.restaurantDeliveryFees) ??
                0.0;
      }
    }*/

    return netValue ?? 0.0 + tax ?? 0.0 + service ?? 0.0;
  }

  String getAllOrderMealsTitles() {
    List<String> allTitles = List();
    if (orderItems != null) {
      orderItems.forEach((element) {
        allTitles.add(element.itemViewModel.name);
      });
    }
    if (otherPeopleOrderItems != null) {
      otherPeopleOrderItems.forEach((element) {
        allTitles.add(element.itemViewModel.name);
      });
    }
    return allTitles.join(', ');
  }

  static List<OrderItemViewModel> getItemsFromList(currentItems) {
    List<OrderItemViewModel> itemsList = List<OrderItemViewModel>();
    if(currentItems != null && currentItems is List && currentItems.length > 0) {
      for (var currentItem in currentItems) {
        try{
          ProductViewModel productViewModel = ProductViewModel.fromJson(currentItem[OrderViewModelJsonKeys.CURRENT_CUSTOMER_ITEM_INFO]);
          List<ProductAddOn> extrasList = List();
          if (currentItem[OrderViewModelJsonKeys.CURRENT_CUSTOMER_ITEM_EXTRAS] != null) {
            extrasList.addAll(ProductAddOn.fromListJson(
                currentItem[OrderViewModelJsonKeys
                    .CURRENT_CUSTOMER_ITEM_EXTRAS]));
          }
          itemsList.add(OrderItemViewModel(
            itemViewModel: productViewModel,
            orderItemId: currentItem[OrderViewModelJsonKeys.RELATION_ITEM_ID],
            userNote: currentItem[OrderViewModelJsonKeys.CURRENT_CUSTOMER_ITEM_NOTE],
            mealSize: ProductAddOn.fromJson(currentItem[OrderViewModelJsonKeys.CURRENT_CUSTOMER_ITEM_SIZE]),
            userSelectedExtras: extrasList ?? List(),
            itemStatues: OrderItemViewModel.getItemStatues(currentItem[OrderItemJsonKeys.ITEM_STATUES]),
            isPlaced: true,
          ));
        } catch(itemException){
          debugPrint("HELLO => $itemException");
        }
      }
    }
    return itemsList;
  }
}

enum ORDER_STATUES {
  PENDING,
  ACCEPTED,
  PREPARING,
  SERVED,
  PAYMENT_REQUESTED,
  COMPLETED,
  RATED,
  CANCELLED,
  CONFIRMED,
  NEW,
  ON_ITS_WAY,
  DELIVERED
}

class OrderViewModelJsonKeys {
  static const String ORDER_DATA_INFORMATION = "activeOrder";

  static const String CLOSED_ORDER_DATA_INFORMATION = "order";
  static const String CLOSED_ORDER_RESTAURANT_TAXES = "tax";
  static const String CLOSED_ORDER_RESTAURANT_SERVICE = "service";

  static const String ORDER_RESTAURANT_INFORMATION = "restaurant";
  static const String ORDER_TABLE_INFORMATION = "table";
  static const String OTHER_PEOPLE_ORDERS = "otherOrders";

  static const String ORDER_TABLE_NUMBER = "tableNumber";

  static const String ORDER_ID = "id";
  static const String ORDER_STATUES = "status";
  static const String ORDER_TOTAL = "userSharePrice";
  static const String ORDER_ITEMS = "items";
  static const String ORDER_USER_NUMBER = "orderNumber";

  static const String ORDER_STATUES_PENDING = "Pending";
  static const String ORDER_STATUES_SENT = "Sent";

  static const String ORDER_STATUES_ACCEPTED = "Accepted";
  static const String ORDER_STATUES_PREPARING = "Preparing";
  static const String ORDER_STATUES_SERVED = "Served";
  static const String ORDER_STATUES_CONFIRMED = "Confirmed";
  static const String ORDER_STATUES_CANCELED = "Cancelled";
  static const String ORDER_STATUES_COMPLETED = "Completed";
  static const String ORDER_STATUES_RATED = "Rated";
  static const String ORDER_STATUES_NEW = "New";
  static const String ORDER_STATUES_PAID = "Paid";
  static const String ORDER_STATUES_DELIVERED = "Delivered";
  static const String ORDER_STATUES_ON_ITS_WAY = "On Its Way";

  static const String PAYMENT_REQUESTED_KEY = "Want Pay";

  static const String WAITER_ORDER_STATUES = "restaurantUserStatus";

  static const String ORDER_TYPE_KEY = "orderType";
  static const String DELIVERY_INFORMATION = "orderAddress";

  static const String DATA = 'data';
  static const String ORDER = 'order';
  static const String CODE = 'code';
  static const String CURRENT_CUSTOMER_ITEMS = 'current_customer_items';
  static const String TABLE_ITEMS = 'other_customers_items';
  static const String CURRENT_CUSTOMER_ITEM_INFO = 'item_info';
  static const String CURRENT_CUSTOMER_ITEM_NOTE = 'notes';
  static const String CURRENT_CUSTOMER_ITEM_SIZE = 'size';
  static const String CURRENT_CUSTOMER_ITEM_EXTRAS = 'extras';

  static const String RESTAURANT_LIST_ORDER_ID = 'restaurant_id';
  static const String ORDER_TOTAL_PRICE = 'total';
  static const String ORDER_SUB_TOTAL_PRICE = 'sub_total';
  static const String CURRENT_CUSTOMER_ITEM_ID = 'id';
  static const String RELATION_ITEM_ID = 'rel_order_item_id';
  static const String ORDER_CURRENCY = 'currency';

  static const String DELIVERY_FEES = 'delivery_fees';
  static const String PROMO_CODE = 'promocode';

}

enum OrderType { DINING, DELIVERY }
