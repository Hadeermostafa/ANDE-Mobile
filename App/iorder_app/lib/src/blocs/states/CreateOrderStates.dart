import 'package:ande_app/src/blocs/events/CreateOrderEvents.dart';
import 'package:ande_app/src/data_providers/models/ErrorViewModel.dart';
import 'package:ande_app/src/data_providers/models/OrderViewModel.dart';
import 'package:ande_app/src/data_providers/models/PromocodeViewModel.dart';
abstract class CreateOrderStates {}

class OrderCreateInitialized extends CreateOrderStates {}

class OrderCreateLoading extends CreateOrderStates {}


class OrderCreateSuccess extends CreateOrderStates {
  final OrderViewModel orderViewModel;
  OrderCreateSuccess({this.orderViewModel});
}

class OrderCreateFailed extends CreateOrderStates {
  final ErrorViewModel error;
  final CreateOrderEvents failedEvent;
  OrderCreateFailed({this.error, this.failedEvent});

}

class WaiterOnItsWay extends OrderCreateFailed{}

class OrderPromoCodeValid extends CreateOrderStates {
  final PromoCodeViewModel promoCodeViewModel;
  OrderPromoCodeValid({this.promoCodeViewModel});
}

class OrderPromoCodeInvalid extends CreateOrderStates {
  final ErrorViewModel errorViewModel;
  OrderPromoCodeInvalid({this.errorViewModel});
}

class RemovePromoCode extends CreateOrderStates {}