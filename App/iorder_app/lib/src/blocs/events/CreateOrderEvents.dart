import 'package:ande_app/src/blocs/states/CreateOrderStates.dart';
import 'package:ande_app/src/data_providers/models/OrderItemViewModel.dart';
import 'package:ande_app/src/data_providers/models/OrderViewModel.dart';
import 'package:flutter/material.dart';

abstract class CreateOrderEvents {}

class CreateOrderEvent extends CreateOrderEvents {
  final OrderViewModel orderModel;
  final bool isUpdateOrderRequest ;

  CreateOrderEvent(this.isUpdateOrderRequest, {this.orderModel});
}

class CreateDeliveryOrder extends CreateOrderEvents {
  final OrderViewModel orderModel;
  final String addressId;
  CreateDeliveryOrder({this.orderModel, this.addressId});
}


class RequestWaiter extends CreateOrderEvents{
  final String tableNumber;
  RequestWaiter({this.tableNumber,});
}

class ValidatePromoCode extends CreateOrderEvents {
  final String promoCode, customerAddressId, restaurantId;
  final List<OrderItemViewModel> orderList;
  final OrderType orderType;
  ValidatePromoCode({this.promoCode, this.orderList, this.orderType, this.customerAddressId, this.restaurantId});
}

class MoveToCreateOrderState extends CreateOrderEvents {
  CreateOrderStates state;
  MoveToCreateOrderState({@required CreateOrderStates moveTo}){
    this.state = moveTo;
  }
}