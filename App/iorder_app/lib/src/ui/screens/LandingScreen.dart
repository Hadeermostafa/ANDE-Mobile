import 'dart:io';

import 'package:ande_app/main.dart';
import 'package:ande_app/src/blocs/bloc/UserBloc.dart';
import 'package:ande_app/src/blocs/bloc/VoucherBloc.dart';
import 'package:ande_app/src/blocs/states/UserStates.dart';
import 'package:ande_app/src/resources/Constants.dart';
import 'package:ande_app/src/resources/Resources.dart';
import 'package:ande_app/src/resources/external_resource/AndeBottomNavigationBar.dart';
import 'package:ande_app/src/ui/screens/RestaurantSplashScreen.dart';
import 'package:ande_app/src/ui/screens/delivery_screens/AndeDeliveryPaymentScreen.dart';
import 'package:ande_app/src/ui/screens/dining_screens/AndeScanBarcodeScreen.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'delivery_screens/ResturantsListScreen.dart';
import 'dining_screens/AndeDineInPaymentScreen.dart';

class LandingScreen extends StatefulWidget {
  final int pageIndex;
  LandingScreen({this.pageIndex = 0});

  @override
  _LandingScreenState createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  int currentVisiblePageIndex;
  List<Widget> screens = [];
  List<BottomNavigationBarItem> barTabs = [];
  final double iconSize = 45;

  @override
  void initState() {
    super.initState();
    currentVisiblePageIndex = widget.pageIndex ?? 0;
    screens = [
      AndeScanBarCodeScreen(),
      RestaurantsListScreen(),
    ];
    barTabs = [
      BottomNavigationBarItem(
          icon: SvgPicture.asset(
            Constants.currentAppLocale == "en"
                ? Resources.bottomNavQRIconEN
                : Resources.bottomNavQRIconAR,
            placeholderBuilder: (context) => CircularProgressIndicator(),
            height: 40,
            color: Colors.grey,
          ),
          activeIcon: SvgPicture.asset(
            Constants.currentAppLocale == "en"
                ? Resources.bottomNavQRIconEN
                : Resources.bottomNavQRIconAR,
            placeholderBuilder: (context) => CircularProgressIndicator(),
            height: 40,
            color: Colors.black,
          ),
          label: ''),
      BottomNavigationBarItem(
          icon: SvgPicture.asset(
            Constants.currentAppLocale == "en" ? Resources
                .bottomNavDeliveryIconEN :
            Resources.bottomNavDeliveryIconAR,
            key: Key('delivery'),
            placeholderBuilder: (context) => CircularProgressIndicator(),
            height: 40,
            color: Colors.grey,
          ),
          activeIcon: SvgPicture.asset(
            Constants.currentAppLocale == "en"
                ? Resources.bottomNavDeliveryIconEN
                : Resources.bottomNavDeliveryIconAR,
            placeholderBuilder: (context) => CircularProgressIndicator(),
            height: 40.0,
            color: Colors.black,
          ),
          label: ''),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: BlocConsumer(
            listener: (context, state) {
              if (state is UserLoadedWithActiveOrderState) {
                if (state.restaurantType == RestaurantLoadingType.DINING) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                        builder: (context) {
                          return BlocProvider.value(
                            value: VoucherBloc(),
                            child: AndeDineInPaymentScreen(
                              userOrderModel: state.activeOrder,
                              comingFromActive: true,
                            ),
                          );
                        },
                        settings: RouteSettings(
                            name: AndeDineInPaymentScreen.DINE_PAYMENT_KEY)),
                  );
                } else if (state.restaurantType ==
                    RestaurantLoadingType.DELIVERY) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) {
                          return AndeDeliveryPaymentScreen(
                            comingFromActive: false,
                            userOrderModel: state.activeOrder,
                          );
                        },
                        settings: RouteSettings(
                            name: AndeDeliveryPaymentScreen
                                .DELIVERY_PAYMENT_KEY)),
                    (route) => false,
                  );
                }
              }
            },
            bloc: BlocProvider.of<UserBloc>(context),
            builder: (context, state) {
              return ModalProgressHUD(
                progressIndicator: loadingFlare,
                inAsyncCall: state is UserLoadingState,
                child: Stack(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height - (Platform.isIOS ? 75 : 65),
                      child: screens[currentVisiblePageIndex],
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(0xffFCFCFC),
                          border:
                              Border(top: BorderSide(color: Color(0xffDDDDDD))),
                        ),
                        height: Platform.isIOS ? 80 : 70,
                        width: MediaQuery.of(context).size.width,
                        child: AndeBottomNavigationBar(
                          backgroundColor: Color(0xffFCFCFC),
                          items: barTabs,
                          unselectedItemColor: Colors.grey,
                          type: BottomNavigationBarType.fixed,
                          currentIndex: currentVisiblePageIndex,
                          selectedItemColor: Colors.black,
                          iconSize: 25,
                          selectedFontSize: 0,
                          onTap: (selectedIndex) {
                            if (selectedIndex == 1)
                              FirebaseCrashlytics.instance.recordError(
                                  Exception("Restaurant Listing Error"),
                                  StackTrace.current);
                            currentVisiblePageIndex = selectedIndex;
                            setState(() {});
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }));
  }
}
