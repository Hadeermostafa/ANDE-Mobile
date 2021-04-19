import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:ande_app/src/data_providers/models/ErrorViewModel.dart';
import 'package:ande_app/src/data_providers/models/OrderViewModel.dart';
import 'package:ande_app/src/utilities/LocalKeys.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
class Constants {
  static const String USER_PREFERENCE_TOKEN_KEY = 'PREF_USER_TOKEN_KEY';
  static const String USER_PREFERENCE_ANONYMOUS_KEY = 'PREF_USER_ANONYMOUS_KEY';
  static const String USER_PREFERENCE_CACHED_USER_KEY = 'USER_PREFERENCE_CACHED_USER_KEY';
  static const String USER_PREFERENCE_COUNTRY_KEY = 'USER_PREFERENCE_COUNTRY_KEY';


  static List<String> orderTypes = [
    (LocalKeys.DINING_TAB),
    (LocalKeys.DELIVERY_TAB),
    // (LocalKeys.PICK_UP_TAB).tr(),
    // (LocalKeys.BOOKING_TAB).tr()
  ];

  static Map<OrderType, String> orderTypeUrl = {
    OrderType.DINING: 'dinein',
    OrderType.DELIVERY: 'delivery',
  };


  static const String FONT_ARIAL = "arial";
  static const String FONT_MONTSERRAT = "Montserrat";
  static const String FONT_TAJAWAL = "TajWawal";
  static const String FONT_Droid_Arabic_Kufi = "Droid Arabic Kufi";

  static const headerStyle = TextStyle(
    fontSize: 20.0,
    color: Colors.black,
    fontWeight: FontWeight.w700,
  );
  static const subTitleStyle = TextStyle(
    fontSize: 18.0,
    color: Colors.black,
    fontWeight: FontWeight.w700,
  );
  static const smallTextStyle = TextStyle(
    fontSize: 13.0,
    color: Colors.black,
    fontWeight: FontWeight.w700,
  );

  static const mainThemeColor = Color(0xffcc0000);
  static const priceUnavailableColor = Colors.grey;
  static const AndeLogoColor = Color(0xFF9F0B07);

  static final kTextColor = Color.fromARGB(255, 102, 102, 102);
  static final kHeadersColor = Colors.black;

  static const String USER_TOKEN_PREFERENCE_KEY = "IORDER_USER_PREFERENCE";
  static const String USER_ID_PREFERENCE_KEY = "IORDER_USER_ID";


  static String currentAppLocale = "en";
  static String currentRestaurantLocale = "en";
  static String currentRestaurantCurrency = (LocalKeys.EGP).tr();

  static const String userMail = 'ande.anonymous@mdlabs.com';
  static const String userPassword = '1097f785f46849de074f040bf0eb7a7871d82f94a998152fe54566931cd396fbcc9c16500e670313374dba8b483a2f65d6ae301d2b9e9f42cd530d0325879397';

  static const String twitterCustomerKey = "xQXjRVDG6AIcGqnw1zf1pVqrs";
  static const String twitterAppSecret = "0wogA3qJ5l0Saq6R4mIxPLgamjNkJ9i9m0f0U96kmKDwvk8p4P";




  static final ErrorViewModel connectionTimeoutException = ErrorViewModel(
    errorMessage: '',
    errorCode: HttpStatus.requestTimeout,
  );
  static parseNotificationReason(var notification) {
    try {
      var notificationDataAsString = Platform.isAndroid
          ? notification['data']['dataFromNotification']
          : notification['dataFromNotification'];

      var notificationDataAsMap = json.decode(notificationDataAsString);
      var notificationReason =
          notificationDataAsMap['original']['notificationReason'];
      return notificationReason;
    } catch (ex) {
      print(ex);
      return "";
    }
  }
}


class NotificationKeys {
  static const String NOTIFICATION_ORDER_UPDATE = "OrderUpdate";
  static const String NOTIFICATION_ORDER_CLOSE = "OrderClosed";

  static const String NOTIFICATION_ORDER_PAY = "OrderPayRequest";
  static const String NOTIFICATION_ORDER_REOPEN = "OrderReopenedRequest";

  static const String NOTIFICATION_SHIFT_MANAGER_UPDATE_ORDER =
      "ShiftManagerUpdateOrder";

  static const String NOTIFICATION_SHOULD_RELOAD = "notificationReload";
  static const String ORDER_CONFIRMED = "Confirmed";
  static const String ORDER_COMPLETED = "Completed";
  static const String ORDER_CLOSED = "OrderClosed";
}
