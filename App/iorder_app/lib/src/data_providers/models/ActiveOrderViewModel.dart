import 'package:ande_app/src/data_providers/models/OrderViewModel.dart';

class ActiveOrderViewModel {
  List<OrderViewModel> activeDineInOrders;
  List<OrderViewModel> activeDeliveryOrders;

  ActiveOrderViewModel({this.activeDineInOrders, this.activeDeliveryOrders});

  static ActiveOrderViewModel fromJson(Map<String, dynamic> json) {
    List<OrderViewModel> activeDineInOrders = List();
    List<OrderViewModel> activeDeliveryOrders = List();
    var data = json[ActiveOrderViewModelJsonKeys.ACTIVE_ORDER_DATA];
    if (data != null) {
      var dineInList = data[ActiveOrderViewModelJsonKeys.ACTIVE_ORDER_DINE_IN_ORDERS];
      for (int i = 0; i < dineInList.length; i++) {
        activeDineInOrders.add(OrderViewModel.fromJson(dineInList[i]));
      }
      var deliveryList = data[ActiveOrderViewModelJsonKeys.ACTIVE_ORDER_DELIVERY_ORDERS];
      for (int i = 0; i < deliveryList.length; i++) {
        activeDeliveryOrders.add(OrderViewModel.fromJson(deliveryList[i]));
      }
    }
    return ActiveOrderViewModel(
      activeDineInOrders: activeDineInOrders,
      activeDeliveryOrders: activeDeliveryOrders
    );
  }

  @override
  String toString() => '{ActiveOrderViewModel: {activeDineInOrders: ${activeDineInOrders.toString()}, activeDeliveryOrders: ${activeDeliveryOrders.toString()}}';
}

class ActiveOrderViewModelJsonKeys {
  static const String ACTIVE_ORDER_DATA = 'data';
  static const String ACTIVE_ORDER_DINE_IN_ORDERS = 'dinein_orders';
  static const String ACTIVE_ORDER_DELIVERY_ORDERS = 'delivery_orders';
}