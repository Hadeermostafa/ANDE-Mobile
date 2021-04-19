import 'package:ande_app/src/data_providers/models/ErrorViewModel.dart';
import 'package:ande_app/src/blocs/events/RestaurantMenuEvents.dart';
import 'package:ande_app/src/data_providers/models/RestaurantMenuModel.dart';

abstract class RestaurantMenuStates {}
class RestaurantMenuLoadingState extends RestaurantMenuStates{}
class RestaurantMenuLoadingFailedState extends RestaurantMenuStates{
  final ErrorViewModel error ;
  final RestaurantMenuEvents failedEvent ;
  RestaurantMenuLoadingFailedState({this.error , this.failedEvent});

}
class RestaurantMenuLoaded extends RestaurantMenuStates {
  final RestaurantMenuModel menu;
  RestaurantMenuLoaded({this.menu});
}
