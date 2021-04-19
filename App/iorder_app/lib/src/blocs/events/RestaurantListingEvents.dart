import 'package:flutter/cupertino.dart';

abstract class RestaurantsListingEvents {}

class LoadRestaurants extends RestaurantsListingEvents {

}

class SearchRestaurant extends RestaurantsListingEvents {
  final String queryText;
  SearchRestaurant({this.queryText});
}
