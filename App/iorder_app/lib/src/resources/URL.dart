import 'package:flutter/foundation.dart';

class URL {
  // static const String SERVER_URL = "andedev-env.eba-je3ap3sa.me-south-1.elasticbeanstalk.com"; //dev
  // static const String SERVER_URL = "andeapp.com"; //production
  static const String SERVER_URL = "andetst.me-south-1.elasticbeanstalk.com"; //test


  /// BASE URL
  // static const String BASE_URL = "http://${URL.SERVER_URL}"; //dev
  //    static const String BASE_URL = "https://${URL.SERVER_URL}"; //production
     static const String BASE_URL = "http://${URL.SERVER_URL}"; //test

 /// S3
 //   static const String BASE_IMAGE_URL = "https://ande-production-s3.s3.eu-west-3.amazonaws.com/"; // dev
 //      static const String BASE_IMAGE_URL = "https://ande-prod.s3.me-south-1.amazonaws.com/"; // production
      static const String BASE_IMAGE_URL = "https://ande-production-s3.s3.eu-west-3.amazonaws.com/"; // test



  /// New APIs
  static const GET_SYSTEM_SUPPORTED_COUNTRIES = "/api/v1/system/countries";
  static const GET_RESTAURANT_BY_ID = "/api/v1/restaurants/";

  // // ignore: non_constant_identifier_names
  // static String GET_RESTAURANT_MENU(String restaurantId , String language)  => "v1/restaurants/$restaurantId/categoriesWithItems?menu_language=$language";

  // ignore: non_constant_identifier_names
  static String GET_RESTAURANT_MENU(String restaurantId, String language) => "/api/v1/restaurants/$restaurantId/categories?menu_language=$language";

  static const String POST_LOGIN_OR_REGISTER = "/api/v1/customers/registerOrLogin";

  // ignore: non_constant_identifier_names
  static String GET_ITEM_BY_ID(String restaurantId, String productId, String language) =>
      '/api/v1/restaurants/$restaurantId/items/$productId?menu_language=$language';

  static const PLACE_USER_ORDER = "/api/v1/dinein/orders";
  static const String CALL_WAITER = '/api/v1/dinein/requests/waiter';
  // ignore: non_constant_identifier_names
  static String GET_USER_HISTORY({String userId, String menuLanguage, String historyType, String pageNumber, String rowCount}) =>
      '/api/v1/customers/$userId/history?page=$pageNumber&order_type=$historyType&menu_language=$menuLanguage&rows_count=$rowCount';
  // ignore: non_constant_identifier_names
  static String GET_ORDER_BY_ID({String orderId, String menuLanguage, String orderType}) =>
      '/api/v1/$orderType/orders/$orderId?menu_language=$menuLanguage';
  // ignore: non_constant_identifier_names
  static String GET_PAYMENT_METHODS({String restaurantId}) =>
      '/api/v1/restaurants/$restaurantId/payments';

  // ignore: non_constant_identifier_names
  static String POST_UPDATE_ORDER({String orderId}) =>
      '/api/v1/dinein/$orderId/items';

  // ignore: non_constant_identifier_names
  static String PUT_UPDATE_ORDER({String orderId}) => '/api/v1/dinein/orders/$orderId';

  static String GET_DELIVERY_RESTAURANTS({@required String pageNumber, @required String countryId, @required String rowCount}) =>
      '/api/v1/delivery/restaurants?page=$pageNumber&country_id=$countryId&rows_count=$rowCount';
  static String POST_CUSTOMER_ADDRESS({@required String customerId}) =>
      '/api/v1/customers/$customerId/addresses';

  static String GET_CUSTOMER_ADDRESS({@required String customerId}) =>
      '/api/v1/customers/$customerId/addresses';

  static const POST_DELIVERY_ORDER = '/api/v1/delivery/orders';
  static String GET_ACTIVE_ORDERS({String userId, String language}) =>
      '/api/v1/customers/$userId/orders/active?menu_language=$language';

  static const String POST_PROMO_CODE = '/api/v1/system/promocodes';

  // ignore: non_constant_identifier_names
  static String POST_VALIDATE_PROMO_CODE({@required String restaurantId}) =>
      '/api/v1/restaurants/$restaurantId/promocodes/validate';

  /// OLD APIs
  static const PLACE_DELIVERY_ORDER = 'customer/delivery/createOrder';



  static const CALL_WAITER_OR_PAY = 'customer/changeOrderRestaurantUserStatus';
  static const REOPEN_ORDER = 'customer/reopenOrder';

  static const GET_DELIVERY_RESTAURANT_BY_ID = "customer/delivery/getRestaurantByID/";
  static const GET_RESTAURANTS_IN_COUNTRY = "customer/delivery/getRegisteredRestaurantsByCountry/";


  static const POST_SAVE_USER_ADDRESS = "customer/delivery/setUserAddress";
  static const GET_RETRIEVE_USER_ADDRESSES = "customer/delivery/getUserAddresses";
  static const GET_RETRIEVE_REGIONS_IN_COUNTRY = "getCountryById/";
  static const POST_CANCEL_USER_ORDER = "customer/delivery/cancelOrder";

  static const POST_REQUEST_VISA_PAYMENT_LINK = "paymob/get_paymob_token";
  static const VIEW_COMPLETE_PAYMENT_WEB_VIEW_LINK = "paymob/getPaymentView/";
  static const VIEW_PAYMENT_RESULT_URL = "paymob/paymob_post_pay";

  static getURL({@required String functionName}) {
    return BASE_URL + functionName;
  }

  static getNonApiURL({String functionName}) {
    return BASE_URL.replaceFirst("/api", "") + functionName;
  }
}
