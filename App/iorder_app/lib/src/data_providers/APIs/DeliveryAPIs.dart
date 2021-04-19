import 'package:ande_app/src/data_providers/models/OrderViewModel.dart';
import 'package:ande_app/src/data_providers/models/ResponseModel.dart';
import 'package:ande_app/src/data_providers/models/RestaurantListViewModel.dart';
import 'package:ande_app/src/data_providers/models/RestaurantViewModel.dart';
import 'package:ande_app/src/data_providers/models/delivery/CityViewModel.dart';
import 'package:ande_app/src/data_providers/models/delivery/LocationViewModel.dart';
import 'package:ande_app/src/data_providers/models/delivery/RestaurantDeliveryInformation.dart';
import 'package:ande_app/src/resources/Constants.dart';
import 'package:ande_app/src/resources/URL.dart';
import 'package:ande_app/src/utilities/NetworkUtilities.dart';
import 'package:flutter/material.dart';

import 'RestaurantListingAPIs.dart';

class DeliveryAPIs {
  static Future<ResponseViewModel<List<RestaurantListViewModel>>>
      getRestaurantsListByCountry(
          String country, int pageNo, int pageSize) async {
    Map<String, String> requestHeaders = await NetworkUtilities.getHttpHeaders();
    String getAllRestaurants = URL.getURL(
        functionName:
            "${URL.GET_RESTAURANTS_IN_COUNTRY}$country/${Constants.currentAppLocale}/$pageSize?page=$pageNo");
    ResponseViewModel getAllRestaurantListing =
        await NetworkUtilities.handleGetRequest(
            requestHeaders: requestHeaders,
            methodURL: getAllRestaurants,
            parserFunction: (restaurantsListingJson) {
              return RestaurantListViewModel.fromListJson(
                  restaurantsListingJson["restaurants"]);
            });
    return ResponseViewModel<List<RestaurantListViewModel>>(
      serverData: getAllRestaurantListing.responseData,
      serverError: getAllRestaurantListing.serverError,
      isSuccess: getAllRestaurantListing.isSuccess,
    );
  }

  static Future<ResponseViewModel<RestaurantViewModel>> getDeliveryRestaurantInformation(restaurantId) async {
    String getRestaurantById =
        "${URL.getURL(functionName: URL.GET_DELIVERY_RESTAURANT_BY_ID)}$restaurantId/${Constants.currentRestaurantLocale}";

    Map<String, String> requestHeaders = await NetworkUtilities.getHttpHeaders();
    ResponseViewModel getRestaurantResponse =
        await NetworkUtilities.handleGetRequest(
            methodURL: getRestaurantById,
            requestHeaders: requestHeaders,
            parserFunction: (responseJson) {
              if (responseJson[ResponseMainKeys.LOCALE] != null)
                Constants.currentRestaurantLocale =
                    responseJson[ResponseMainKeys.LOCALE];
              RestaurantViewModel restaurantViewModel =
                  RestaurantViewModel.fromJson(
                      responseJson[ResponseMainKeys.RESTAURANT]);

              //--------- Special handling if the Backend returned null for the delivery information -----//
              if (restaurantViewModel.deliveryInformation == null) {
                restaurantViewModel.deliveryInformation =
                    RestaurantDeliveryInformation(
                  feesType: DeliveryFeesType.FIXED_COST,
                );
              }
              return restaurantViewModel;
            });

    return ResponseViewModel<RestaurantViewModel>(
      serverData: getRestaurantResponse.responseData,
      serverError: getRestaurantResponse.serverError,
      isSuccess: getRestaurantResponse.isSuccess,
    );
  }

  static Future< ResponseViewModel<bool>> saveDeliveryAddress(LocationViewModel address) async {
    String saveAddressURL =
        URL.getURL(functionName: URL.POST_SAVE_USER_ADDRESS);
    Map<String, String> requestHeaders = await NetworkUtilities.getHttpHeaders();
    Map<String, dynamic> requestBody = {
      "country_id": address.countryId ?? 1,
      "city_id": address.regionInformation.cityId ?? 1,
      "region_id": address.regionInformation.regionId ?? 1,
      "street": address.streetName ?? '',
      "building": address.buildingNo.toString() ?? 0.toString(),
      "floor": address.floorNo.toString() ?? 0.toString(),
      "latitude": address.lat ?? 0.0,
      "magnitude": address.lon ?? 0.0,
      "additional_directions": address.notes ?? '',
    };
    ResponseViewModel saveAddressResponse =
        await NetworkUtilities.handlePostRequest(
            acceptJson: true,
            requestHeaders: requestHeaders,
            methodURL: saveAddressURL,
            requestBody: requestBody,
            parserFunction: (jsonResponse) {
              return true;
            });
    return ResponseViewModel<bool>(
      serverData: saveAddressResponse.responseData,
      isSuccess: saveAddressResponse.isSuccess,
      serverError: saveAddressResponse.serverError,
    );
  }

  static Future<ResponseViewModel<List<LocationViewModel>>>
      getUserAddresses() async {
    String getUserAddressesURL =
        URL.getURL(functionName: URL.GET_RETRIEVE_USER_ADDRESSES);
    Map<String, String> requestHeaders = await NetworkUtilities.getHttpHeaders();
    ResponseViewModel getRestaurantResponse =
        await NetworkUtilities.handleGetRequest(
            methodURL: getUserAddressesURL,
            requestHeaders: requestHeaders,
            parserFunction: (responseJson) {
              return LocationViewModel.fromListJson(
                  responseJson['user_addresses']);
            });

    return ResponseViewModel<List<LocationViewModel>>(
      serverData: getRestaurantResponse.responseData,
      serverError: getRestaurantResponse.serverError,
      isSuccess: getRestaurantResponse.isSuccess,
    );
  }

  static Future<ResponseViewModel<List<RegionViewModel>>> getRegionsInCountry(
      int countryId) async {
    String getRegionsInCountry =
        '${URL.getURL(functionName: URL.GET_RETRIEVE_REGIONS_IN_COUNTRY)}$countryId/${Constants.currentAppLocale}';

    Map<String, String> requestHeaders = await NetworkUtilities.getHttpHeaders();
    ResponseViewModel getRestaurantResponse =
        await NetworkUtilities.handleGetRequest(
            methodURL: getRegionsInCountry,
            requestHeaders: requestHeaders,
            parserFunction: (responseJson) {
              return RegionViewModel.fromListJson(
                  responseJson['country']['cities']);
            });

    return ResponseViewModel<List<RegionViewModel>>(
      serverData: getRestaurantResponse.responseData,
      serverError: getRestaurantResponse.serverError,
      isSuccess: getRestaurantResponse.isSuccess,
    );
  }

  static cancelUserOrder(OrderViewModel order) async {
    String cancelOrderURL =
        URL.getURL(functionName: URL.POST_CANCEL_USER_ORDER);
    Map<String, String> requestHeaders = await NetworkUtilities.getHttpHeaders();
    Map<String, dynamic> requestBody = {'order_id': order.orderID};

    ResponseViewModel cancelResponse = await NetworkUtilities.handlePostRequest(
        requestHeaders: requestHeaders,
        requestBody: requestBody,
        acceptJson: true,
        methodURL: cancelOrderURL,
        parserFunction: (responseJson) {
          return true;
        });
    return ResponseViewModel<bool>(
      isSuccess: cancelResponse.isSuccess,
      serverError: cancelResponse.serverError,
      serverData: cancelResponse.responseData,
    );
  }

  static Future<ResponseViewModel<List<RestaurantListViewModel>>> getDeliveryRestaurants(
  {@required String pageNumber, @required String countryId, @required rowCount}
      ) async {
    Map<String, String> requestHeaders = await NetworkUtilities.getHttpHeaders();
    String url = URL.GET_DELIVERY_RESTAURANTS(pageNumber: pageNumber, countryId: countryId, rowCount: rowCount);
    String deliveryRestaurantsUrl = URL.getURL(functionName: url);
    ResponseViewModel response = await NetworkUtilities.handleGetRequest(
      methodURL: deliveryRestaurantsUrl,
      requestHeaders: requestHeaders,
      parserFunction: (Map<String, dynamic> passedJson) {
        var restaurantList = passedJson['data'];
        List<RestaurantListViewModel> restaurantListResponse = [];
        restaurantListResponse = RestaurantListViewModel.fromListJson(restaurantList);
        return restaurantListResponse;
      }
    );
    return ResponseViewModel<List<RestaurantListViewModel>>(
      isSuccess: response.isSuccess,
      serverData: response.responseData,
      serverError: response.serverError
    );
  }

  /*static Future<ResponseViewModel<RestaurantViewModel>> getDeliveryRestaurantById({String restaurantId, String menuLang}) async {
    Map<String, String> requestHeaders = await NetworkUtilities.getHttpHeaders();
    String deliveryRestaurantInfoUrl = URL.getURL(functionName: URL.GET_RESTAURANT_MENU(restaurantId, menuLang));
    ResponseViewModel response = await NetworkUtilities.handleGetRequest(
      methodURL: deliveryRestaurantInfoUrl,
      requestHeaders: requestHeaders,
      parserFunction: (Map<String, dynamic> passedJson) {
        debugPrint('''
        ********************Delivery************************
        delivery restaurant response => $passedJson
        ********************************************
        ''');
      }
    );
    return ResponseViewModel<RestaurantViewModel>(
      isSuccess: response.isSuccess,
      serverData: response.responseData,
      serverError: response.serverError
    );
  }*/
}
