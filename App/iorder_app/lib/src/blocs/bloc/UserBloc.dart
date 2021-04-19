import 'dart:io';

import 'package:ande_app/main.dart';
import 'package:ande_app/src/blocs/events/AuthenticationEvents.dart';
import 'package:ande_app/src/blocs/events/UserEvents.dart';
import 'package:ande_app/src/blocs/states/AuthenticationStates.dart';
import 'package:ande_app/src/blocs/states/UserStates.dart';
import 'package:ande_app/src/data_providers/models/ActiveOrderViewModel.dart';
import 'package:ande_app/src/data_providers/models/CountryModel.dart';
import 'package:ande_app/src/data_providers/models/CustomerAddressViewModel.dart';
import 'package:ande_app/src/data_providers/models/OrderViewModel.dart';
import 'package:ande_app/src/data_providers/models/ResponseModel.dart';
import 'package:ande_app/src/data_providers/models/UserViewModel.dart';
import 'package:ande_app/src/data_providers/models/delivery/CityViewModel.dart';
import 'package:ande_app/src/resources/Constants.dart';
import 'package:ande_app/src/resources/Repository.dart';
import 'package:ande_app/src/resources/UserCart.dart';
import 'package:ande_app/src/ui/screens/RestaurantSplashScreen.dart';
import 'package:ande_app/src/utilities/NetworkUtilities.dart';
import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';

import 'AuthenticationBloc.dart';
class UserBloc extends Bloc<UserEvents, UserStates> {
  BehaviorSubject<bool> languageChangeNotifier = BehaviorSubject<bool>();
  BehaviorSubject<List<RegionViewModel>> countryCities =
      BehaviorSubject<List<RegionViewModel>>();

  AuthenticationBloc authBloc;

  CountryModel userCountry;
  OrderViewModel userActiveOrder;
  UserViewModel currentLoggedInUser = UserViewModel.fromAnonymous();
  User user;

  bool isAnonymous() {
    return user == null || (user.email != null && user.email ==  Constants.userMail);
  }

  UserBloc(AuthenticationBloc bloc) {
    this.authBloc = bloc;
    authBloc.add(AppStart());
    authBloc.listen((state) async {
      if(state is UserAuthenticated)
        add(LoadUserInformation());
    });
  }

  @override
  UserStates get initialState => UserInitialState();

  @override
  Future<void> close() {
    languageChangeNotifier.close();
    countryCities.close();
    return super.close();
  }

  @override
  Stream<UserStates> mapEventToState(UserEvents event) async* {



    bool isConnected = await NetworkUtilities.isConnected();
    if (isConnected == false) {
      yield UserLoadingFailed(event: event, error: Constants.connectionTimeoutException);
      return;
    }

    if (event is MoveToState) {
      yield event.wantedState;
      return;
    }


    if (event is LoadUserInformation) {
      yield* _handleUserInformationLoading(event);
      return;
    } else if (event is SaveUserAddress) {
      yield* _saveAddress(event);
      return;
    } else if (event is LoadUserAddresses) {
      yield* _loadUserAddresses(event);
      return;
    }
  }

  Stream<UserStates> _saveAddress(SaveUserAddress event) async* {
    yield UserLoadingState();
    ResponseViewModel<bool> saveAddressResponse =
      await Repository.addCustomerAddress(address: event.addressToServerModel);
    if (saveAddressResponse.isSuccess) {
      add(LoadUserAddresses());
      return;
    } else {
      yield UserLoadingFailed(
          event: event, error: saveAddressResponse.serverError);
      return;
    }
  }

  Stream<UserStates> _loadUserAddresses(LoadUserAddresses event) async* {
    ResponseViewModel<List<CustomerAddressViewModel>> getUserAddresses =
        await Repository.getCustomerAddresses();
    if (getUserAddresses.isSuccess) {
      currentLoggedInUser.userLocations = getUserAddresses.responseData;
      // add(LoadUserInformation());
      yield UserNewAddressSaved();
      return;
    } else {
      add(LoadUserInformation());
      return;
    }
  }

  void loadUserCountry() async {
    ResponseViewModel<List<RegionViewModel>> citiesList =
        await Repository.getRegionsInCountry(countryId: userCountry ?? appBloc.supportedCountries[0].countryId);

    if (citiesList.isSuccess) {
      countryCities.sink.add(citiesList.responseData);
    } else {
      countryCities.sink.add(List<RegionViewModel>());
    }
  }

  Stream<UserStates> _handleUserInformationLoading(LoadUserInformation event) async* {
    yield UserLoadingState();
    user = FirebaseAuth.instance.currentUser;
    if(user == null){
     ResponseViewModel<User> firebaseLoginResponse = await Repository.loginAnonymously();
     if(firebaseLoginResponse.isSuccess)
       user = firebaseLoginResponse.responseData;
    }

    // get User saved Locations & History List
    ResponseViewModel<List<CustomerAddressViewModel>> userAddressResponse = await Repository.getCustomerAddresses();
    if (userAddressResponse.isSuccess) {
      currentLoggedInUser.userLocations = userAddressResponse.responseData;
    } else if (userAddressResponse.serverError.errorCode == HttpStatus.requestTimeout) {
      this.add(LoadUserInformation());
      return;
    }

    ResponseViewModel<ActiveOrderViewModel> activeOrderResponse = await Repository.getCustomerActiveOrders();
    if (activeOrderResponse.isSuccess) {
      if (activeOrderResponse.responseData.activeDineInOrders.length > 0) {
        /// check for active dine in orders
        for (int i = 0; i < activeOrderResponse.responseData.activeDineInOrders.length; i++) {
          if (activeOrderResponse.responseData.activeDineInOrders[i] != null) {
            userActiveOrder = activeOrderResponse.responseData.activeDineInOrders[i];
            UserCart().updateOrderFromBackEnd(userActiveOrder);
            yield UserLoadedWithActiveOrderState(activeOrder: userActiveOrder, restaurantType: RestaurantLoadingType.DINING);
            return;
          }
        }
      } else if (activeOrderResponse.responseData.activeDeliveryOrders.length > 0){
        /// check for active delivery orders
        for (int i = 0; i < activeOrderResponse.responseData.activeDeliveryOrders.length; i++) {
          if (activeOrderResponse.responseData.activeDeliveryOrders[i] != null) {
            userActiveOrder = activeOrderResponse.responseData.activeDeliveryOrders[i];
            UserCart().updateOrderFromBackEnd(userActiveOrder);
            yield UserLoadedWithActiveOrderState(activeOrder: userActiveOrder, restaurantType: RestaurantLoadingType.DELIVERY);
            return;
          }
        }
      } else {
        userActiveOrder = null;
        yield UserLoadedWithoutActiveOrderState();
        return;
      }

    } else {
      if (activeOrderResponse.serverError.errorCode == HttpStatus.requestTimeout) {
        userActiveOrder = null;
        this.add(LoadUserInformation());
        return;
      }
    }
  }
}
