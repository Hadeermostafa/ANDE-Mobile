import 'dart:async';
import 'dart:core';

import 'package:ande_app/src/blocs/bloc/OrderHistoryBloc.dart';
import 'package:ande_app/src/data_providers/models/ErrorViewModel.dart';
import 'package:ande_app/src/data_providers/models/NotificationObjectModel.dart';
import 'package:ande_app/src/data_providers/models/OrderViewModel.dart';
import 'package:ande_app/src/data_providers/models/PaymentMethodViewModel.dart';
import 'package:ande_app/src/data_providers/models/PromocodeViewModel.dart';
// import 'package:ande_app/src/data_providers/models/OrderItemViewModel.dart';
// import 'package:ande_app/src/data_providers/models/OrderViewModel.dart';
import 'package:ande_app/src/data_providers/models/ResponseModel.dart';
import 'package:ande_app/src/resources/Constants.dart';
import 'package:ande_app/src/resources/Repository.dart';
import 'package:ande_app/src/resources/UserCart.dart';
import 'package:ande_app/src/utilities/NetworkUtilities.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';

import 'NotificationBloc.dart';

class PaymentBloc extends Bloc<PaymentEvents, PaymentStates> {
  NotificationBloc bloc;

  OrderViewModel userOrder;
  PaymentBloc(
      NotificationBloc _notificationBloc, OrderViewModel userInitialOrder) {

    if (userInitialOrder != null) userOrder = userInitialOrder;
    if (_notificationBloc != null && bloc == null) {
      bloc = _notificationBloc;
      bloc.listen((newState) {
          if (newState is NewNotificationState) {
            NotificationObjectModel serverNotification = newState.notification;
            bloc.add(NotificationHandled());


            // in case of delivery order check if the order is confirmed by the restaurant
            if (serverNotification.notificationReason.toLowerCase() == NotificationKeys.ORDER_CONFIRMED.toLowerCase()) {
              userOrder.statues = ORDER_STATUES.ACCEPTED;
              add(MoveToStateEvent(destination: OrderDataLoaded(orderViewModel: userOrder)));
              return;
            }
            // check if the order is closed and redirect the user to scan QR again
            else if (serverNotification.notificationReason == NotificationKeys.ORDER_CLOSED) {
              userOrder.statues = ORDER_STATUES.COMPLETED;
              add(MoveToStateEvent(destination: OrderClosedSuccessfully()));
              return;
            }
            // check if the order is heavily changed and needs update
            if (serverNotification.shouldReload) {
              try{
                this.add(ReloadOrderItems());
              } catch(exception){
                debugPrint("Payment Bloc Exception $exception");
              }
              return;
            }
            else {
              // the key for the notification is order update with should reload false that means the update is in the body
              // extract it and update the order
          if (serverNotification.notificationReason == NotificationKeys.NOTIFICATION_ORDER_UPDATE ) {
            if (serverNotification.notificationData['rel_order_item_id'] != null) {
              NotificationObjectModel.updateCartFromNotificationItems(serverNotification.notificationData);
              userOrder.otherPeopleOrderItems = UserCart().othersItemsList;
              userOrder.orderItems = UserCart().getConfirmedItems;
              add(MoveToStateEvent(destination: OrderDataLoaded(orderViewModel: userOrder)));
              return;
            }
            userOrder.statues = OrderViewModel.getOrderStatues(serverNotification.notificationData['status']);
            add(MoveToStateEvent(destination: OrderDataLoaded(orderViewModel: userOrder)));
            return;
          }
            }
          }
        },
      );
    }
  }

  @override
  Future<void> close() {
    return super.close();
  }

  @override
  PaymentStates get initialState => ScreenInitialized();

  @override
  Stream<PaymentStates> mapEventToState(PaymentEvents event) async* {
    try {
      bool isConnected = await NetworkUtilities.isConnected();
      if (isConnected == false) {
        yield PaymentFailed(
            error: Constants.connectionTimeoutException , event: event);
        return;
      }
      if (event is MoveToStateEvent) {
        yield event.destination;
        return;
      } // Mainly notification based actions , or direct movement from state to another
      else if (event is ReloadOrderItems && // without Logic as external order closing
          state is OrderItemsLoadingState == false) {
        yield OrderItemsLoadingState();
        OrderViewModel userOrder = await reloadOrder();
        if (userOrder.statues == ORDER_STATUES.COMPLETED) {
          yield OrderClosedSuccessfully();
          return;
        }
        yield OrderDataLoaded(orderViewModel: userOrder);
        return;
      } // Backend update Loading Indicator will appear
      else if (event is ReloadDeliveryOrderItems && // without Logic as external order closing
          state is OrderItemsLoadingState == false) {
        yield OrderItemsLoadingState();
        OrderViewModel userOrder = await reloadDeliveryOrder();
        if (userOrder.statues == ORDER_STATUES.COMPLETED || userOrder.statues == ORDER_STATUES.DELIVERED) {
          yield OrderClosedSuccessfully();
          return;
        }
        yield OrderDataLoaded(orderViewModel: userOrder);
        return;
      }

      else if (event is UserReloadedOrderItems && state is OrderItemsLoadingState == false) {
        yield PaymentLoading();
        OrderViewModel userOrder = await reloadOrder();
        yield OrderDataLoaded(orderViewModel: userOrder);
        return;
      }
      else if (event is RequestWaiter) {
        yield* _handleCallingWaiter(event);
        return ;
      }
      else if(event is RequestVisaPayment){
        yield* _handleOnlinePayment(event);
        return ;
      }
      else if (event is RequestCheckEvent) {
        yield* _handleRequestingCheque(event);
        return ;
      } else if (event is CancelOrder) {
        yield* _handleOrderCanceling(event);
        return;
      } else if (event is RequestPaymentMethods) {
        yield* _handleRequestPaymentMethods(event);
        return;
      } else if (event is ApplyPromoCodeToOrder) {
        yield* _handleApplyPromoCodeToOrder(event);
        return;
      }
    } catch (exception) {
      debugPrint(exception);
      ErrorViewModel error;
      if ((exception is ErrorViewModel) == false) {

      } else
        error = exception;
      yield PaymentFailed(error: error , event: event);
      return;
    }
  }

  Future<OrderViewModel> reloadOrder() async {
    ResponseViewModel<OrderViewModel> getOrder = await Repository.getOrderById(orderId: userOrder.orderID, menuLanguage: Constants.currentRestaurantLocale, orderType: historyTypeUrlMap[HistoryType.DINE_IN]);

    if (getOrder.isSuccess) {
      UserCart().updateOrderFromBackEnd(getOrder.responseData);
      userOrder = getOrder.responseData;
    }
    return userOrder;
  }

  Future<OrderViewModel> reloadDeliveryOrder() async {
    ResponseViewModel<OrderViewModel> getOrder = await Repository.getOrderById(orderId: userOrder.orderID, menuLanguage: Constants.currentRestaurantLocale, orderType: historyTypeUrlMap[HistoryType.DELIVERY]);

    if (getOrder.isSuccess) {
      UserCart().updateOrderFromBackEnd(getOrder.responseData);
      userOrder = getOrder.responseData;
    }
    return userOrder;
  }

  Stream<PaymentStates> _handleRequestPaymentMethods(RequestPaymentMethods event) async* {
    yield PaymentLoading();
    ResponseViewModel<List<PaymentMethodViewModel>> response =
      await Repository.getRestaurantPaymentMethods(restaurantId: event.restaurantId);
    if (response.isSuccess) {
      if (response.responseData == null || response.responseData.isEmpty) {
        this.add(RequestCheckEvent(paymentOrderModel: OrderViewModel(orderID: UserCart().orderID)));
        return;
      }
      yield PaymentMethodsSuccess(paymentMethods: response.responseData);
      return;
    }
    yield PaymentMethodsFailed(errorViewModel: response.serverError, failedEvent: event);
    return;
  }


  Stream<PaymentStates> _handleOrderCanceling(CancelOrder event) async* {
    yield PaymentLoading();
    ResponseViewModel _cancelOrder =
        await Repository.cancelOrder(order: event.order);
    if (_cancelOrder.isSuccess) {
      yield OrderClosedSuccessfully();
      return;
    } else {
      yield PaymentFailed(error: _cancelOrder.serverError , event: event);
      return;
    }
  }
  Stream<PaymentStates> _handleCallingWaiter(RequestWaiter event) async*{

    yield PaymentLoading();
    ResponseViewModel<bool> callWaiterResponse = await Repository.callWaiter(
        tableId: event.tableNumber, orderId: event.orderId);

    if(callWaiterResponse.isSuccess){
      yield WaiterOnTheWayState();
      return;
    } else {
      yield PaymentFailed(error: callWaiterResponse.serverError , event: event);
      return;
    }
  }

  Stream<PaymentStates> _handleOnlinePayment(RequestVisaPayment event) async* {
    yield PaymentLoading();
    OrderViewModel orderViewModel = event.paymentOrderModel;
    ResponseViewModel<String> requestPaymentLinkResponse = await Repository.requestPaymentLink(orderViewModel.orderID, orderViewModel.calculateOrderGross().toString());

    if (requestPaymentLinkResponse.isSuccess) {
      yield PaymentWithVisaReady(paymentLink: requestPaymentLinkResponse.responseData);
      return;
    } else {
      yield PaymentFailed(error: requestPaymentLinkResponse.serverError , event: event);
      return;
    }
  }


  Stream<PaymentStates> _handleRequestingCheque(RequestCheckEvent event) async* {

    yield PaymentLoading();
    OrderViewModel orderViewModel = event.paymentOrderModel;
    ResponseViewModel<bool> chequeRequestResponse = await Repository
        .requestCheque(orderModel: orderViewModel);
    if (chequeRequestResponse.isSuccess) {
      yield PaymentSuccess();
      return;
    } else {
      yield PaymentFailed(error: chequeRequestResponse.serverError , event: event);
      return;
    }


  }

  Stream<PaymentStates> _handleApplyPromoCodeToOrder(ApplyPromoCodeToOrder event) async* {
    yield PaymentLoading();
    OrderViewModel order = OrderViewModel.clone(userOrder);
    order.promoCodeViewModel = PromoCodeViewModel(promoCodeTitle: event.promoCode);
    ResponseViewModel<PromoCodeViewModel> responseViewModel = await
        Repository.addPromoCodeToOrder(orderViewModel: order, orderType: Constants.orderTypeUrl[event.orderType]);
    if (responseViewModel.isSuccess) {
      yield PromoCodeSuccess(promoCodeViewModel: responseViewModel.responseData);
      return;
    }
    yield PromoCodeFailure(errorViewModel: responseViewModel.serverError, failedEvent: event);
    return;
  }

}

//--------------- States -----------------------------------
abstract class PaymentStates {}

class PaymentSuccess extends PaymentStates {}

class PaymentFailed extends PaymentStates {
  final ErrorViewModel error;
  final PaymentEvents event ;
  PaymentFailed({this.error , this.event});
}

class OrderItemsLoadingState extends PaymentStates {}

class OrderClosedState extends PaymentStates {
  final OrderViewModel orderModel;
  OrderClosedState({this.orderModel});
}


class PaymentLoading extends PaymentStates {}

class ScreenInitialized extends PaymentStates {}

class OrderDataLoaded extends PaymentStates {
  final OrderViewModel orderViewModel;
  OrderDataLoaded({this.orderViewModel});
}

class OrderClosedSuccessfully extends PaymentStates {}

class OrderUpdatedFromNotificationState extends PaymentStates {}

class WaiterOnTheWayState extends PaymentStates {}

class PaymentWithVisaReady extends PaymentStates{
  final String paymentLink ;
  PaymentWithVisaReady({this.paymentLink});
}

class PaymentMethodsSuccess extends PaymentStates {
  final List<PaymentMethodViewModel> paymentMethods;

  PaymentMethodsSuccess({this.paymentMethods});
}

class PaymentMethodsFailed extends PaymentStates {
  final ErrorViewModel errorViewModel;
  final PaymentEvents failedEvent;

  PaymentMethodsFailed({this.errorViewModel, this.failedEvent});
}

class PromoCodeSuccess extends PaymentStates {
  final PromoCodeViewModel promoCodeViewModel;
  PromoCodeSuccess({this.promoCodeViewModel});
}

class PromoCodeFailure extends PaymentStates {
  final ErrorViewModel errorViewModel;
  final PaymentEvents failedEvent;
  PromoCodeFailure({this.errorViewModel, this.failedEvent});
}


//----------------------- Events ----------------------------

abstract class PaymentEvents {}

class RequestCheckEvent extends PaymentEvents {
  final OrderViewModel paymentOrderModel;
  RequestCheckEvent({this.paymentOrderModel});
}

class RequestWaiter extends PaymentEvents {
  final String tableNumber;
  final String restaurantId;
  final String orderId;
  RequestWaiter({this.tableNumber, this.restaurantId, this.orderId});
}

class UserReloadedOrderItems extends PaymentEvents {}

class ShiftManagerClosedOrder extends PaymentEvents {}

class NotificationReceived extends PaymentEvents {
  final OrderViewModel notificationData;
  NotificationReceived({this.notificationData});
}

class ReloadOrderItems extends PaymentEvents {}

class OrderClosedExternally extends PaymentEvents {}

class CancelOrder extends PaymentEvents {
  final OrderViewModel order;
  CancelOrder({this.order});
}

class MoveToStateEvent extends PaymentEvents {
  final PaymentStates destination;
  MoveToStateEvent({this.destination});
}

class RequestVisaPayment extends PaymentEvents {
  final OrderViewModel paymentOrderModel;
  RequestVisaPayment({this.paymentOrderModel});
}

class RequestPaymentMethods extends PaymentEvents {
  final String restaurantId;
  RequestPaymentMethods({this.restaurantId});
}

class ReloadDeliveryOrderItems extends PaymentEvents {}

class ApplyPromoCodeToOrder extends PaymentEvents {
  final String promoCode;
  final OrderType orderType;
  ApplyPromoCodeToOrder({this.promoCode, this.orderType});
}
