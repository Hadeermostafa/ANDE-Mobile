import 'dart:io';

import 'package:ande_app/src/data_providers/APIs/ApplicationDataAPIs.dart';
import 'package:ande_app/src/data_providers/APIs/CustomerAPIs.dart';
import 'package:ande_app/src/data_providers/APIs/DeliveryAPIs.dart';
import 'package:ande_app/src/data_providers/APIs/LoginAPIs.dart';
import 'package:ande_app/src/data_providers/APIs/OrdersAPIs.dart';
import 'package:ande_app/src/data_providers/APIs/RestaurantListingAPIs.dart';
import 'package:ande_app/src/data_providers/models/ActiveOrderViewModel.dart';
import 'package:ande_app/src/data_providers/models/AddressToServerModel.dart';
import 'package:ande_app/src/data_providers/models/CountryModel.dart';
import 'package:ande_app/src/data_providers/models/CustomerAddressViewModel.dart';
import 'package:ande_app/src/data_providers/models/LanguageModel.dart';
import 'package:ande_app/src/data_providers/models/OrderViewModel.dart';
import 'package:ande_app/src/data_providers/models/PaymentMethodViewModel.dart';
import 'package:ande_app/src/data_providers/models/PromocodeViewModel.dart';
import 'package:ande_app/src/data_providers/models/ResponseModel.dart';
import 'package:ande_app/src/data_providers/models/RestaurantListViewModel.dart';
import 'package:ande_app/src/data_providers/models/RestaurantMenuModel.dart';
import 'package:ande_app/src/data_providers/models/RestaurantViewModel.dart';
import 'package:ande_app/src/data_providers/models/UserViewModel.dart';
import 'package:ande_app/src/data_providers/models/delivery/CityViewModel.dart';
import 'package:ande_app/src/data_providers/models/delivery/LocationViewModel.dart';
import 'package:ande_app/src/data_providers/models/product/ProductViewModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class Repository {
  static Future<ResponseViewModel<User>> loginAnonymously() async =>
      await LoginAPIs.signInAnonymously();

  static bool isAnonymousUser() =>
      LoginAPIs.isAnonymousUser();



  static Future<ResponseViewModel<String>> loginWithFacebook() async =>
      await LoginAPIs.loginWithFacebook();


  static Future<ResponseViewModel<String>> loginWithApple() async =>
      await LoginAPIs.loginWithApple();

  static Future<ResponseViewModel<String>> loginWithPhone(
      AuthCredential credential) async =>
      await LoginAPIs.loginWithPhone(credential);

  static Future<ResponseViewModel<OrderViewModel>> createOrder(
      OrderViewModel orderModel) async {
   ResponseViewModel<OrderViewModel> response =  await OrdersAPIs.createOrder(orderModel);
    if (response.isSuccess == false && response.serverError.errorCode == HttpStatus.unauthorized) {
      ResponseViewModel<UserViewModel> loginResult = await LoginAPIs.silentUserLogin();
      if (loginResult.isSuccess) {
        await saveAccessToken(loginResult.responseData.userToken);
        try {
          await saveUserId(loginResult.responseData.userId);
        } catch (e) {}
        return await OrdersAPIs.createOrder(orderModel);
      }
      return response;
    }
    return response;

  }
  static Future<ResponseViewModel<OrderViewModel>> createDeliveryOrder(
      OrderViewModel orderModel,String addressId) async {
   ResponseViewModel<OrderViewModel> response =  await OrdersAPIs.createDeliveryOrder(orderViewModel: orderModel, addressId: addressId);
   if (response.isSuccess == false && response.serverError.errorCode == HttpStatus.unauthorized) {
     ResponseViewModel<UserViewModel> loginResult = await LoginAPIs.silentUserLogin();
     if (loginResult.isSuccess) {
       await saveAccessToken(loginResult.responseData.userToken);
       try {
         await saveUserId(loginResult.responseData.userId);
       } catch (e) {}
       return await OrdersAPIs.createDeliveryOrder(orderViewModel: orderModel, addressId: addressId);
     }
     return response;
   }
   return response ;

  }


  static Future<User> getCurrentUser() async =>
      await LoginAPIs.getCurrentUser();

  static Future<ResponseViewModel<bool>> requestCheque(
      {OrderViewModel orderModel}) async {

    ResponseViewModel<bool> response =  await OrdersAPIs.requestCheque(orderModel: orderModel);
    if (response.isSuccess == false && response.serverError.errorCode == HttpStatus.unauthorized) {
      ResponseViewModel<UserViewModel> loginResult = await LoginAPIs.silentUserLogin();
      if (loginResult.isSuccess) {
        await saveAccessToken(loginResult.responseData.userToken);
        try {
          await saveUserId(loginResult.responseData.userId);
        } catch (e) {}
        return await OrdersAPIs.requestCheque(orderModel: orderModel);
      }
      return response;
    }
    return response ;



  }
  static serverLogin({String socialMediaToken}) async {
  return  await LoginAPIs.serverLogin(socialMediaToken: socialMediaToken);

  }

  static saveAccessToken(String serverToken) async =>
      await LoginAPIs.saveAccessToken(userToken: serverToken);

  static saveUserId(String userId) async =>
      await LoginAPIs.saveUserId(userId: userId);

  static getAccessToken() async => await LoginAPIs.getAccessToken();

  static Future<String> getUserId() async => await LoginAPIs.getUserId();

  static Future<ResponseViewModel<String>> loginWithTwitter() async =>
      await LoginAPIs.loginWithTwitter();

  static Future<ResponseViewModel<bool>> callWaiterForTable(String tableNumber,
      String restaurantId, String orderId,
      {String option}) async {
    ResponseViewModel<bool> response = await OrdersAPIs.callWaiterForTable(tableNumber, restaurantId, orderId,
        option: option);

    if (response.isSuccess == false && response.serverError.errorCode == HttpStatus.unauthorized) {
      ResponseViewModel<UserViewModel> loginResult = await LoginAPIs.silentUserLogin();
      if (loginResult.isSuccess) {
        await saveAccessToken(loginResult.responseData.userToken);
        try {
          await saveUserId(loginResult.responseData.userId);
        } catch (e) {}
        return await OrdersAPIs.callWaiterForTable(tableNumber, restaurantId, orderId,
            option: option);
      }
      return response;
    }
    return response;

  }

  static Future<ResponseViewModel<ProductViewModel>> getItemInformation(
      String restaurantId, String productId, String language) async{
    ResponseViewModel<ProductViewModel> response =  await RestaurantListingAPIs.getItemInformation(
        restaurantId, productId, language);

    if (response.isSuccess == false && response.serverError.errorCode == HttpStatus.unauthorized) {
      ResponseViewModel<UserViewModel> loginResult = await LoginAPIs.silentUserLogin();
      if (loginResult.isSuccess) {
        await saveAccessToken(loginResult.responseData.userToken);
        try {
          await saveUserId(loginResult.responseData.userId);
        } catch (e) {}
        return await  RestaurantListingAPIs.getItemInformation(
            restaurantId, productId, language);
      }
      return response;
    }
    return response;

  }



  static Future<ResponseViewModel<bool>> serverLogout() async =>
      await LoginAPIs.serverLogout();

  static removeAccessToken() async => await LoginAPIs.removeAccessToken();

  static Future<
      ResponseViewModel<List<RestaurantListViewModel>>> getRestaurantsInCountry(
      {String countryCode, int pageNo, int pageSize}) async =>
      await DeliveryAPIs.getRestaurantsListByCountry(
          countryCode, pageNo, pageSize);

  static Future<ResponseViewModel<List<CountryModel>>> loadSupportedCountries() async {
    ResponseViewModel<List<CountryModel>> response = await ApplicationDataAPIs.getSystemSupportedCountries();
    if (response.isSuccess == false && response.serverError.errorCode == HttpStatus.unauthorized) {
      ResponseViewModel<UserViewModel> loginResult = await LoginAPIs.silentUserLogin();
      if (loginResult.isSuccess) {
        await saveAccessToken(loginResult.responseData.userToken);
        try {
          await saveUserId(loginResult.responseData.userId);
        } catch (e) {}
        return await ApplicationDataAPIs.getSystemSupportedCountries();
      }
      return response;
    }
    return response;

  }

  static Future<ResponseViewModel<RestaurantViewModel>> getDeliveryRestaurantInformation(
      String restaurantId) async {
    ResponseViewModel<RestaurantViewModel> response = await DeliveryAPIs.getDeliveryRestaurantInformation(restaurantId);
    if (response.isSuccess == false && response.serverError.errorCode == HttpStatus.unauthorized) {
      ResponseViewModel<UserViewModel> loginResult = await LoginAPIs.silentUserLogin();
      if (loginResult.isSuccess) {
        await saveAccessToken(loginResult.responseData.userToken);
        try {
          await saveUserId(loginResult.responseData.userId);
        } catch (e) {}
        return await DeliveryAPIs.getDeliveryRestaurantInformation(restaurantId);
      }
      return response;
    }
    return response;
  }


  static Future<ResponseViewModel> getRestaurantInformation(String restaurantId) async {
    ResponseViewModel response = await RestaurantListingAPIs.getRestaurantInformation(restaurantId);
    if (response.isSuccess == false && response.serverError.errorCode == HttpStatus.unauthorized) {
      ResponseViewModel<UserViewModel> loginResult = await LoginAPIs.silentUserLogin();
      if (loginResult.isSuccess) {
        await saveAccessToken(loginResult.responseData.userToken);
        try {
          await saveUserId(loginResult.responseData.userId);
        } catch (e) {}
        return await RestaurantListingAPIs.getRestaurantInformation(restaurantId);
      }
      return response;
    }
    return response;
  }

  static Future<ResponseViewModel<RestaurantMenuModel>> getRestaurantMenu(
      String restaurantId, String language) async {
    ResponseViewModel<RestaurantMenuModel> response =  await RestaurantListingAPIs.getRestaurantMenu(restaurantId, language);

    if (response.isSuccess == false && response.serverError.errorCode == HttpStatus.unauthorized) {
      ResponseViewModel<UserViewModel> loginResult = await LoginAPIs.silentUserLogin();
      if (loginResult.isSuccess) {
        await saveAccessToken(loginResult.responseData.userToken);
        try {
          await saveUserId(loginResult.responseData.userId);
        } catch (e) {}
        return await RestaurantListingAPIs.getRestaurantMenu(restaurantId, language);
      }
      return response;
    }
    return response;

  }

  static Future<ResponseViewModel<bool>> saveNewAddress(
      {LocationViewModel address}) async =>
      DeliveryAPIs.saveDeliveryAddress(address);

  static Future<ResponseViewModel<List<LocationViewModel>>> getUserAddresses(
      {LanguageModel address}) async =>
      DeliveryAPIs.getUserAddresses();

  static Future<ResponseViewModel<List<RegionViewModel>>> getRegionsInCountry(
      {int countryId}) async =>
      await DeliveryAPIs.getRegionsInCountry(countryId);

  static Future<ResponseViewModel<bool>> cancelOrder(
      {OrderViewModel order}) async {
    return await DeliveryAPIs.cancelUserOrder(order);
  }


  static Future<ResponseViewModel<String>> requestPaymentLink(String orderId,
      String totalPayment) =>
      OrdersAPIs.requestPaymentLink(orderId, totalPayment);

  static Future<void> deleteAnonymousUser() async =>
      await LoginAPIs.deleteAnonymousUser();

  static Future<ResponseViewModel<bool>> callWaiter(
      {String tableId, String orderId}) async {
    ResponseViewModel<bool> response =  await RestaurantListingAPIs.callWaiter(tableId: tableId);

    if (response.isSuccess == false && response.serverError.errorCode == HttpStatus.unauthorized) {
      ResponseViewModel<UserViewModel> loginResult = await LoginAPIs.silentUserLogin();
      if (loginResult.isSuccess) {
        await saveAccessToken(loginResult.responseData.userToken);
        try {
          await saveUserId(loginResult.responseData.userId);
        } catch (e) {}
        return await RestaurantListingAPIs.callWaiter(tableId: tableId);
      }
      return response;
    }
    return response;


  }
  static Future<ResponseViewModel<List<OrderViewModel>>> getHistory({String historyTypeUrl, String pageNumber, String rowCount}) async  {
    ResponseViewModel<List<OrderViewModel>> response = await OrdersAPIs.getHistory(historyTypeUrl: historyTypeUrl, pageNumber: pageNumber, rowCount: rowCount);

    if (response.isSuccess == false &&
        response.serverError.errorCode == HttpStatus.unauthorized) {
      ResponseViewModel<UserViewModel> loginResult = await LoginAPIs.silentUserLogin();
      if (loginResult.isSuccess) {
        await saveAccessToken(loginResult.responseData.userToken);
        try {
          await saveUserId(loginResult.responseData.userId);
        } catch (e) {}
        return await OrdersAPIs.getHistory(historyTypeUrl: historyTypeUrl, pageNumber: pageNumber, rowCount: rowCount);
      }
      return response;
    }

    return response;

  }

  static Future<ResponseViewModel<OrderViewModel>> getOrderById({String orderId, String menuLanguage, String orderType}) async {
    ResponseViewModel<OrderViewModel> response = await OrdersAPIs
        .getOrderById(orderId: orderId, menuLanguage: menuLanguage, orderType: orderType);

    if (response.isSuccess == false &&
        response.serverError.errorCode == HttpStatus.unauthorized) {
      ResponseViewModel<UserViewModel> loginResult = await LoginAPIs
          .silentUserLogin();
      if (loginResult.isSuccess) {
        await saveAccessToken(loginResult.responseData.userToken);
        try {
          await saveUserId(loginResult.responseData.userId);
        } catch (e) {}
        return await OrdersAPIs.getOrderById(
            orderId: orderId, menuLanguage: menuLanguage, orderType: orderType);
      }
      return response;
    }

    return response;
  }

  static Future<ResponseViewModel<UserViewModel>> silentUserLogin() async =>
      await LoginAPIs.silentUserLogin();

  static Future<ResponseViewModel<List<PaymentMethodViewModel>>> getRestaurantPaymentMethods({String restaurantId}) async {
    ResponseViewModel<List<PaymentMethodViewModel>> response = await OrdersAPIs.getRestaurantPaymentMethods(restaurantId: restaurantId);

    if (response.isSuccess == false &&
        response.serverError.errorCode == HttpStatus.unauthorized) {
      ResponseViewModel<UserViewModel> loginResult = await LoginAPIs.silentUserLogin();
      if (loginResult.isSuccess) {
        await saveAccessToken(loginResult.responseData.userToken);
        try {
          await saveUserId(loginResult.responseData.userId);
        } catch (e) {}
        return await OrdersAPIs.getRestaurantPaymentMethods(restaurantId: restaurantId);
      }
    }
    return response;
  }

  static Future<ResponseViewModel<OrderViewModel>> updateOrder({OrderViewModel orderViewModel}) async {
    ResponseViewModel<OrderViewModel> response = await OrdersAPIs.updateOrder(orderModel: orderViewModel);


    if (response.isSuccess == false &&
        response.serverError.errorCode == HttpStatus.unauthorized) {
      ResponseViewModel<UserViewModel> loginResult = await LoginAPIs.silentUserLogin();
      if (loginResult.isSuccess) {
        await saveAccessToken(loginResult.responseData.userToken);
        try {
          await saveUserId(loginResult.responseData.userId);
        } catch (e) {}
        return await OrdersAPIs.updateOrder(orderModel: orderViewModel);
      }
    }
    return response;
  }

  static Future<ResponseViewModel<List<RestaurantListViewModel>>> getDeliveryRestaurants(
      {@required String pageNumber, @required String countryId, @required rowCount}
      ) async {
    ResponseViewModel<List<RestaurantListViewModel>> response = await DeliveryAPIs.getDeliveryRestaurants(pageNumber: pageNumber, countryId: countryId, rowCount: rowCount);
    if (response.isSuccess == false &&
        response.serverError.errorCode == HttpStatus.unauthorized) {
      ResponseViewModel<UserViewModel> loginResult = await LoginAPIs.silentUserLogin();
      if (loginResult.isSuccess) {
        await saveAccessToken(loginResult.responseData.userToken);
        try {
          await saveUserId(loginResult.responseData.userId);
        } catch (e) {}
        return await DeliveryAPIs.getDeliveryRestaurants(pageNumber: pageNumber, countryId: countryId, rowCount: rowCount);
      }
    }
    return response;
  }

  static Future<ResponseViewModel<bool>> addCustomerAddress({AddressToServerModel address}) async {
    ResponseViewModel<bool> response = await CustomerAPIs.addCustomerAddress(addressToServerModel: address);
    if (response.isSuccess == false &&
        response.serverError.errorCode == HttpStatus.unauthorized) {
      ResponseViewModel<UserViewModel> loginResult = await LoginAPIs.silentUserLogin();
      if (loginResult.isSuccess) {
        await saveAccessToken(loginResult.responseData.userToken);
        try {
          await saveUserId(loginResult.responseData.userId);
        } catch (e) {}
        return CustomerAPIs.addCustomerAddress(addressToServerModel: address);
      }
    }
    return response;
  }

  static Future<ResponseViewModel<List<CustomerAddressViewModel>>> getCustomerAddresses() async {
    ResponseViewModel<List<CustomerAddressViewModel>> response = await CustomerAPIs.getCustomerAddresses();
    if (response.isSuccess == false &&
        response.serverError.errorCode == HttpStatus.unauthorized) {
      ResponseViewModel<UserViewModel> loginResult = await LoginAPIs.silentUserLogin();
      if (loginResult.isSuccess) {
        await saveAccessToken(loginResult.responseData.userToken);
        try {
          await saveUserId(loginResult.responseData.userId);
        } catch (e) {}
        return await CustomerAPIs.getCustomerAddresses();
      }
    }
    return response;
  }

  static Future<ResponseViewModel<ActiveOrderViewModel>> getCustomerActiveOrders() async {
    ResponseViewModel<ActiveOrderViewModel> response = await CustomerAPIs.getCustomerActiveOrders();
    if (response.isSuccess == false &&
        response.serverError.errorCode == HttpStatus.unauthorized) {
      ResponseViewModel<UserViewModel> loginResult = await LoginAPIs.silentUserLogin();
      if (loginResult.isSuccess) {
        await saveAccessToken(loginResult.responseData.userToken);
        try {
          await saveUserId(loginResult.responseData.userId);
        } catch (e) {}
        return await CustomerAPIs.getCustomerActiveOrders();
      }
    }
    return response;
  }

  static Future<ResponseViewModel<PromoCodeViewModel>> addPromoCodeToOrder({@required OrderViewModel orderViewModel, @required String orderType}) async {
    ResponseViewModel<PromoCodeViewModel> response =
        await OrdersAPIs.addPromoCodeToOrder(orderViewModel: orderViewModel, orderType: orderType);
    if (response.isSuccess == false &&
        response.serverError.errorCode == HttpStatus.unauthorized) {
      ResponseViewModel<UserViewModel> loginResult = await LoginAPIs.silentUserLogin();
      if (loginResult.isSuccess) {
        await saveAccessToken(loginResult.responseData.userToken);
        try {
          await saveUserId(loginResult.responseData.userId);
        } catch (e) {}
        return await OrdersAPIs.addPromoCodeToOrder(orderViewModel: orderViewModel, orderType: orderType);
      }
    }
    return response;
  }

  static Future<ResponseViewModel<PromoCodeViewModel>> validatePromoCode(
      { @required String orderType, @required String promoCode, @required String restaurantId,
        @required double orderSubTotal, @required String customerAddressId}) async {
    ResponseViewModel<PromoCodeViewModel> response =
      await OrdersAPIs.validatePromoCode(
          orderType: orderType, promoCode: promoCode, restaurantId: restaurantId,
          orderSubTotal: orderSubTotal, customerAddressId: customerAddressId);
    if (response.isSuccess == false &&
        response.serverError.errorCode == HttpStatus.unauthorized) {
      ResponseViewModel<UserViewModel> loginResult = await LoginAPIs.silentUserLogin();
      if (loginResult.isSuccess) {
        await saveAccessToken(loginResult.responseData.userToken);
        try {
          await saveUserId(loginResult.responseData.userId);
        } catch (e) {}
        return await OrdersAPIs.validatePromoCode(
            orderType: orderType, promoCode: promoCode, restaurantId: restaurantId,
            orderSubTotal: orderSubTotal, customerAddressId: customerAddressId);
      }
    }
    return response;
  }
}
