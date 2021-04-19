
import 'dart:convert';

import 'package:ande_app/src/resources/UserCart.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'OrderItemViewModel.dart';
import 'package:flutter/material.dart';
class NotificationObjectModel {
  String notificationReason;

  NotificationObjectModel(
      {this.notificationReason, this.shouldReload, this.notificationData});
  bool shouldReload;
  var notificationData;

  static NotificationObjectModel fromJson(RemoteMessage notification) {

    print("From Json notification => $notification");

    try {
      // var notificationDataAsString = Platform.isAndroid
      //     ? notification['data']
      //     : notification['dataFromNotification'];
      //json.decode(notificationDataAsString['original']);

      var notificationDataAsMap =   notification.data ;



      var notificationInfo = jsonDecode(notificationDataAsMap['original']);
      String notificationReason = notificationInfo['notificationReason'];
      bool notificationRequireReload = notificationInfo['notificationReload'];





      NotificationObjectModel objectModel = NotificationObjectModel(
        notificationReason: notificationReason,
        shouldReload: notificationRequireReload,
        notificationData: notificationInfo['notificationData'],
      );



      return objectModel;
    } catch (ex) {
      debugPrint("Exception in parsing notification => $ex");

      return NotificationObjectModel(
        notificationReason: 'OrderUpdate',
        shouldReload: true,
      );
    }
  }

  static void updateCartFromNotificationItems(Map<String, dynamic> newOrderStatus) {
    var itemId = newOrderStatus['rel_order_item_id'];
    var newStatus = newOrderStatus['status'];
    int index = UserCart().confirmedItemsList.lastIndexOf(OrderItemViewModel(orderItemId: itemId));
    int othersIndex = UserCart().othersItemsList.lastIndexOf(OrderItemViewModel(orderItemId: itemId));

    if (index > -1) {
      UserCart().confirmedItemsList[index].itemStatues =
          OrderItemViewModel.getItemStatues(newStatus);
    }
    if (othersIndex > -1) {

      UserCart().othersItemsList[othersIndex].itemStatues =
          OrderItemViewModel.getItemStatues(newStatus);
    }


  }

  @override
  String toString() {
    return 'Notification Received => notification reason $notificationReason \n' +
        'notification should refresh ? => $shouldReload \n' +
        'and getting data => $notificationData \n';
  }
}
