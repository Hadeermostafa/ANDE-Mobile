import 'package:ande_app/src/blocs/states/RestaurantListingStates.dart';
import 'package:ande_app/src/data_providers/models/ResponseModel.dart';
import 'package:ande_app/src/data_providers/models/RestaurantListViewModel.dart';
import 'package:ande_app/src/data_providers/models/product/ProductCategoryViewModel.dart';
import 'package:ande_app/src/resources/Constants.dart';
import 'package:ande_app/src/resources/Repository.dart';
import 'package:ande_app/src/utilities/NetworkUtilities.dart';
import 'package:bloc/bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../events/RestaurantListingEvents.dart';

class RestaurantListBloc
    extends Bloc<RestaurantsListingEvents, RestaurantsListingStates> {
  BehaviorSubject<List<RestaurantListViewModel>> _restaurantsController =
      BehaviorSubject<List<RestaurantListViewModel>>();


  String userCountryId ;
  int pageNumber = 1;

  RestaurantListBloc(String countryId){
    this.userCountryId = countryId;
  }





  List<RestaurantListViewModel> restaurants = List();
  bool reachedEnd = false;
  static const int PAGE_SIZE = 8;

  @override
  void dispose() {
    _restaurantsController.close();
    super.close();
  }

  Stream<List<RestaurantListViewModel>> get restaurantsStream =>
      _restaurantsController.stream;

  getFilteredList(String filterKey, List<RestaurantListViewModel> searchList) {
    List<RestaurantListViewModel> filterList = [];
    filterKey = filterKey.toLowerCase();

    for (RestaurantListViewModel model in searchList) {
      if (model.restaurantName.toLowerCase().contains(filterKey)) {
        if (filterList.contains(model) == false) filterList.add(model);
        continue;
      }
      else {
        for (ProductCategoryViewModel categoryModel
            in model.restaurantCuisines) {
          if (categoryModel.categoryName.toLowerCase().contains(filterKey)) {
            if (filterList.contains(model) == false) filterList.add(model);
            continue;
          }
        }
      }
    }

    return filterList;
  }

  @override
  RestaurantsListingStates get initialState => RestaurantsUninitialized();

  @override
  Stream<RestaurantsListingStates> mapEventToState(
      RestaurantsListingEvents event) async* {
    bool isConnected = await NetworkUtilities.isConnected();
    if (isConnected == false) {
      yield RestaurantsLoadingFailed(error: Constants.connectionTimeoutException , event: event);
      return;
    }

    if (event is LoadRestaurants) {
      yield* _handleRestaurantsLoading(event);
    }

    if (event is SearchRestaurant && state is RestaurantsLoaded) {
      _restaurantsController.sink
          .add(getFilteredList(event.queryText, restaurants));
    }
  }

  Stream<RestaurantsListingStates> _handleRestaurantsLoading(LoadRestaurants event) async*{
    if (reachedEnd == false) {
      yield RestaurantsLoading();
      ResponseViewModel<List<RestaurantListViewModel>> response = await Repository.getDeliveryRestaurants(
          countryId: userCountryId, pageNumber: pageNumber.toString(), rowCount: PAGE_SIZE.toString()
      );
      if (response.isSuccess) {
        if (response.responseData.length < PAGE_SIZE ||
            response.responseData.length == 0) reachedEnd = true;
        pageNumber++;
        restaurants.addAll(response.responseData);
        _restaurantsController.sink.add(restaurants);
        yield RestaurantsLoaded(restaurantsData: restaurants);
        return;
      }
      yield RestaurantsLoadingFailed(error: response.serverError, event: event);
      return;
    }  else {
      yield RestaurantsLoaded(restaurantsData: restaurants);
      return;
    }
  }
}
