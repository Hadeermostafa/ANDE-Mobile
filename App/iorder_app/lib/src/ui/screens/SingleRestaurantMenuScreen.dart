import 'dart:io';

import 'package:ande_app/src/blocs/bloc/SingleRestaurantBloc.dart';
import 'package:ande_app/src/blocs/bloc/UserBloc.dart';
import 'package:ande_app/src/blocs/bloc/VoucherBloc.dart';
import 'package:ande_app/src/blocs/events/SingleRestaurantEvents.dart';
import 'package:ande_app/src/blocs/states/SingleRestaurantStates.dart';
import 'package:ande_app/src/blocs/states/UserStates.dart';
import 'package:ande_app/src/data_providers/models/LanguageModel.dart';
import 'package:ande_app/src/data_providers/models/RestaurantMenuModel.dart';
import 'package:ande_app/src/data_providers/models/RestaurantViewModel.dart';
import 'package:ande_app/src/data_providers/models/delivery/RestaurantDeliveryInformation.dart';
import 'package:ande_app/src/data_providers/models/product/ProductListViewModel.dart';
import 'package:ande_app/src/resources/Constants.dart';
import 'package:ande_app/src/resources/UserCart.dart';
import 'package:ande_app/src/ui/dialogs/WarningDialog.dart';
import 'package:ande_app/src/ui/screens/LandingScreen.dart';
import 'package:ande_app/src/ui/screens/RestaurantSplashScreen.dart';
import 'package:ande_app/src/ui/widgets/AndeAppbar.dart';
import 'package:ande_app/src/ui/widgets/DeliveryFooter.dart';
import 'package:ande_app/src/ui/widgets/ErrorView.dart';
import 'package:ande_app/src/ui/widgets/FooterBottomBar.dart';
import 'package:ande_app/src/ui/widgets/HelperWidgets.dart';
import 'package:ande_app/src/ui/widgets/RestaurantMenuWidget.dart';
import 'package:ande_app/src/utilities/LocalKeys.dart';
import 'package:easy_localization/easy_localization.dart' as ll;
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../main.dart';
import 'SingleProductDetailsScreen.dart';
import 'delivery_screens/AndeDeliveryPaymentScreen.dart';
import 'delivery_screens/DeliveryOrderCartScreen.dart';
import 'dining_screens/AndeDineInPaymentScreen.dart';
import 'dining_screens/OrderCartScreen.dart';

class SingleRestaurantMenuScreen extends StatefulWidget {
  final String restaurantID;
  final RestaurantLoadingType restaurantType;
  final RestaurantViewModel restaurantItemViewModel;

  SingleRestaurantMenuScreen(
      {this.restaurantID, this.restaurantType, this.restaurantItemViewModel});

  @override
  _SingleRestaurantMenuScreenState createState() =>
      _SingleRestaurantMenuScreenState();
}

class _SingleRestaurantMenuScreenState extends State<SingleRestaurantMenuScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  String restaurantID;
  SingleRestaurantBloc _bloc;
  AnimationController cartAnimationController;
  Animation cartFadeAnimation, cartMovementAnimation;
  var _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _bloc = BlocProvider.of<SingleRestaurantBloc>(context);
    cartAnimationController = AnimationController(
        duration: const Duration(seconds: 1, milliseconds: 300), vsync: this);
    cartFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(cartAnimationController);
    cartMovementAnimation = Tween<Offset>(
      begin: Offset(Offset.zero.dx, Offset.zero.dy + 20),
      end: Offset.zero,
    ).animate(cartAnimationController);

    // if Normal Flow or restaurant is Loaded already => Restaurant is loaded in its own Splash
    // if coming From Active Order => Restaurant to be loaded here

    if (_bloc.restaurantModel == null || widget.restaurantItemViewModel == null) {
      _bloc.add(LoadRestaurantDetails(restaurantId: widget.restaurantID, as: widget.restaurantType));
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    bool showErrorView = _bloc.state is RestaurantInformationLoadingError
    && (_bloc.state as RestaurantInformationLoadingError).error.errorCode != 408;


    // to update the current state for the streams each time the screen opens
    _bloc.updateUI();
    return WillPopScope(
        onWillPop: () async => dismissPage(),
        child: (showErrorView == false)
            ? getScreenBody(context)
            : getErrorView(context , _bloc.state as RestaurantInformationLoadingError).error);
  }


  Widget getDiningScreenFooter() {
    double _finalPrice = 0;
    return StreamBuilder<double>(
      stream: _bloc.cartTotalPriceStream,
      builder: (context, snapshot) {
        try {
          if (snapshot.hasData) {
            _finalPrice = snapshot.data +
                (snapshot.data * _bloc.restaurantModel.restaurantTaxes / 100) +
                (snapshot.data * _bloc.restaurantModel.restaurantService / 100);
          } else {
            _finalPrice = _bloc.restaurantModel.restaurantService;
          }
        } catch (ex) {
          _finalPrice = 0;
        }
        return Container(
          child: FooterBottomBar(
            restaurantCurrency: _bloc.restaurantModel.restaurantCurrency.currencyName,
            showTotal: false,
            orderSubTotal: snapshot.data,
            orderTotal: _finalPrice,
            restaurantService: _bloc.restaurantModel != null
                ? _bloc.restaurantModel.restaurantService
                : 0,
            restaurantTaxes: _bloc.restaurantModel != null
                ? _bloc.restaurantModel.restaurantTaxes
                : 0,
            isPercent: true,
          ),
        );
      },
    );
  }
  Widget getDeliveryScreenFooter() {
    return StreamBuilder<double>(
      stream: _bloc.cartTotalPriceStream,
      builder: (context, snapshot) {
        return Container(
          child: DeliveryFooter(
            feesType: DeliveryFeesType.AREA_BASED,
            orderNetPrice: snapshot.data,
            restaurantService: _bloc.restaurantModel != null
                ? _bloc.restaurantModel.restaurantTaxes ?? 0
                : 0,
            restaurantCurrency: _bloc.restaurantModel.restaurantCurrency.currencyName ?? '',
          ),
        );
      },
    );
  }


  @override
  void dispose() {

    cartAnimationController.dispose();


    _bloc.dispose();
    super.dispose();
  }


   dismissPage() async {
    bool hasActiveOrder = BlocProvider.of<UserBloc>(context).state is UserLoadedWithActiveOrderState;
    hasActiveOrder = hasActiveOrder || (UserCart().getConfirmedItems != null && UserCart().getConfirmedItems.length > 0);

    if (hasActiveOrder == true) {
      UserCart().nonConfirmedItemsList.clear();
        if (widget.restaurantType == RestaurantLoadingType.DINING) {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) {
                return BlocProvider.value(
                  value: VoucherBloc(),
                  child: AndeDineInPaymentScreen(
                    userOrderModel:
                        BlocProvider.of<UserBloc>(context).userActiveOrder,
                    comingFromActive: false,
                  ),
                );
              },
              settings: RouteSettings(name: AndeDineInPaymentScreen.DINE_PAYMENT_KEY),
            ),
          );
        }
        else {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) {
                return BlocProvider.value(
                  value: _bloc,
                  child: AndeDeliveryPaymentScreen(
                    userOrderModel:
                        BlocProvider.of<UserBloc>(context).userActiveOrder,
                    comingFromActive: false,
                  ),
                );
              },
            ),);
        }
    }
    else {
      if (UserCart().cartSize > 0) {
        var userAccept = await showDialog(
            context: context,
            builder: (context) => WarningDialog(
                  message: (LocalKeys.CART_CLEAR_WARNING).tr(),
                  actions: <Widget>[
                    SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      child: ButtonTheme(
                        shape: RoundedRectangleBorder(
                            side: BorderSide(
                              width: 1,
                              color: Colors.grey[900],
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(9))),
                        height: 60,
                        child: FlatButton(
                          padding: EdgeInsets.all(0),
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                          color: Colors.grey[900],
                          child: Text(
                            (LocalKeys.OK).tr(),
                            textScaleFactor: 1,
                            style: TextStyle(
                              fontFamily: Constants.FONT_MONTSERRAT,
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      child: ButtonTheme(
                        height: 60,
                        child: FlatButton(
                          shape: RoundedRectangleBorder(
                              side: BorderSide(
                                width: 1,
                                color: Colors.grey[900],
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(9))),
                          padding: EdgeInsets.all(0),
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                          color: Colors.white,
                          child: Text(
                            (LocalKeys.STAY).tr(),
                            textScaleFactor: 1,
                            style: TextStyle(
                              fontFamily: Constants.FONT_MONTSERRAT,
                              fontSize: 14,
                              color: Colors.grey[900],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                  ],
                ));
        if (userAccept ?? false) {
          UserCart().clearCart();
            if(Navigator.of(context).canPop()){
              Navigator.of(context).pop(true);
            } else {
              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => LandingScreen()), (route) => false);
            }
          }
      } else {
        UserCart().clearCart();
        if(Navigator.of(context).canPop()){
          Navigator.of(context).pop(true);
        } else {
          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => LandingScreen()), (route) => false);
        }
      }
    }
  }


  getScreenBody(BuildContext context) {


    // Animate the Cart
    if(_bloc.getCartCount > 0)
      cartAnimationController.forward();


    return BlocConsumer(
      bloc: _bloc,
      builder: (context, state) {
      if (state is RestaurantInformationLoaded) {
        return Scaffold(
          key: _scaffoldKey,
          floatingActionButton: getCartView(),
          appBar: AndeAppbar(
            leading: FlatButton.icon(
                onPressed: () async => dismissPage(),
                icon: Icon(
                  Icons.arrow_back_ios,
                  size: 18,
                  color: Colors.white,
                ),
                label: Text('')),
            screenTitle: (_bloc.restaurantModel?.restaurantListViewModel != null)
                ? _bloc.restaurantModel.restaurantListViewModel.restaurantName
                : "",
          ),
          body: Column(
            children: <Widget>[
              RestaurantMenuWidget(
                restaurantModel: _bloc.restaurantModel,
                languageModel:_bloc.restaurantModel.languagesList != null && _bloc.restaurantModel.languagesList.length > 0
                    ? _bloc.restaurantModel.languagesList[0] : LanguageModel(localeCode: Constants.currentAppLocale, localeName: Constants.currentAppLocale == 'en' ? ll.tr(LocalKeys.ENGLISH_LOCALE) : ll.tr(LocalKeys.ARABIC_LOCALE)),
                onMenuItemClicked: onItemClicked,
                onMenuLanguageChange: (RestaurantMenuModel restaurantMenu){
                  _bloc.restaurantModel.restaurantListViewModel.restaurantName = restaurantMenu.restaurantName;
                  _bloc.restaurantModel.restaurantMenuModel = restaurantMenu;
                  setState(() {});
                },
              ),
              widget.restaurantType == RestaurantLoadingType.DINING
                  ? getDiningScreenFooter()
                  : getDeliveryScreenFooter(),
            ],
          ),
        );
      }
      else if (state is RestaurantInformationLoading) {
        return Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(55.0),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage('assets/images/background.jpg'),
                  )),
              child: AppBar(
                centerTitle: true,
                title: Text(
                  (_bloc.restaurantModel != null && _bloc.restaurantModel.restaurantListViewModel != null)
                      ? _bloc.restaurantModel.restaurantListViewModel.restaurantName : "",
                  textScaleFactor: 1,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                automaticallyImplyLeading: false,
                backgroundColor: Colors.transparent,
              ),
            ),
          ),
          body: Align(
            alignment: Alignment.center,
            child: loadingFlare,
          ),
        );
      }
      else {
        return getErrorView(context, state);
      }
    }, listener: (context, state) async{
      if (state is RestaurantInformationLoadingError) {
        if (state.error.errorCode == HttpStatus.requestTimeout) {
          HelperWidget.showNetworkErrorDialog(context);
          await Future.delayed(Duration(seconds: 2), () {});
          HelperWidget.removeNetworkErrorDialog(context);
        }
        else if (state.error.errorCode == HttpStatus.serviceUnavailable) {
          HelperWidget.showToast(message: (LocalKeys.SERVER_UNREACHABLE).tr(), isError: true);
          return;
        }
        else if (state.error.errorCode != 401) {
          HelperWidget.showToast(message: state.error.errorMessage ?? '', isError: true);
          return;
        }
      }
    },);


  }


  getErrorView(BuildContext context,  state) {

    return Scaffold(
        appBar: AndeAppbar(
          screenTitle: '',
          hasBackButton: false,
        ),
        body: ErrorView(
          errorMessage: (LocalKeys.RESTAURANT_NOT_EXIST).tr(),
          retryAction: backButtonPressed,
        ));
  }

  void backButtonPressed() {
    //Constants.currentRestaurantLocale = ll.EasyLocalization.of(context).locale.languageCode;
    Navigator.of(context).pop();
  }

  @override
  bool get wantKeepAlive => true;

  void onItemClicked(ProductListViewModel item) async {
    RestaurantViewModel restaurantViewModel = widget.restaurantItemViewModel ?? _bloc.restaurantModel;
    cartAnimationController.reset();
    FirebaseAnalytics().logViewItem(itemId: item.itemId.toString(), itemName: item.itemName, itemCategory: item.itemCategoryId , price: item.itemBasePrice );



    await Navigator.of(context).push(MaterialPageRoute(builder: (context) =>  SingleProductDetailsScreen(
      productId: item.itemId.toString(),
      productName: item.itemName,
      restaurantInfo: _bloc.restaurantModel,
      restaurantType: widget.restaurantType,
      language: _bloc.restaurantModel.restaurantMenuModel.currentlyDisplayingLanguage.localeCode ?? Constants.currentRestaurantLocale,
    ),
      ),);
    setState(() {});
  }

  void navigateToAfterCartScreen() {

    if (UserCart().cartSize > 0) {
      cartAnimationController.reset();
      if (widget.restaurantType == RestaurantLoadingType.DINING) {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return OrderCartScreen(
            restaurantModel: _bloc.restaurantModel,
          );
        }));
        return;
      } else {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return DeliveryOrderCartScreen(
            restaurantModel: _bloc.restaurantModel,
          );
        }),);
        return;
      }
    } else {
      HelperWidget.showToast(message: (LocalKeys.EMPTY_CART_WARNING).tr(), isError: true);
      return;
    }
  }

  Widget getCartView() {
   return GestureDetector(
     onTap: navigateToAfterCartScreen,
     child: HelperWidget.resolveDirectionality(
        targetWidgetName: 'SingleRestaurantMenuScreen=> Floating Action Button',
        context: context,
        locale: Constants.currentRestaurantLocale,
        child: Visibility(
          visible: (_bloc.getCartCount != null) && _bloc.getCartCount > 0,
          child: AnimatedBuilder(
            animation: cartAnimationController,
            builder: (context, child) {
              return Transform.translate(
                offset: cartMovementAnimation.value,
                child: child,
              );
            },
            child: FadeTransition(
              opacity: cartFadeAnimation,
              child: Stack(
                children: <Widget>[
                  Positioned.directional(
                    textDirection: Constants.currentAppLocale == "en"
                        ? TextDirection.ltr
                        : TextDirection.rtl,
                    bottom: 35,
                    end: 0,
                    child: SizedBox(
                      width: 65,
                      height: 65,
                      child: FloatingActionButton(
                          onPressed: navigateToAfterCartScreen,
                          elevation: 1,
                          mini: false,
                          backgroundColor: Colors.red[900],
                          child: Center( key: Key('confirm order'),
                            child: Image.asset(
                              'assets/images/fab_icon.png',
                              width: 30,
                              height: 30,
                              fit: BoxFit.contain,
                              alignment: Alignment.topCenter,
                              color: Colors.white,
                            ),
                          )),
                    ),
                  ),
                  Positioned.directional(
                    textDirection: Constants.currentAppLocale == "en"
                        ? TextDirection.ltr
                        : TextDirection.rtl,
                    bottom: 60,
                    end: 12,
                    child: StreamBuilder<int>(
                        stream: _bloc.cartItemsCountStream,
                        builder: (context, snapshot) {
                          return Visibility(
                            replacement: Container(width: 0, height: 0,),
                            visible: (_bloc.getCartCount != null) && _bloc.getCartCount > 0,
                            child: Container(
                              width: 17,
                              height: 17,
                              child: Center(
                                child: Text(
                                  '${(_bloc.getCartCount > 0) ? _bloc.getCartCount : 0}',
                                  textScaleFactor: 1,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                  ),
                                ),
                              ),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.red[900],
                                  ),
                                  color: Colors.amber,
                                  shape: BoxShape.circle),
                            ),
                          );
                        }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
   );
  }
}