import 'package:flutter/material.dart';

import 'product/ProductCategoryViewModel.dart';
class RestaurantListViewModel extends Comparable {
  var restaurantId, restaurantImagePath, restaurantName;
  final double restaurantLatitude, restaurantLongitude;

  List<ProductCategoryViewModel> restaurantCuisines = List();
  var restaurantRating;

  RestaurantListViewModel(
      {this.restaurantName,
      this.restaurantRating,
      this.restaurantId,
      this.restaurantLatitude,
      this.restaurantLongitude,
      this.restaurantCuisines,
      this.restaurantImagePath});

  static RestaurantListViewModel fromJson(singleRestaurantJson) {

    try {
      /*List<ProductCategoryViewModel> restaurantCategories = List<ProductCategoryViewModel>();
      if (singleRestaurantJson['categories'] != null) {
        singleRestaurantJson['categories'].forEach((v) {
          restaurantCategories.add(ProductCategoryViewModel.fromJson(v));
        });
      }*/

      List<ProductCategoryViewModel> restaurantCuisines =
          List<ProductCategoryViewModel>();
      if (singleRestaurantJson['cuisines'] != null) {
        singleRestaurantJson['cuisines'].forEach((v) {
          restaurantCuisines.add(ProductCategoryViewModel.fromJson(v));
        });
      }
      return RestaurantListViewModel(
        restaurantImagePath: singleRestaurantJson[
                RestaurantListViewModelJsonKeys.RESTAURANT_LIST_LOGO] ?? '',
        restaurantName: singleRestaurantJson[RestaurantListViewModelJsonKeys.RESTAURANT_LIST_NAME] ?? '',
        restaurantCuisines: restaurantCuisines,
        restaurantId: singleRestaurantJson[
                RestaurantListViewModelJsonKeys.RESTAURANT_LIST_ID] ??
            '-1',
        // restaurantCategories: restaurantCategories,
      );
    } catch (ex) {
      throw ex.toString();
    }
  }

  static List<RestaurantListViewModel> fromListJson(restaurantListJson) {
    List<RestaurantListViewModel> restaurants = List();
    try {
      if (restaurantListJson != null && restaurantListJson is List) {
        for (int i = 0; i < restaurantListJson.length; i++)
          restaurants
              .add(RestaurantListViewModel.fromJson(restaurantListJson[i]));
      }
    } catch (exception) {
      debugPrint("Exception while parsing all restaurants json => $exception");
    }
    return restaurants;
  }

  @override
  int compareTo(other) {
    if (this.restaurantId == other.restaurantId)
      return 0;
    else
      return 1;
  }
}

class RestaurantListViewModelJsonKeys {
  static const RESTAURANT_LIST_ID = "id";
  static const RESTAURANT_LIST_NAME = "name";
  static const RESTAURANT_LIST_MAIL = "email";
  static const RESTAURANT_LIST_LOGO = "logoUrl";
  static const RESTAURANT_LIST_KITCHEN = "cuisines";
  static const RESTAURANT_LIST_IMAGE = "logo";
}
