import 'package:ande_app/src/blocs/events/RestaurantListingEvents.dart';
import 'package:ande_app/src/data_providers/models/ErrorViewModel.dart';
import 'package:ande_app/src/data_providers/models/RestaurantListViewModel.dart';

abstract class RestaurantsListingStates {}

class RestaurantsLoading extends RestaurantsListingStates {}

class RestaurantsUninitialized extends RestaurantsListingStates {}

class RestaurantsLoaded extends RestaurantsListingStates {
  final List<RestaurantListViewModel> restaurantsData;
  RestaurantsLoaded({this.restaurantsData});
}


class RestaurantsLoadingFailed extends RestaurantsListingStates {
  final ErrorViewModel error;
  final RestaurantsListingEvents event ;
  RestaurantsLoadingFailed({this.error , this.event});
}
