import 'package:ande_app/src/data_providers/models/CurrencyModel.dart';
import 'package:ande_app/src/data_providers/models/RestaurantFeaturesModel.dart';
import 'package:ande_app/src/data_providers/models/RestaurantMenuModel.dart';
import 'package:ande_app/src/utilities/ApiParseKeys.dart';
import 'package:ande_app/src/utilities/HelperFunctions.dart';

import 'LanguageModel.dart';
import 'PaymentMethodViewModel.dart';
import 'RestaurantListViewModel.dart';
import 'delivery/RestaurantDeliveryInformation.dart';
import 'product/ProductCategoryViewModel.dart';

class RestaurantViewModel {
  RestaurantListViewModel restaurantListViewModel = RestaurantListViewModel();
  RestaurantMenuModel restaurantMenuModel = RestaurantMenuModel();
  List<LanguageModel> languagesList = List();
  List<PaymentMethodViewModel> supportedPaymentMethods = List();
  RestaurantDeliveryInformation deliveryInformation;
  var restaurantDescription, restaurantCover;
  CurrencyModel restaurantCurrency;
  double restaurantTaxes, restaurantService;
  RestaurantFeaturesModel restaurantModulesModel;



  static RestaurantViewModel fromJson(Map<String,dynamic> restaurantBodyJson){

    CurrencyModel restaurantCurrency = CurrencyModel.fromJson(restaurantBodyJson[ApiParseKeys.RESTAURANT_CURRENCY]);
    List<LanguageModel> restaurantSupportedLanguages = List<LanguageModel>();
   restaurantSupportedLanguages.add(LanguageModel.fromJson(restaurantBodyJson[ApiParseKeys.RESTAURANT_PRIMARY_LANG]));
    restaurantSupportedLanguages.addAll(LanguageModel.fromListJson(restaurantBodyJson[ApiParseKeys.RESTAURANT_SUPPORTED_LANG]));
    List<ProductCategoryViewModel> restaurantCuisines = List<ProductCategoryViewModel>();
    RestaurantDeliveryInformation deliveryInformation = RestaurantDeliveryInformation();

    if (restaurantBodyJson['cuisines'] != null) {
      restaurantBodyJson['cuisines'].forEach((v) {
        restaurantCuisines.add(ProductCategoryViewModel.fromJson(v));
      });
    }

    if (restaurantBodyJson['delivery_areas'] != null) {
      deliveryInformation = RestaurantDeliveryInformation.fromJson(restaurantBodyJson['delivery_areas']);
    }

    RestaurantListViewModel miniRestaurantModel = RestaurantListViewModel(

      restaurantId: restaurantBodyJson[ApiParseKeys.RESTAURANT_ID] ?? '',
      restaurantImagePath: restaurantBodyJson[ApiParseKeys.RESTAURANT_LOGO] ?? '',
      restaurantCuisines: restaurantCuisines,
      restaurantLatitude: 0.0,
      restaurantLongitude: 0.0,
      restaurantName: restaurantBodyJson[ApiParseKeys.RESTAURANT_NAME] ?? '',
      restaurantRating: 5.0,
    );
    RestaurantFeaturesModel restaurantFeaturesModel = RestaurantFeaturesModel();
    if (restaurantBodyJson[ApiParseKeys.RESTAURANT_ACTIVE_MODULES] != null) {
      restaurantFeaturesModel = RestaurantFeaturesModel.fromJson(restaurantBodyJson[ApiParseKeys.RESTAURANT_ACTIVE_MODULES]);
    }

    RestaurantViewModel restaurantViewModel = RestaurantViewModel(
      supportedPaymentMethods: [],
      restaurantDescription: restaurantBodyJson[ApiParseKeys.RESTAURANT_DESCRIPTION] ?? '',
      restaurantListViewModel: miniRestaurantModel,
      restaurantCurrency: restaurantCurrency,
      languagesList: restaurantSupportedLanguages,
      restaurantTaxes: ParseHelper.parseNumber( restaurantBodyJson[ApiParseKeys.RESTAURANT_TAXES] ?? '', toDouble: true),
      restaurantCover: restaurantBodyJson[ApiParseKeys.RESTAURANT_COVER_IMAGE] ?? '',
      restaurantService: ParseHelper.parseNumber( restaurantBodyJson[ApiParseKeys.RESTAURANT_SERVICES] ?? '', toDouble: true),
      restaurantModulesModel: restaurantFeaturesModel,
      deliveryInformation: deliveryInformation,
    );

    return restaurantViewModel;

  }
  RestaurantViewModel(
      {this.restaurantListViewModel,
      this.restaurantTaxes,
      this.deliveryInformation,
      this.restaurantDescription,
      this.restaurantMenuModel,
      this.restaurantService,
      this.languagesList,
      this.restaurantCurrency,
      this.restaurantCover,
      this.supportedPaymentMethods,
      this.restaurantModulesModel});



  void setRestaurantMenu(RestaurantMenuModel menu){
    this.restaurantMenuModel = menu;
  }


}

class RestaurantJsonKeys {
  static const RESTAURANT_MAIL = "email";
  static const RESTAURANT_ADDRESS = "address";
  static const RESTAURANT_RATE = "rate";
  static const RESTAURANT_SERVICE = "service";
  static const RESTAURANT_TAX = "tax";
  static const RESTAURANT_LATITUDE = "latitude";
  static const RESTAURANT_LONGITUDE = "longitude";
  static const RESTAURANT_LOGO = "logoUrl";
  static const RESTAURANT_CATEGORIES = "categories";
  static const RESTAURANT_PAYMENT_METHOD = "payments";
  static const RESTAURANT_CATEGORY_ITEMS = "items";
  static const RESTAURANT_DESCRIPTION = "description";
  static const RESTAURANT_SUPPORTED_LANGUAGES = "languages";
  static const RESTAURANT_SUPPORTED_CURRENCY = "currency";
  static const RESTAURANT_MAIN_LANGUAGE = "primaryLanguage";
  static const RESTAURANT_COVER_IMAGE = "coverPhoto";
  static const RESTAURANT_DELIVERY_INFORMATION = "delivery";
  static const RESTAURANT_SERVICE_FEES = "service_fees";
}
