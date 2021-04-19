import 'package:ande_app/src/blocs/events/SingleRestaurantEvents.dart';
import 'package:ande_app/src/data_providers/models/ErrorViewModel.dart';
import 'package:ande_app/src/data_providers/models/RestaurantViewModel.dart';

abstract class SingleRestaurantStates {}



class RestaurantInformationLoading extends SingleRestaurantStates {}

class RestaurantInformationLoaded extends SingleRestaurantStates {
  final RestaurantViewModel restaurantViewModel;
  RestaurantInformationLoaded({this.restaurantViewModel});
}


class RestaurantInformationLoadingError extends SingleRestaurantStates {
  final ErrorViewModel error;
  final SingleRestaurantEvents event ;
  RestaurantInformationLoadingError({this.error , this.event});
}

