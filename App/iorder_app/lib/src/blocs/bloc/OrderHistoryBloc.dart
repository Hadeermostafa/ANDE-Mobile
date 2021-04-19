import 'package:ande_app/src/data_providers/models/ErrorViewModel.dart';
import 'package:ande_app/src/data_providers/models/OrderViewModel.dart';
import 'package:ande_app/src/data_providers/models/ResponseModel.dart';
import 'package:ande_app/src/resources/Constants.dart';
import 'package:ande_app/src/resources/Repository.dart';
import 'package:ande_app/src/utilities/NetworkUtilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum HistoryType {
  DINE_IN,
  DELIVERY,
  BOOKING,
  PICK_UP
}

const Map<HistoryType, String> historyTypeUrlMap = {
  HistoryType.DINE_IN: 'dinein',
  HistoryType.DELIVERY: 'delivery',
};

abstract class OrderHistoryEvent {}

class GetHistoryOrderDetails extends OrderHistoryEvent {
  final String orderId;
  final HistoryType orderType;

  GetHistoryOrderDetails({@required this.orderId, @required this.orderType});
}

class GetHistoryByType extends OrderHistoryEvent {
  final HistoryType historyType;
  final bool reset;
  GetHistoryByType({@required this.historyType, this.reset = false});
}

abstract class OrderHistoryState {}

class OrderHistoryLoading extends OrderHistoryState {}

class OrderHistorySuccess extends OrderHistoryState {
  final List<OrderViewModel> historyList;
  OrderHistorySuccess({this.historyList});
}

class OrderHistoryFailed extends OrderHistoryState {
  final ErrorViewModel errorViewModel;
  final OrderHistoryEvent failedEvent;

  OrderHistoryFailed({this.errorViewModel, this.failedEvent});
}

class OrderHistoryDetailsSuccess extends OrderHistoryState {
  final OrderViewModel orderViewModel;

  OrderHistoryDetailsSuccess({@required this.orderViewModel});
}

class OrderHistoryBloc
    extends Bloc<OrderHistoryEvent, OrderHistoryState> {

  List<OrderViewModel> orderList = List();
  int pageNumber = 1;
  static const int PAGE_SIZE = 8;
  bool reachedEnd = false;
  HistoryType currentType = HistoryType.DINE_IN;

  @override
  OrderHistoryState get initialState => OrderHistoryLoading();

  @override
  Stream<OrderHistoryState> mapEventToState(
      OrderHistoryEvent event) async* {
    bool isConnected = await NetworkUtilities.isConnected();
    if (isConnected == false) {
      yield OrderHistoryFailed(
          errorViewModel: Constants.connectionTimeoutException,
          failedEvent: event);
      return;
    }
    if (event is GetHistoryOrderDetails) {
      yield OrderHistoryLoading();
      String orderTypeUrl = historyTypeUrlMap[event.orderType];
      ResponseViewModel<OrderViewModel> response =
          await Repository.getOrderById(
              orderId: event.orderId, menuLanguage: Constants.currentAppLocale, orderType: orderTypeUrl);
      if (response.isSuccess) {
        yield OrderHistoryDetailsSuccess(orderViewModel: response.responseData);
        return;
      } else {
        yield OrderHistoryFailed(errorViewModel: response.serverError, failedEvent: event);
        return;
      }
    }

    if (event is GetHistoryByType) {
      if (event.reset) {
        reachedEnd = false;
        pageNumber = 1;
        orderList.clear();
      }
      if (reachedEnd == false) {
        yield OrderHistoryLoading();
        if (currentType != event.historyType) {
          pageNumber = 1;
          orderList.clear();
          currentType = event.historyType;
        }
        String historyTypeUrl = historyTypeUrlMap[event.historyType];
        ResponseViewModel<List<OrderViewModel>> userHistoryResponse =
        await Repository.getHistory(historyTypeUrl: historyTypeUrl, pageNumber: pageNumber.toString(), rowCount: PAGE_SIZE.toString());
        if (userHistoryResponse.isSuccess) {
          pageNumber++;
          if (userHistoryResponse.responseData.length < PAGE_SIZE
               || userHistoryResponse.responseData.length == 0) {
            reachedEnd = true;
          }
          if (event.historyType == HistoryType.DINE_IN) {
            userHistoryResponse.responseData.removeWhere((element) => element.statues != ORDER_STATUES.COMPLETED);
          } else if (event.historyType == HistoryType.DELIVERY) {
            userHistoryResponse.responseData.removeWhere((element) => element.statues != ORDER_STATUES.DELIVERED);
          }
          orderList.addAll(userHistoryResponse.responseData);
          yield OrderHistorySuccess(historyList: orderList);
          return;
        }
        yield OrderHistoryFailed(errorViewModel: userHistoryResponse.serverError, failedEvent: event);
        return;
      } else {
        yield OrderHistorySuccess(historyList: orderList);
        return;
      }
    }
  }
}
