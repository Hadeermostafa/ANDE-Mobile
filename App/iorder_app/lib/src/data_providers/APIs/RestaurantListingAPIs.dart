
import 'package:ande_app/src/data_providers/models/ResponseModel.dart';
import 'package:ande_app/src/data_providers/models/RestaurantMenuModel.dart';
import 'package:ande_app/src/data_providers/models/RestaurantViewModel.dart';
import 'package:ande_app/src/data_providers/models/product/ProductViewModel.dart';
import 'package:ande_app/src/resources/Constants.dart';
import 'package:ande_app/src/resources/URL.dart';
import 'package:ande_app/src/utilities/NetworkUtilities.dart';


class RestaurantListingAPIs {
  static Future<ResponseViewModel> getRestaurantInformation(String restaurantId) async {
    String getRestaurantById =
        "${URL.getURL(functionName: URL.GET_RESTAURANT_BY_ID)}$restaurantId";

    Map<String, String> requestHeaders = await NetworkUtilities.getHttpHeaders();
    ResponseViewModel getRestaurantResponse =
        await NetworkUtilities.handleGetRequest(
            methodURL: getRestaurantById,
            requestHeaders: requestHeaders,
            parserFunction: (responseJson) {
              RestaurantViewModel restaurantViewModel = RestaurantViewModel.fromJson(responseJson['data']);
              if (responseJson[ResponseMainKeys.LOCALE] != null)
                Constants.currentRestaurantLocale = responseJson[ResponseMainKeys.LOCALE];
              return restaurantViewModel;

            });


    return ResponseViewModel<RestaurantViewModel>(
      serverData: getRestaurantResponse.responseData,
      serverError: getRestaurantResponse.serverError,
      isSuccess: getRestaurantResponse.isSuccess,
    );
  }


  static Future<ResponseViewModel<ProductViewModel>> getItemInformation(String restaurantId, String productId, String language) async {
    String getItemInformation =
        "${URL.getURL(functionName: URL.GET_ITEM_BY_ID(restaurantId, productId, language))}";
    var requestHeaders = await NetworkUtilities.getHttpHeaders();

    ResponseViewModel productModel = await NetworkUtilities.handleGetRequest(
      parserFunction: (itemJsonResponse){
        return ProductViewModel.fromJson(itemJsonResponse[ResponseMainKeys.DATA]);
      },
      requestHeaders: requestHeaders,
      methodURL: getItemInformation,
    );
    return ResponseViewModel<ProductViewModel>(
      serverData: productModel.responseData,
      isSuccess: productModel.isSuccess,
      serverError: productModel.serverError
    );
  }

  static Future<ResponseViewModel<RestaurantMenuModel>> getRestaurantMenu(String restaurantId, String language) async {
    String getRestaurantMenuURL = URL.getURL(functionName: URL.GET_RESTAURANT_MENU(restaurantId,language));
    var requestHeaders = await NetworkUtilities.getHttpHeaders();
    ResponseViewModel productModel = await NetworkUtilities.handleGetRequest(
      parserFunction: (itemJsonResponse){
        return RestaurantMenuModel.fromJson(itemJsonResponse);
      },
      requestHeaders: requestHeaders,
      methodURL: getRestaurantMenuURL,
    );
    return ResponseViewModel<RestaurantMenuModel>(
        serverData: productModel.responseData,
        isSuccess: productModel.isSuccess,
        serverError: productModel.serverError
    );
  }

  static Future<ResponseViewModel<bool>> callWaiter({String tableId, String orderId}) async {
    Map<String, dynamic> body = {};
    body.putIfAbsent('table_id', () => tableId);
    if (orderId != null) {
      body.putIfAbsent('order_id', () => orderId);
    }
    Map<String, String> requestHeaders = await NetworkUtilities.getHttpHeaders();
    ResponseViewModel response = await NetworkUtilities.handlePostRequest(
      acceptJson: true,
      requestBody: body,
      methodURL: URL.getURL(functionName: URL.CALL_WAITER),
      requestHeaders: requestHeaders,
      parserFunction: (Map<String, dynamic> rawJson){}
    );
    return ResponseViewModel<bool>(
      isSuccess: response.isSuccess,
      serverData: response.isSuccess,
      serverError: response.serverError,
    );
  }
}

class ResponseMainKeys {
  static const String RESTAURANTS = "restaurants";
  //------------------------
  static const String RESTAURANT = "restaurant";
  static const String LOCALE = "locale";
  //-----------------------
  static const String DATA = "data";
}
