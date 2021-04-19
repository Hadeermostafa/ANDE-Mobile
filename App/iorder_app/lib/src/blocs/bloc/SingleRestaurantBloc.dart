import 'package:ande_app/src/data_providers/models/ResponseModel.dart';
import 'package:ande_app/src/data_providers/models/RestaurantViewModel.dart';
import 'package:ande_app/src/data_providers/models/product/ProductListViewModel.dart';
import 'package:ande_app/src/resources/Constants.dart';
import 'package:ande_app/src/resources/Repository.dart';
import 'package:ande_app/src/resources/UserCart.dart';
import 'package:ande_app/src/ui/screens/RestaurantSplashScreen.dart';
import 'package:ande_app/src/utilities/NetworkUtilities.dart';
import 'package:bloc/bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../events/SingleRestaurantEvents.dart';
import '../states/SingleRestaurantStates.dart';

class SingleRestaurantBloc
    extends Bloc<SingleRestaurantEvents, SingleRestaurantStates> {
  RestaurantViewModel restaurantModel;

  @override
  SingleRestaurantStates get initialState => restaurantModel == null ? RestaurantInformationLoading() : RestaurantInformationLoaded(restaurantViewModel: restaurantModel);

  SingleRestaurantBloc() {
    updateUI();
  }

  UserCart _mUserCart = UserCart();
  BehaviorSubject<int> _cartCount = BehaviorSubject<int>();
  BehaviorSubject<double> _totalPrice = BehaviorSubject<double>();

  BehaviorSubject<List<ProductListViewModel>> _visibleItems =
      BehaviorSubject<List<ProductListViewModel>>();

  Stream<int> get cartItemsCountStream => _cartCount.stream;

  Stream<double> get cartTotalPriceStream => _totalPrice.stream;

  Stream<List<ProductListViewModel>> get visibleItemsStream => _visibleItems.stream;

  int get getCartCount => _cartCount.value;

  @override
  Stream<SingleRestaurantStates> mapEventToState(SingleRestaurantEvents event) async* {

    bool isConnected = await NetworkUtilities.isConnected();
    if (isConnected == false) {
      yield RestaurantInformationLoadingError(
        event: event,
        error: Constants.connectionTimeoutException,
      );
      return;
    }
    yield RestaurantInformationLoading();

    if (event is LoadRestaurantDetails && event.restaurantId != null) {
      yield* _handleMainRestaurantInformation(event);

      return ;
    }
  }

  @override
  void dispose() {
    _visibleItems.close();
    _cartCount.close();
    _totalPrice.close();

    super.close();
  }

  void updateUI() {
    double totalPrices = 0.0;

    if(_mUserCart.getConfirmedItems != null){
      _mUserCart.getConfirmedItems.forEach((model) {
        totalPrices += model.mealSize.price;
        if (model.userSelectedExtras != null) {
          model.userSelectedExtras.forEach((element) {
            if (element != null) {
              totalPrices += element.price;
            }
          });
        }
      });
    }


    if(_mUserCart.getNonConfirmedItems != null) {
      _mUserCart.getNonConfirmedItems.forEach((model) {
        if (model.mealSize != null) totalPrices += model.mealSize.price;
        if (model.userSelectedExtras != null) {
          model.userSelectedExtras.forEach((element) {
            if (element != null) {
              totalPrices += element.price;
            }
          });
        }
      });
    }

    _totalPrice.sink.add(totalPrices);
    _cartCount.sink.add(_mUserCart.nonConfirmedItemsList.length);
  }



  Stream<SingleRestaurantStates> _handleMainRestaurantInformation(LoadRestaurantDetails event) async*{

    ResponseViewModel serverResponse;

    // Load Restaurant Information but as we have to separate the dine-in and delivery restaurant Information
    // ww check the type of the request Load type
    if (event.as == null || event.as == RestaurantLoadingType.DINING) {
      serverResponse = await Repository.getRestaurantInformation(event.restaurantId,);
    }
    else {
      serverResponse = await Repository.getRestaurantInformation(event.restaurantId,);
    }

    if (serverResponse.isSuccess) {
      restaurantModel = serverResponse.responseData;
      yield RestaurantInformationLoaded(restaurantViewModel: serverResponse.responseData);
        updateUI();
    }
    else {
      yield RestaurantInformationLoadingError(error: serverResponse.serverError , event: event);
    }
  }

}
