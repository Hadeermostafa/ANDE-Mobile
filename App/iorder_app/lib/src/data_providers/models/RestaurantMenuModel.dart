import 'package:ande_app/src/data_providers/models/LanguageModel.dart';
import 'package:ande_app/src/data_providers/models/product/ProductCategoryViewModel.dart';
import 'package:ande_app/src/utilities/ApiParseKeys.dart';

class RestaurantMenuModel {

  List<ProductCategoryViewModel> restaurantSupportedCategories  = [];
  String restaurantName , restaurantDescription;
  LanguageModel currentlyDisplayingLanguage ;

  RestaurantMenuModel({
      this.restaurantSupportedCategories,
      this.restaurantName,
      this.restaurantDescription,
      this.currentlyDisplayingLanguage});
  static RestaurantMenuModel fromJson(Map<String,dynamic> restaurantMenuMap){
    List<ProductCategoryViewModel> restaurantCategories = [];
    restaurantCategories.addAll(ProductCategoryViewModel.fromListJson(restaurantMenuMap[ApiParseKeys.RESTAURANT_MENU_AVAILABLE_CATEGORIES]));
    LanguageModel languageModel = LanguageModel();
    if (restaurantMenuMap[ApiParseKeys.RESTAURANT_MENU_RESTAURANT_LANGUAGE] != null) {
      languageModel = LanguageModel.fromJson(restaurantMenuMap[ApiParseKeys.RESTAURANT_MENU_RESTAURANT_LANGUAGE]);
    }

    return RestaurantMenuModel(
      restaurantName: restaurantMenuMap[ApiParseKeys.RESTAURANT_MENU_RESTAURANT_NAME] ?? '',
      restaurantDescription: restaurantMenuMap[ApiParseKeys.RESTAURANT_MENU_RESTAURANT_DESCRIPTION] ?? '',
      restaurantSupportedCategories: restaurantCategories,
      currentlyDisplayingLanguage: languageModel,
    );
  }





}