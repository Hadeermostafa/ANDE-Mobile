import 'dart:convert';
import 'dart:io';

import 'package:ande_app/src/blocs/bloc/ApplicaitonDataBloc.dart';
import 'package:ande_app/src/blocs/bloc/VoucherBloc.dart';
import 'package:ande_app/src/blocs/states/UserStates.dart';
import 'package:ande_app/src/data_providers/models/CountryModel.dart';
import 'package:ande_app/src/data_providers/models/OrderViewModel.dart';
import 'package:ande_app/src/resources/Constants.dart';
import 'package:ande_app/src/resources/Resources.dart';
import 'package:ande_app/src/ui/screens/LandingScreen.dart';
import 'package:ande_app/src/ui/screens/RestaurantSplashScreen.dart';
import 'package:ande_app/src/ui/widgets/HelperWidgets.dart';
import 'package:ande_app/src/utilities/DeepLinkHelper.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../blocs/bloc/UserBloc.dart';
import '../../blocs/events/AuthenticationEvents.dart';
import '../../blocs/states/AuthenticationStates.dart';
import 'UserCountrySelectionScreen.dart';
import 'delivery_screens/AndeDeliveryPaymentScreen.dart';
import 'dining_screens/AndeDineInPaymentScreen.dart';

class SplashScreen extends StatefulWidget {
  final GlobalKey<NavigatorState>navigatorKey;

  SplashScreen(this.navigatorKey);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    DynamicLinkHelper.initDynamicLinks(context, widget.navigatorKey);
    BlocProvider.of<UserBloc>(context).listen((state) {
      if (ModalRoute.of(context).isCurrent) {
        if(state is UserLoadingFailed){
          if(state.error.errorCode == HttpStatus.requestTimeout){
            BlocProvider.of<UserBloc>(context).add(state.event);
            return;
          } else {
            navigateToHomeScreen(context);
            return;
          }
        }
        if (state is UserLoadedWithActiveOrderState) {
          navigateToActiveOrderScreen(state.activeOrder, context, state.restaurantType);
          return;
        }
        if (state is UserLoadedWithoutActiveOrderState) {
          navigateToHomeScreen(context);
          return;
        }
      }
    });


    BlocProvider.of<UserBloc>(context).authBloc.listen((state) async {
      if (state is UserAuthenticated) {
        if(ModalRoute.of(context).isCurrent) {
          BlocProvider.of<ApplicationDataBloc>(context).add(LoadApplicationData());
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer(
      bloc: BlocProvider.of<UserBloc>(context).authBloc,
      listener: (context, state) async {
        if (state is UserAuthenticationFailed) {
          if (state.error.errorCode == HttpStatus.requestTimeout) {
            HelperWidget.showBlockingNetworkErrorDialog(context);
            Future.delayed(Duration(seconds: 2), () {
              Navigator.pop(context);
            });
            Future.delayed(Duration(seconds: 5), () {
              BlocProvider.of<UserBloc>(context).authBloc.add(state.event);
            });
          }
        }
      },
      builder: (context, state) {
        return Scaffold(
          key: _scaffoldKey,
          body: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage(Resources.splashScreenBackground),
                      fit: BoxFit.fill),
                ),
              ),
              Positioned.fill(
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    child: Center(
                      child: FlareActor("assets/flr/ande.flr",
                          alignment: Alignment.center,
                          fit: BoxFit.fill,
                          animation: "Untitled"),
                    ),

                  ),

                ),
              )
            ],
          ),
        );
      },
    );
  }

  void navigateToHomeScreen(context) async {
    if (ModalRoute.of(context).isCurrent == false) {
      return;
    }


    CountryModel country;
    try {
      SharedPreferences preference = await SharedPreferences.getInstance();
      country = CountryModel.fromJson(json.decode(preference.getString(Constants.USER_PREFERENCE_COUNTRY_KEY)));
      BlocProvider.of<UserBloc>(context).userCountry = country;
    } catch (sharedPreferenceException) {
      debugPrint(sharedPreferenceException.toString());
    }


    // checks if the user's location is known then redirect him to the landing page
    // if the user location is not known , then he needs to select the country to see the restaurants

    if (BlocProvider.of<UserBloc>(context).isAnonymous() || BlocProvider.of<UserBloc>(context).userCountry == null || country == null) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) {
          return UserCountrySelectionScreen();
        },
      ),);
    }
    else {
      BlocProvider
          .of<UserBloc>(context)
          .currentLoggedInUser
          .userLastKnownLocation
          .countryId = country.countryId;
      BlocProvider
          .of<UserBloc>(context)
          .userCountry = country;
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) {
              return LandingScreen();
            },
          ),
      );
    }
  }

  void navigateToActiveOrderScreen(OrderViewModel activeOrder, context, RestaurantLoadingType restaurantLoadingType) async {

    CountryModel country;
    try {
      SharedPreferences preference = await SharedPreferences.getInstance();
      country = CountryModel.fromJson(json.decode(preference.getString(Constants.USER_PREFERENCE_COUNTRY_KEY)));
      BlocProvider.of<UserBloc>(context).userCountry = country;
    } catch (sharedPreferenceException) {
      debugPrint(sharedPreferenceException.toString());
    }

    // check the type of order as every type has his own screen
    // if DineIn => redirect to the payment screen associated with the dine-in
    // if Delivery => redirect to the payment screen associated with the delivery

    if (restaurantLoadingType == RestaurantLoadingType.DINING) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) {
            return BlocProvider.value(
              value: VoucherBloc(),
              child: AndeDineInPaymentScreen(
                userOrderModel: activeOrder,
                comingFromActive: true,
              ),
            );
          },settings: RouteSettings(name: AndeDineInPaymentScreen.DINE_PAYMENT_KEY)
        ),
      );
    }
    else if (restaurantLoadingType == RestaurantLoadingType.DELIVERY){
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) {
            return BlocProvider.value(
              value: VoucherBloc(),
              child: AndeDeliveryPaymentScreen(
                userOrderModel: activeOrder,
                comingFromActive: true,
              ),
            );
          },
        ),
      );
    }
  }


  // some events need to be re-dispatched automatically in case of failure
  void resolveNeedRedispatch(AuthenticationEvents event) {}


}


