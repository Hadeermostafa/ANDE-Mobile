import 'package:ande_app/src/blocs/events/UserEvents.dart';
import 'package:ande_app/src/data_providers/models/ErrorViewModel.dart';
import 'package:ande_app/src/data_providers/models/OrderViewModel.dart';
import 'package:ande_app/src/ui/screens/RestaurantSplashScreen.dart';

abstract class UserStates {}

class UserLoadingState extends UserStates {}

class UserLoadingFailed extends UserStates {
  final UserEvents event;
  final ErrorViewModel error;
  UserLoadingFailed({this.event, this.error});
}

class UserInitialState extends UserStates {}

abstract class UserLoadedState extends UserStates {}

class UserLoadedWithoutActiveOrderState extends UserLoadedState {}

class UserLoadedWithActiveOrderState extends UserLoadedState {
  final OrderViewModel activeOrder;
  final RestaurantLoadingType restaurantType;
  UserLoadedWithActiveOrderState({this.activeOrder, this.restaurantType});
}

class UserNewAddressSaved extends UserLoadedState {}
