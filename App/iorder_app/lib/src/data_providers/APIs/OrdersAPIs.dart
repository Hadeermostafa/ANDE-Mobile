import 'dart:io';

import 'package:ande_app/src/data_providers/models/ErrorViewModel.dart';
import 'package:ande_app/src/data_providers/models/OrderViewModel.dart';
import 'package:ande_app/src/data_providers/models/PaymentMethodViewModel.dart';
import 'package:ande_app/src/data_providers/models/PromocodeViewModel.dart';
import 'package:ande_app/src/data_providers/models/ResponseModel.dart';
import 'package:ande_app/src/resources/Constants.dart';
import 'package:ande_app/src/resources/Repository.dart';
import 'package:ande_app/src/resources/URL.dart';
import 'package:ande_app/src/utilities/LocalKeys.dart';
import 'package:ande_app/src/utilities/NetworkUtilities.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';

class OrdersAPIs {

  static Future<ResponseViewModel<OrderViewModel>> createOrder(
      OrderViewModel orderModel) async {
    String url =
        '${URL.getURL(functionName: URL.PLACE_USER_ORDER)}';
    var requestHeaders = await NetworkUtilities.getHttpHeaders();
    Map<String, dynamic> createNewOrderData = Map();
        createNewOrderData.putIfAbsent('table_code', () => orderModel.tableViewModel.tableId);
    createNewOrderData.putIfAbsent('restaurant_id', () => orderModel
        .restaurantViewModel.restaurantListViewModel.restaurantId);
    if (orderModel.orderItems.isNotEmpty && orderModel.orderItems != null) {
      List<Map<String, dynamic>> _newMeals = [];
      orderModel.orderItems.forEach((element) {
        Map<String, dynamic> singleMeal = Map();
        if (element.quantity != null) {
          singleMeal.putIfAbsent('quantity', () => element.quantity);
        }
        if (element.userNote != null && element.userNote.isNotEmpty) {
          singleMeal.putIfAbsent('notes', () => element.userNote);
        }
        singleMeal.putIfAbsent('item_size', () => element.mealSize.id);
        if (element.userSelectedExtras != null) {
          List<int> extraIds = element.userSelectedExtras.map((element) => element.id).toList();
          singleMeal.putIfAbsent('item_extras', () => extraIds);
        }
        _newMeals.add(singleMeal);
      });
      createNewOrderData.putIfAbsent('items', () => _newMeals);
    }
    createNewOrderData.putIfAbsent('menu_language', () => Constants.currentRestaurantLocale);
    ResponseViewModel createOrderResponse =
        await NetworkUtilities.handlePostRequest(
      requestHeaders: requestHeaders,
      methodURL: url,
      requestBody: createNewOrderData,
      acceptJson: true,
      parserFunction: (Map<String, dynamic> passedJson) {
        var data = passedJson[OrderViewModelJsonKeys.DATA];
        var order = data[OrderViewModelJsonKeys.ORDER];
        return OrderViewModel.fromJson(order);
      },
    );
    return ResponseViewModel<OrderViewModel>(
      isSuccess: createOrderResponse.isSuccess,
      serverData: createOrderResponse.responseData,
      serverError: createOrderResponse.serverError,
    );
  }

  static Future<ResponseViewModel<OrderViewModel>> updateOrder(
  {OrderViewModel orderModel}) async {
    String url =
        '${URL.getURL(functionName: URL.POST_UPDATE_ORDER(orderId: orderModel.orderID))}';
    Map<String, String> requestHeaders = await NetworkUtilities.getHttpHeaders();
    Map<String, dynamic> body = Map();
    List<dynamic> items = List();
    for (int i = 0; i < orderModel.orderItems.length; i++) {
      if (orderModel.orderItems[i].isPlaced == true) {
        continue;
      }
      Map<String, dynamic> orderItem = Map();
      orderItem.putIfAbsent('item_size', () => orderModel.orderItems[i].mealSize.id);
      orderItem.putIfAbsent('quantity', () => orderModel.orderItems[i].quantity);
      if (orderModel.orderItems[i].userNote != null && orderModel.orderItems[i].userNote.isNotEmpty) {
        orderItem.putIfAbsent('item_notes', () => orderModel.orderItems[i].userNote);
      }
      if (orderModel.orderItems[i].userSelectedExtras != null && orderModel.orderItems[i].userSelectedExtras.isNotEmpty) {
        List<int> extras = List();
        for (int j = 0; j < orderModel.orderItems[i].userSelectedExtras.length; j++) {
          extras.add(orderModel.orderItems[i].userSelectedExtras[j].id);
        }
        orderItem.putIfAbsent('item_extras', () => extras);
      }
      items.add(orderItem);
    }
    body.putIfAbsent('items', () => items);
    ResponseViewModel response = await NetworkUtilities.handlePostRequest(
      acceptJson: true,
      methodURL: url,
      requestHeaders: requestHeaders,
      requestBody: body,
      parserFunction: (Map<String, dynamic> passedJson) {
        var data = passedJson[OrderViewModelJsonKeys.DATA];
        var order = data[OrderViewModelJsonKeys.ORDER];
        return OrderViewModel.fromJson(order);
      }
    );
    return ResponseViewModel<OrderViewModel>(
      isSuccess: response.isSuccess,
      serverError: response.serverError,
      serverData: response.responseData
    );
  }


  static Future<ResponseViewModel<bool>> requestCheque({OrderViewModel orderModel}) async {
    Map<String, dynamic> requestHeaders = await NetworkUtilities.getHttpHeaders();
    Map<String, dynamic> requestBody = Map();
    requestBody.putIfAbsent('payment_request', () => 'true');
    ResponseViewModel response = await NetworkUtilities.handlePutRequest(
      acceptJson: true,
      methodURL: URL.getURL(functionName: URL.PUT_UPDATE_ORDER(orderId: orderModel.orderID)),
      requestHeaders: requestHeaders,
      requestBody: requestBody,
      parserFunction: (Map<String, dynamic> passedJson){}
    );
    return ResponseViewModel<bool>(
      isSuccess: response.isSuccess,
      serverData: response.isSuccess,
      serverError: response.serverError,
    );
  }

  static callWaiterForTable(
      String tableNumber, String restaurantId, String orderId,
      {String option}) async {
    String callWaiterURL = URL.getURL(functionName: URL.CALL_WAITER_OR_PAY);
    var requestHeaders = await NetworkUtilities.getHttpHeaders();
    var requestData = {
      'status': option ?? 'Call Waiter',
      'restaurant_id': restaurantId,
      'restaurantTableNumber': tableNumber,
      'order_id': orderId,
    };

    ResponseViewModel requestChequeResponse = await NetworkUtilities.handlePostRequest(
      methodURL: callWaiterURL,
      requestHeaders: requestHeaders,
      requestBody: requestData,
      acceptJson: true,
      parserFunction: (_){},
    );
    return ResponseViewModel<bool>(
      serverData: requestChequeResponse.isSuccess,
      isSuccess: requestChequeResponse.isSuccess,
      serverError: requestChequeResponse.serverError,
    );

  }

  static reopenOrderForTable(tableNumber, restaurantId, orderId) async {
    String reOpenOrderURL = URL.getURL(functionName: URL.REOPEN_ORDER);
    var requestHeaders = await NetworkUtilities.getHttpHeaders();
    var requestData = {
      'restaurant_id': restaurantId,
      'restaurantTableNumber': tableNumber,
      'order_id': orderId,
    };

    ResponseViewModel requestChequeResponse = await NetworkUtilities.handlePostRequest(
      methodURL: reOpenOrderURL,
      requestHeaders: requestHeaders,
      requestBody: requestData,
      acceptJson: true,
      parserFunction: (_){},
    );
    return ResponseViewModel<bool>(
      serverData: requestChequeResponse.isSuccess,
      isSuccess: requestChequeResponse.isSuccess,
      serverError: requestChequeResponse.serverError,
    );
  }

  static Future<ResponseViewModel<OrderViewModel>> createDeliveryOrder({OrderViewModel orderViewModel, String addressId}) async {
    String url = URL.getURL(functionName: URL.POST_DELIVERY_ORDER);
    Map<String,dynamic> requestHeaders = await NetworkUtilities.getHttpHeaders();
    Map<String, dynamic> requestBody = Map();
    requestBody.putIfAbsent('restaurant_id', () => orderViewModel.restaurantViewModel.restaurantListViewModel.restaurantId.toString());
    requestBody.putIfAbsent('address_id', () => addressId);
    requestBody.putIfAbsent('callback_name', () => orderViewModel.deliveryOrderInfo.userName);
    requestBody.putIfAbsent('callback_phone', () => orderViewModel.deliveryOrderInfo.userPhoneNumber);
    if (orderViewModel.promoCodeViewModel != null && orderViewModel.promoCodeViewModel.promoCodeTitle != null && orderViewModel.promoCodeViewModel.promoCodeTitle.isNotEmpty) {
      requestBody.putIfAbsent('promocode', () => orderViewModel.promoCodeViewModel.promoCodeTitle);
    }
    if (orderViewModel.deliveryOrderInfo.deliveryNotes != null && orderViewModel.deliveryOrderInfo.deliveryNotes.isNotEmpty) {
      requestBody.putIfAbsent('order_notes', () => orderViewModel.deliveryOrderInfo.deliveryNotes);
    }
    if (orderViewModel.orderItems.isNotEmpty && orderViewModel.orderItems != null) {
      List<Map<String, dynamic>> _newMeals = [];
      orderViewModel.orderItems.forEach((element) {
        Map<String, dynamic> singleMeal = Map();
        if (element.quantity != null) {
          singleMeal.putIfAbsent('quantity', () => element.quantity);
        }
        if (element.userNote != null && element.userNote.isNotEmpty) {
          singleMeal.putIfAbsent('item_notes', () => element.userNote);
        }
        singleMeal.putIfAbsent('item_size', () => element.mealSize.id);
        if (element.userSelectedExtras != null) {
          List<int> extraIds = element.userSelectedExtras.map((element) => element.id).toList();
          singleMeal.putIfAbsent('item_extras', () => extraIds);
        }
        _newMeals.add(singleMeal);
      });
      requestBody.putIfAbsent('items', () => _newMeals);
    }
    ResponseViewModel response = await NetworkUtilities.handlePostRequest(
      acceptJson: true,
      methodURL: url,
      requestHeaders: requestHeaders,
      requestBody: requestBody,
      parserFunction: (Map<String, dynamic> passedJson){
        var data = passedJson[OrderViewModelJsonKeys.DATA];
        var order = data[OrderViewModelJsonKeys.ORDER];
        return OrderViewModel.fromJson(order);
      }
    );
    return ResponseViewModel<OrderViewModel>(
      isSuccess: response.isSuccess,
      serverData: response.responseData,
      serverError: response.serverError,
    );
  }


  static Future<ResponseViewModel<String>> requestPaymentLink(String orderId , String totalCost) async {
    String url = '${URL.getURL(functionName: URL.POST_REQUEST_VISA_PAYMENT_LINK)}';
    Map<String,dynamic> requestHeaders = await NetworkUtilities.getHttpHeaders();
    Map<String,dynamic> requestBody = {
      'order_id':orderId,
      'total_cost': totalCost,
    };



    ResponseViewModel requestPaymentLinkResponse =
    await NetworkUtilities.handlePostRequest(
      requestHeaders: requestHeaders,
      methodURL: url,
      acceptJson: true,
      requestBody: requestBody,
      parserFunction: (paymentLinkJson){
        if(paymentLinkJson['payment_token'] != null && paymentLinkJson['payment_token'] != 'null')
          return "${URL.getURL(functionName: URL.VIEW_COMPLETE_PAYMENT_WEB_VIEW_LINK)}${paymentLinkJson['payment_token']}";
        else
          return null;
      },
    );
    //----------------- Special Handling For Null Cases  -------------------------

    if(requestPaymentLinkResponse.responseData == null){
     return ResponseViewModel<String>(
        isSuccess: false,
        serverData: requestPaymentLinkResponse.responseData,
        serverError: ErrorViewModel(
          errorMessage: (LocalKeys.ONLINE_PAYMENT_SERVICE_UNAVAILABLE).tr(),
          errorCode: 403,
        ),
      );
    }
    else {
      return ResponseViewModel<String>(
        isSuccess: requestPaymentLinkResponse.isSuccess,
        serverData: requestPaymentLinkResponse.responseData,
        serverError: requestPaymentLinkResponse.serverError,
      );
    }
  }

  static Future<ResponseViewModel<List<OrderViewModel>>> getHistory({String historyTypeUrl, String pageNumber, String rowCount}) async {
    Map<String,dynamic> requestHeaders = await NetworkUtilities.getHttpHeaders();
    requestHeaders.putIfAbsent(HttpHeaders.contentLanguageHeader, () => Constants.currentAppLocale);
    String userId = await Repository.getUserId();
    String url = URL.getURL(functionName: URL.GET_USER_HISTORY(userId: userId, menuLanguage: Constants.currentAppLocale, historyType: historyTypeUrl, pageNumber: pageNumber, rowCount: rowCount));
    ResponseViewModel historyResponse = await NetworkUtilities.handleGetRequest(
      methodURL: url,
      requestHeaders: requestHeaders,
      parserFunction: (Map<String, dynamic> passedJson) {
        var orderList = passedJson[OrderViewModelJsonKeys.DATA];
        List<OrderViewModel> orderHistory = List();
        for (var currentItem in orderList) {
          orderHistory.add(OrderViewModel.fromJson(currentItem));
        }
        return orderHistory;
      },
    );
    return ResponseViewModel<List<OrderViewModel>>(
      isSuccess: historyResponse.isSuccess,
      serverData: historyResponse.responseData,
      serverError: historyResponse.serverError,
    );
  }

  static Future<ResponseViewModel<OrderViewModel>> getOrderById({String orderId, String menuLanguage, String orderType}) async {
    Map<String,dynamic> requestHeaders = await NetworkUtilities.getHttpHeaders();
    ResponseViewModel response = await NetworkUtilities.handleGetRequest(
      methodURL: URL.getURL(functionName: URL.GET_ORDER_BY_ID(orderId: orderId, menuLanguage: menuLanguage, orderType: orderType)),
      requestHeaders: requestHeaders,
      parserFunction: (Map<String, dynamic> passedJson) {
        var data = passedJson[OrderViewModelJsonKeys.DATA];
        var order = data[OrderViewModelJsonKeys.ORDER];
        return OrderViewModel.fromJson(order);
      },
    );
    return ResponseViewModel<OrderViewModel>(
      isSuccess: response.isSuccess,
      serverData: response.responseData,
      serverError: response.serverError,
    );
  }

  static Future<ResponseViewModel<List<PaymentMethodViewModel>>> getRestaurantPaymentMethods({String restaurantId}) async {
    Map<String,dynamic> requestHeaders = await NetworkUtilities.getHttpHeaders();
    ResponseViewModel response = await NetworkUtilities.handleGetRequest(
      methodURL: URL.getURL(functionName: URL.GET_PAYMENT_METHODS(restaurantId: restaurantId)),
      requestHeaders: requestHeaders,
      parserFunction: (Map<String, dynamic> passedJson){
        List<PaymentMethodViewModel> paymentMethodsList = List();
        var paymentMethods = passedJson['data'];
        for (int i = 0; i < paymentMethods.length; i++){
          paymentMethodsList.add(PaymentMethodViewModel.fromJson(paymentMethods[i]));
        }
        return paymentMethodsList;
      }
    );
    return ResponseViewModel<List<PaymentMethodViewModel>>(
      isSuccess: response.isSuccess,
      serverData: response.responseData,
      serverError: response.serverError
    );
  }

  static Future<ResponseViewModel<PromoCodeViewModel>> addPromoCodeToOrder({@required OrderViewModel orderViewModel, @required String orderType}) async {
    Map<String, dynamic> requestHeaders = await NetworkUtilities.getHttpHeaders();
    Map<String, dynamic> requestBody = Map();
    if (orderViewModel.orderID != null && orderViewModel.orderID.isNotEmpty) {
      requestBody.putIfAbsent('order_id', () => orderViewModel.orderID);
    }
    if (orderType != null && orderType.isNotEmpty) {
      requestBody.putIfAbsent('order_type', () => orderType);
    }
    if (orderViewModel.promoCodeViewModel != null && orderViewModel.promoCodeViewModel.promoCodeTitle != null && orderViewModel.promoCodeViewModel.promoCodeTitle.isNotEmpty) {
      requestBody.putIfAbsent('code', () => orderViewModel.promoCodeViewModel.promoCodeTitle);
    }
    ResponseViewModel response = await NetworkUtilities.handlePostRequest(
      acceptJson: true,
      methodURL: URL.getURL(functionName: URL.POST_PROMO_CODE),
      requestHeaders: requestHeaders,
      requestBody: requestBody,
      parserFunction: (Map<String, dynamic> json) {
        var data = json['data'];
        return PromoCodeViewModel.fromJson(data);
      }
    );
    return ResponseViewModel<PromoCodeViewModel>(
      isSuccess: response.isSuccess,
      serverData: response.responseData,
      serverError: response.serverError
    );
  }

  static Future<ResponseViewModel<PromoCodeViewModel>> validatePromoCode(
      { @required String orderType, @required String promoCode, @required String restaurantId,
        @required double orderSubTotal, @required String customerAddressId}) async {
    Map<String, dynamic> requestHeaders = await NetworkUtilities.getHttpHeaders();
    Map<String, dynamic> requestBody = Map();
    if (orderType != null && orderType.isNotEmpty) {
      requestBody.putIfAbsent('order_type', () => orderType);
    }
    if (promoCode != null && promoCode.isNotEmpty) {
      requestBody.putIfAbsent('code', () => promoCode);
    }
    if (orderSubTotal != null && orderSubTotal > 0.0) {
      requestBody.putIfAbsent('order_sub_total', () => orderSubTotal);
    }
    if (customerAddressId != null && customerAddressId.isNotEmpty) {
      requestBody.putIfAbsent('address_id', () => customerAddressId);
    }
    String url = URL.getURL(functionName: URL.POST_VALIDATE_PROMO_CODE(restaurantId: restaurantId));
    ResponseViewModel response = await NetworkUtilities.handlePostRequest(
      acceptJson: true,
      methodURL: url,
      requestHeaders: requestHeaders,
      requestBody: requestBody,
      parserFunction: (Map<String, dynamic> passedJson) {
        var promoCodeData = passedJson['data'];
        return PromoCodeViewModel.fromJson(promoCodeData);
      }
    );
    return ResponseViewModel<PromoCodeViewModel>(
      isSuccess: response.isSuccess,
      serverData: response.responseData,
      serverError: response.serverError,
    );
  }
}
