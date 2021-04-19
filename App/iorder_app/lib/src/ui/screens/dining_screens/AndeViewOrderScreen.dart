import 'package:ande_app/src/data_providers/models/OrderViewModel.dart';
import 'package:ande_app/src/ui/screens/RestaurantSplashScreen.dart';
import 'package:ande_app/src/ui/widgets/AndeAppbar.dart';
import 'package:ande_app/src/ui/widgets/HelperWidgets.dart';
import 'package:ande_app/src/utilities/LocalKeys.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import '../../../../main.dart';
import '../../../blocs/bloc/PaymentBloc.dart';
import '../../../blocs/bloc/SingleRestaurantBloc.dart';
import '../../../resources/UserCart.dart';
import '../../list_tiles/ViewOderItemTile.dart';
import '../SingleRestaurantMenuScreen.dart';

class AndeViewOrderScreen extends StatefulWidget {
  final bool comingFromActive;
  AndeViewOrderScreen({this.comingFromActive});
  @override
  _AndeViewOrderScreenState createState() => _AndeViewOrderScreenState();
}

class _AndeViewOrderScreenState extends State<AndeViewOrderScreen>
    with WidgetsBindingObserver {
  OrderViewModel _userOrderModel;
  double screenHeight = 0, voucherValue = 0;
  var _scaffoldKey;
  PaymentBloc paymentBloc;

  Future<void> _onRefresh() async {
    paymentBloc.add(UserReloadedOrderItems());
    await Future.delayed(Duration(seconds: 3));
    return null;
  }


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _scaffoldKey = GlobalKey<ScaffoldState>();
    paymentBloc = BlocProvider.of<PaymentBloc>(context);
    _userOrderModel = paymentBloc.userOrder;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: true,
      top: false,
      child: Scaffold(
        backgroundColor: Color(0xfffcfcfc),
        key: _scaffoldKey,
        appBar: AndeAppbar(
          hasBackButton: true,
          screenTitle: '${(LocalKeys.ORDER_SCREEN_TITLE).tr()}',
          actions: <Widget>[
            IconButton(key: Key('add'),
              icon: Icon(
                Icons.add,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return BlocProvider.value(
                        value: SingleRestaurantBloc(),
                        child: SingleRestaurantMenuScreen(
                          restaurantType: UserCart().isDeliveryOrder
                              ? RestaurantLoadingType.DELIVERY
                              : RestaurantLoadingType.DINING,
                          restaurantID: _userOrderModel.restaurantViewModel
                              .restaurantListViewModel.restaurantId
                              .toString(),
                          restaurantItemViewModel: null,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _onRefresh,
          child: getScreenBody(),
        ),
      ),
    );
  }
  getScreenBody() {


    return BlocBuilder(
      bloc: paymentBloc,
      builder: (context, state) {
        if (state is OrderDataLoaded) {
          _userOrderModel = state.orderViewModel;
        }
        return ModalProgressHUD(
          progressIndicator: loadingFlare,
          inAsyncCall: (state is OrderItemsLoadingState),
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  HelperWidget.verticalSpacer(heightVal: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          '${(LocalKeys.YOUR_ITEMS_LABEL).tr()}',
                          textAlign: TextAlign.start,
                          textScaleFactor: 1,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ).tr(),
                        Text(
                          '${(LocalKeys.ORIGINAL_PRICE).tr()} (${getPriceWithLabel(getYourTotal())})',
                          textScaleFactor: 1,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  HelperWidget.verticalSpacer(heightVal: 4),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: paymentBloc.userOrder.orderItems.length,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return ViewOrderItemTile(
                        restaurantService: paymentBloc
                            .userOrder.restaurantViewModel.restaurantService,
                        restaurantTaxes: paymentBloc
                            .userOrder.restaurantViewModel.restaurantTaxes,
                        orderViewModel: _userOrderModel.orderItems[index],
                      );
                    },
                  ),
                  Divider(),
                  HelperWidget.verticalSpacer(heightVal: 10),
                  Visibility(
                    visible: paymentBloc.userOrder.otherPeopleOrderItems !=
                            null &&
                        paymentBloc.userOrder.otherPeopleOrderItems.length > 0,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            '${(LocalKeys.YOUR_FRIENDS_ITEMS_LABEL).tr()}',
                            textAlign: TextAlign.start,
                            textScaleFactor: 1,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${(LocalKeys.ORIGINAL_PRICE).tr()} (${getPriceWithLabel(getYourFriendsTotal())})',
                            textScaleFactor: 1,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  HelperWidget.verticalSpacer(heightVal: 4),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount:
                        paymentBloc.userOrder.otherPeopleOrderItems != null
                            ? paymentBloc.userOrder.otherPeopleOrderItems.length
                            : 0,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return ViewOrderItemTile(
                        restaurantService: paymentBloc
                            .userOrder.restaurantViewModel.restaurantService,
                        restaurantTaxes: paymentBloc
                            .userOrder.restaurantViewModel.restaurantTaxes,
                        orderViewModel:
                            paymentBloc.userOrder.otherPeopleOrderItems[index],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  getYourTotal() {
    double orderPrice = UserCart().calculateCart();

    return orderPrice;
  }
  getYourFriendsTotal() {
    double yourTotal = getYourTotal();
    double orderTotal = UserCart().calculateOrder();
    return orderTotal - yourTotal;
  }
  getPriceWithLabel(double price) {
    return price.toStringAsFixed(2) + (_userOrderModel.restaurantViewModel.restaurantCurrency.currencyName ?? '');
  }
}
