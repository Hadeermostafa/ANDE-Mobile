import 'dart:io';

import 'package:ande_app/main.dart';
import 'package:ande_app/src/blocs/bloc/OrderHistoryBloc.dart';
import 'package:ande_app/src/data_providers/models/OrderViewModel.dart';
import 'package:ande_app/src/resources/Constants.dart';
import 'package:ande_app/src/ui/list_tiles/HistoryOrderTile.dart';
import 'package:ande_app/src/ui/screens/SingleOrderHistoryDetails.dart';
import 'package:ande_app/src/ui/widgets/AndeAppbar.dart';
import 'package:ande_app/src/ui/widgets/HelperWidgets.dart';
import 'package:ande_app/src/ui/widgets/ListViewAnimatorWidget.dart';
import 'package:ande_app/src/utilities/LocalKeys.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class OrdersHistoryScreen extends StatefulWidget {
  @override
  _OrdersHistoryScreenState createState() => _OrdersHistoryScreenState();
}

class _OrdersHistoryScreenState extends State<OrdersHistoryScreen>
    with TickerProviderStateMixin{


  List<OrderViewModel> userOrders = List<OrderViewModel>();
  TabController tabController;
  int currentIndex = 0;
  OrderHistoryBloc historyBloc;
  HistoryType _currentHistoryType = HistoryType.DINE_IN;
  ScrollController _scrollController = ScrollController();
  GlobalKey _listViewFormState = GlobalKey();

  void onScrollListener() {
    if (_scrollController.position.maxScrollExtent - _scrollController.position.pixels < 50) {
      if ((historyBloc.state is OrderHistoryLoading) == false && historyBloc.reachedEnd == false) {
        historyBloc.add(GetHistoryByType(historyType: _currentHistoryType));
      }
    }
  }


  @override
  void initState() {
    super.initState();
    tabController = TabController(initialIndex: currentIndex,
        length: Constants.orderTypes.length,
        vsync: this);
    historyBloc = OrderHistoryBloc();
    historyBloc.add(GetHistoryByType(historyType: _currentHistoryType));
    _scrollController.addListener(onScrollListener);
  }

  Future<void> _onRefresh() async {
    _resolveNeedRedispatch(GetHistoryByType(historyType: _currentHistoryType, reset: true));
    setState(() {
      userOrders.clear();
    });
    return null;
  }

  @override
  void dispose() {
    historyBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    return Scaffold(
      appBar: AndeAppbar(
        hasBackButton: true,
        screenTitle: (LocalKeys.HISTORY).tr(),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding:
            const EdgeInsets.all(8.0),
            child: SizedBox(
              height: 35,
              child: TabBar(
                indicatorColor: Color(0xFFa40000),
                isScrollable: true,
                labelColor: Colors.black,
                unselectedLabelColor:
                Constants.kTextColor,
                tabs: getOrderTypes(),
                controller: tabController,
                onTap: (selectedIndex) {
                  setState(() {});
                  switch (selectedIndex) {
                    case 0:
                      historyBloc.add(GetHistoryByType(historyType: HistoryType.DINE_IN, reset: true));
                      _currentHistoryType = HistoryType.DINE_IN;
                      userOrders.clear();
                      return;
                    case 1:
                      historyBloc.add(GetHistoryByType(historyType: HistoryType.DELIVERY, reset: true));
                      _currentHistoryType = HistoryType.DELIVERY;
                      userOrders.clear();
                      return;
                  }
                },
                indicatorWeight: 2,
                indicatorSize: TabBarIndicatorSize.tab,
              ),
            ),
          ),
          Expanded(
            child: BlocConsumer(
              bloc: historyBloc,
              listener: (context, state) async {
                if (state is OrderHistoryFailed) {
                  if (state.errorViewModel.errorCode == HttpStatus.requestTimeout) {
                    HelperWidget.showNetworkErrorDialog(context);
                    await Future.delayed(Duration(seconds: 2), () {});
                    HelperWidget.removeNetworkErrorDialog(context);
                    return;
                  }  else if (state.errorViewModel.errorCode == HttpStatus.serviceUnavailable) {
                    HelperWidget.showToast(message: (LocalKeys.SERVER_UNREACHABLE).tr(), isError: true);
                  }
                  else {
                    HelperWidget.showToast(message: state.errorViewModel.errorMessage ?? '' , isError: true);
                  }
                }
              },
              builder: (context, state) {
                if (state is OrderHistorySuccess){
                  userOrders = state.historyList;
                }
                return ModalProgressHUD(
                  opacity: 0.0,
                  inAsyncCall: state is OrderHistoryLoading,
                  progressIndicator: loadingFlare,
                  child: RefreshIndicator(
                    onRefresh: _onRefresh,
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      physics: AlwaysScrollableScrollPhysics(),
                      child: state is OrderHistoryFailed ?
                      Container(
                         height: mediaQuery.size.height - (mediaQuery.padding.top + kToolbarHeight + 35),
                          child: Center(child: Text(tr(LocalKeys.PLEASE_PULL_TO_REFRESH)),))
                          :
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: ListViewAnimatorWidget(
                          delay: 0,
                          listKey: _listViewFormState,
                          isScrollEnabled: false,
                          placeHolder: Visibility(
                              visible: state is OrderHistorySuccess,
                              replacement: Container(height: 0.0, width: 0.0,),
                              child: Text((LocalKeys.NO_HISTORY).tr())),
                          listChildrenWidgets: userOrders.map((element) =>
                              HistoryOrderTile(orderViewModel: element, onPressed: (){
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => BlocProvider.value(
                                      value: historyBloc,
                                      child: SingleOrderHistoryDetails(
                                        orderViewModel: element,
                                        orderType: _currentHistoryType,
                                      ),
                                    ),
                                  ),
                                );
                              },)).toList(),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> getOrderTypes() {
    return Constants.orderTypes.map((String tabName) =>
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            tr(tabName),
            textScaleFactor: 1,
            style: TextStyle(
                fontSize: 14, fontFamily: Constants.FONT_MONTSERRAT),
          ),
        )).toList();
  }

  void _resolveNeedRedispatch(OrderHistoryEvent event) {
    historyBloc.add(event);
    return;
  }

}
