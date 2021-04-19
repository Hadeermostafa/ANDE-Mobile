import 'dart:math' as MATH;

import 'package:ande_app/src/data_providers/models/OrderItemViewModel.dart';
import 'package:ande_app/src/data_providers/models/OrderViewModel.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

// import '../data_providers/models/OrderViewModel.dart';
import '../data_providers/models/TableViewModel.dart';
import '../data_providers/models/UserViewModel.dart';

class UserCart {
  static UserCart _singleton = new UserCart._internal();
  factory UserCart() {
    return _singleton;
  }
  UserCart._internal() {
    confirmedItemsList = new List();
    nonConfirmedItemsList = new List();
  }

  String orderTableNumber = "";
  String orderID = "", userOrderNo = "";
  bool isDelivery = false;
  List<OrderItemViewModel> confirmedItemsList = List<OrderItemViewModel>();
  List<OrderItemViewModel> nonConfirmedItemsList = List<OrderItemViewModel>();
  List<OrderItemViewModel> othersItemsList = List<OrderItemViewModel>();
  List<OrderItemViewModel> get getConfirmedItems => confirmedItemsList;
  List<OrderItemViewModel> get getNonConfirmedItems => nonConfirmedItemsList;
  int get cartSize =>
      (nonConfirmedItemsList.length + confirmedItemsList.length);
  bool get isDeliveryOrder => isDelivery;

  bool isEmpty() {
    return (getNonConfirmedItems != null &&
        getNonConfirmedItems.length > 0 &&
        getConfirmedItems != null &&
        getConfirmedItems.length > 0);
  }

  addToCart({List<OrderItemViewModel> itemsAsList}) {
    itemsAsList.forEach((item) {
      if (item != null && item.mealSize != null) {
        if (item.orderItemId == null)
          item.orderItemId = MATH.max(
              nonConfirmedItemsList.length + confirmedItemsList.length, 1);
        nonConfirmedItemsList.add(item);
      }
    });
  }

  removeFromNonConfirmedCart({OrderItemViewModel deletedItem}) {
    for (int i = 0; i < nonConfirmedItemsList.length; i++) {
      if (nonConfirmedItemsList[i] == deletedItem) {
        nonConfirmedItemsList.removeAt(i);
        return;
      }
    }
  }

  removeFromConfirmedCart({OrderItemViewModel deletedItem}) {
    for (int i = 0; i < confirmedItemsList.length; i++) {
      if (confirmedItemsList[i] == deletedItem) {
        confirmedItemsList.removeAt(i);
        break;
      }
    }
  }

  bool needNewItemsSection() {
    return (nonConfirmedItemsList.length > 0 && confirmedItemsList.length > 0);
  }

  clearCart() {
    confirmedItemsList.clear();
    nonConfirmedItemsList.clear();
    othersItemsList.clear();
    orderTableNumber = null;
    orderID = null;
    userOrderNo = null;
    isDelivery = false;
  }

  void confirmItems() {
    confirmedItemsList.addAll(nonConfirmedItemsList);
    nonConfirmedItemsList.clear();
  }

  bool isCartItem(OrderItemViewModel itemViewModel) {
    return (nonConfirmedItemsList.contains(itemViewModel) ||
        confirmedItemsList.contains(itemViewModel));
  }

  double calculateCart() {
    double subTotal = 0.0;
    if (confirmedItemsList.length > 0) {
      confirmedItemsList.forEach((orderItem) {
        subTotal += (orderItem.calculateItemPrice() * orderItem.quantity);
      });
    }
    if (nonConfirmedItemsList.length > 0) {
      nonConfirmedItemsList.forEach((orderItem) {
        subTotal += (orderItem.calculateItemPrice() * orderItem.quantity);
      });
    }
    return subTotal;
  }

  double calculateOrder() {
    double subTotal = calculateCart();
    if (othersItemsList.length > 0) {
      othersItemsList.forEach((orderItem) {
        subTotal += (orderItem.calculateItemPrice() * orderItem.quantity);
      });
    }
    return subTotal;
  }

  void updateItem(OrderItemViewModel itemModel, int change) {

    if(change > 0){
      FirebaseAnalytics().logAddToCart(itemId: itemModel.itemViewModel.id.toString(), itemName: itemModel.itemViewModel.name,  quantity: 1);
    }
    else {
      FirebaseAnalytics().logRemoveFromCart(itemId: itemModel.itemViewModel.id.toString(), itemName: itemModel.itemViewModel.name,  quantity: 1);
    }
    int itemIndex = confirmedItemsList.lastIndexOf(itemModel);
    if (itemIndex > -1) {
      confirmedItemsList[itemIndex].quantity += change;
      if (confirmedItemsList[itemIndex].quantity == 0) {
        removeFromConfirmedCart(deletedItem: itemModel);
      }
      return;
    }

    itemIndex = nonConfirmedItemsList.lastIndexOf(itemModel);

    if (itemIndex > -1) {
      nonConfirmedItemsList[itemIndex].quantity += change;
      if (nonConfirmedItemsList[itemIndex].quantity == 0) {
        removeFromNonConfirmedCart(deletedItem: itemModel);
      }
      return;
    }
  }

  createOrder(restaurantModel, userID) {
    return OrderViewModel(
        orderID: orderID,
        orderItems: confirmedItemsList,
        tableViewModel: TableViewModel(tableId: orderTableNumber),
        statues: ORDER_STATUES.PENDING,
        orderUserNumber: userOrderNo,
        otherPeopleOrderItems: othersItemsList,
        restaurantViewModel: restaurantModel,
        userModel: UserViewModel(
          userId: userID.toString(),
        ));
  }

  void setPlacedItem() {
    confirmedItemsList.forEach((item) {
      item.isPlaced = true;
    });
  }

  void updateOrderFromBackEnd(OrderViewModel orderViewModel) {
    confirmedItemsList = orderViewModel.orderItems;
    othersItemsList = orderViewModel.otherPeopleOrderItems;
    setPlacedItem();
    orderID = orderViewModel.orderID;
    userOrderNo = orderViewModel.orderUserNumber;
    orderTableNumber = orderViewModel.tableViewModel.tableId;
    nonConfirmedItemsList.clear();
  }




  void undoOrderCreation() {
    nonConfirmedItemsList.clear();
    confirmedItemsList.forEach((item) {
      if(item.isPlaced == false )
        nonConfirmedItemsList.add(item);
    });
    confirmedItemsList.removeWhere((item) => item.isPlaced == false);
  }
}
