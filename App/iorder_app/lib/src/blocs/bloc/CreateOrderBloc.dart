import 'package:ande_app/src/blocs/events/CreateOrderEvents.dart';
import 'package:ande_app/src/blocs/states/CreateOrderStates.dart';
import 'package:ande_app/src/data_providers/models/OrderViewModel.dart';
import 'package:ande_app/src/data_providers/models/PromocodeViewModel.dart';
import 'package:ande_app/src/data_providers/models/ResponseModel.dart';
import 'package:ande_app/src/resources/Constants.dart';
import 'package:ande_app/src/resources/Repository.dart';
import 'package:ande_app/src/resources/UserCart.dart';
import 'package:ande_app/src/utilities/NetworkUtilities.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
class CreateOrderBloc extends Bloc<CreateOrderEvents, CreateOrderStates> {
  @override
  CreateOrderStates get initialState => OrderCreateInitialized();

  @override
  Stream<CreateOrderStates> mapEventToState(CreateOrderEvents event) async* {

    yield OrderCreateLoading();
    bool isConnected = await NetworkUtilities.isConnected();

    if (!isConnected) {
      yield OrderCreateFailed(error: Constants.connectionTimeoutException , failedEvent: event);
      return;
    }

    if (event is CreateOrderEvent) {
      yield* _handleOrderCreationEvent(event);
      return;
    }

    if (event is CreateDeliveryOrder) {
      yield* _handleDeliveryOrderCreation(event);
      return;
    }

    if (event is ValidatePromoCode) {
      yield* _handlePromoCodeValidation(event);
      return;
    }

    if (event is MoveToCreateOrderState) {
      yield event.state;
      return;
    }

    // if(event is RequestWaiter){
    //   yield* _handleWaiterRequest(event);
    //   return;
    // }
  }

  Stream<CreateOrderStates> _handleOrderCreationEvent(
      CreateOrderEvent event) async* {
    yield OrderCreateLoading();
    if (event.isUpdateOrderRequest) {
      ResponseViewModel<OrderViewModel> response = await Repository.updateOrder(orderViewModel: event.orderModel);
      if (response.isSuccess) {
        OrderViewModel orderViewModel = response.responseData;

        UserCart().updateOrderFromBackEnd(orderViewModel);
        yield OrderCreateSuccess(orderViewModel: orderViewModel);
        return ;
      }
      else {
        yield OrderCreateFailed(failedEvent: event, error: response.serverError);
        return;
      }
    }
    ResponseViewModel<OrderViewModel> orderViewModelResponse =
        await Repository.createOrder(event.orderModel);
    if (orderViewModelResponse.isSuccess &&
        orderViewModelResponse.responseData != null) {
      OrderViewModel orderViewModel = orderViewModelResponse.responseData;

      UserCart().updateOrderFromBackEnd(orderViewModel);
      yield OrderCreateSuccess(orderViewModel: orderViewModel);
      return ;
    } else
      yield OrderCreateFailed(
          failedEvent: event, error: orderViewModelResponse.serverError);
    return ;
  }

  Stream<CreateOrderStates> _handleDeliveryOrderCreation(
      CreateDeliveryOrder event) async* {
    yield OrderCreateLoading();
    ResponseViewModel<OrderViewModel> orderViewModelResponse =
        await Repository.createDeliveryOrder(event.orderModel, event.addressId);

    if (orderViewModelResponse.isSuccess && orderViewModelResponse.responseData != null) {
      OrderViewModel orderViewModel = orderViewModelResponse.responseData;
      UserCart().updateOrderFromBackEnd(orderViewModel);
      yield OrderCreateSuccess(orderViewModel: orderViewModel);
      return ;
    } else
      yield OrderCreateFailed(
          failedEvent: event, error: orderViewModelResponse.serverError);
    return ;
  }

  Stream<CreateOrderStates> _handleWaiterRequest(RequestWaiter event) async*{

    ResponseViewModel response = await Repository.callWaiter(tableId: event.tableNumber);
    if (response.isSuccess) {
      yield WaiterOnItsWay();
      return;
    }  else {
      yield WaiterOnItsWay();
      return;
    }
  }

  Stream<CreateOrderStates> _handlePromoCodeValidation(ValidatePromoCode event) async* {
    yield OrderCreateLoading();
    double subtotal = .0;
    for (int i = 0; i < event.orderList.length; i++) {
      subtotal += event.orderList[i].calculateItemPrice();
    }
    ResponseViewModel<PromoCodeViewModel> response =
    await Repository.validatePromoCode(
        orderType: Constants.orderTypeUrl[event.orderType], promoCode: event.promoCode,
        restaurantId: event.restaurantId, orderSubTotal: subtotal, customerAddressId: event.customerAddressId);
    if (response.isSuccess) {
      yield OrderPromoCodeValid(promoCodeViewModel: response.responseData);
      return;
    }
    yield OrderPromoCodeInvalid(errorViewModel: response.serverError);
    return;
  }
}
