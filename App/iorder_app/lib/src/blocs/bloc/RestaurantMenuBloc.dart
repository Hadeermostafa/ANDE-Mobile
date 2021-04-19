import 'package:ande_app/src/blocs/states/SingleRestaurantStates.dart';
import 'package:ande_app/src/data_providers/models/ResponseModel.dart';
import 'package:ande_app/src/data_providers/models/RestaurantMenuModel.dart';
import 'package:ande_app/src/resources/Constants.dart';
import 'package:ande_app/src/resources/Repository.dart';
import 'package:ande_app/src/utilities/NetworkUtilities.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ande_app/src/blocs/events/RestaurantMenuEvents.dart';
import 'package:ande_app/src/blocs/states/RestaurantMenuStates.dart';


class RestaurantMenuBloc extends Bloc<RestaurantMenuEvents, RestaurantMenuStates>{
  @override
  RestaurantMenuStates get initialState =>  RestaurantMenuLoadingState();
  @override
  Stream<RestaurantMenuStates> mapEventToState(RestaurantMenuEvents event) async*{
    bool isConnected = await NetworkUtilities.isConnected();
    if (isConnected == false) {
      yield RestaurantMenuLoadingFailedState(
        failedEvent: event,
        error: Constants.connectionTimeoutException,
      );
      return;
    }
    else if(event is LoadRestaurantMenu){
      yield* _handleMenuLoading(event);
    }
  }

  Stream<RestaurantMenuStates>  _handleMenuLoading(LoadRestaurantMenu event) async* {
    yield RestaurantMenuLoadingState();
    ResponseViewModel<RestaurantMenuModel> restaurantMenuResponse = await Repository.getRestaurantMenu(event.restaurantId, event.language);
    if(restaurantMenuResponse.isSuccess){
      yield RestaurantMenuLoaded(menu: restaurantMenuResponse.responseData);
      return;
    } else {
      yield RestaurantMenuLoadingFailedState(error: restaurantMenuResponse.serverError , failedEvent: event);
      return;
    }
  }



}