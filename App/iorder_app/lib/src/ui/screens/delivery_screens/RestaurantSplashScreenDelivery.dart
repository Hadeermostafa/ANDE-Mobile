
import 'dart:io';

import 'package:ande_app/src/blocs/bloc/SingleRestaurantBloc.dart';
import 'package:ande_app/src/blocs/events/SingleRestaurantEvents.dart';
import 'package:ande_app/src/blocs/states/SingleRestaurantStates.dart';
import 'package:ande_app/src/data_providers/models/RestaurantListViewModel.dart';
import 'package:ande_app/src/resources/external_resource/AndeImageNetwork.dart';
import 'package:ande_app/src/ui/screens/SingleRestaurantMenuScreen.dart';
import 'package:ande_app/src/ui/widgets/HelperWidgets.dart';
import 'package:ande_app/src/utilities/LocalKeys.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../RestaurantSplashScreen.dart';



class RestaurantSplashScreenDelivery extends StatefulWidget {

  final RestaurantListViewModel restaurantListViewModel;
  RestaurantSplashScreenDelivery({this.restaurantListViewModel});

  @override
  _RestaurantSplashScreenDeliveryState createState() => _RestaurantSplashScreenDeliveryState();
}

class _RestaurantSplashScreenDeliveryState extends State<RestaurantSplashScreenDelivery>
    with TickerProviderStateMixin {
  SingleRestaurantBloc _bloc = SingleRestaurantBloc();
  AnimationController nameAnimationController, logoAnimationController;
  Animation nameAnimation, logoAnimation;

  @override
  void initState() {
    initAnimations();
    if (widget.restaurantListViewModel.restaurantId != null)
      _bloc.add(LoadRestaurantDetails(restaurantId: widget.restaurantListViewModel.restaurantId.toString() , as: RestaurantLoadingType.DELIVERY ));
    else
      Navigator.pop(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener(
        bloc: _bloc,
        listener: (context, state) async{
          if(state is RestaurantInformationLoadingError){
            if (state.error.errorCode == HttpStatus.requestTimeout) {
              HelperWidget.showNetworkErrorDialog(context);
              await Future.delayed(Duration(seconds: 2), () {});
              HelperWidget.removeNetworkErrorDialog(context);
              _bloc.add(state.event);
            }
            else if (state.error.errorCode == HttpStatus.serviceUnavailable) {
              HelperWidget.showToast(message: (LocalKeys.SERVER_UNREACHABLE).tr(), isError: true);
            }
            else {
              HelperWidget.showToast(message: state.error.errorMessage ?? '' , isError: true);
            }
            // Navigator.pop(context);
          } else if (state is RestaurantInformationLoaded) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) {
                  return BlocProvider.value(
                    value: _bloc,
                    child: SingleRestaurantMenuScreen(
                      restaurantType: RestaurantLoadingType.DELIVERY,
                      restaurantID: widget.restaurantListViewModel.restaurantId.toString(),
                      restaurantItemViewModel: state.restaurantViewModel,
                    ),
                  );
                },
              ),
            );
          }
        },
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(image: AssetImage('assets/images/background.jpg'), fit: BoxFit.cover),
          ),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                AnimatedBuilder(
                  animation: logoAnimationController,
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                    child: Container(
                      height: 100,
                      width: 100,
                      child: AndeImageNetwork(widget.restaurantListViewModel.restaurantImagePath , constrained: false, fit: BoxFit.cover,),
                    ),
                  ),
                  builder: (context, child) {
                    return Transform.translate(
                      offset: logoAnimation.value,
                      child: child,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameAnimationController.dispose();
    logoAnimationController.dispose();
    super.dispose();
  }

  void initAnimations() {
    nameAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    nameAnimation = Tween<Offset>(
        end: Offset(Offset.zero.dx, Offset.zero.dy + 10),
        begin: Offset(Offset.zero.dx, 50)).animate(nameAnimationController);
    logoAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    logoAnimation = Tween<Offset>(end: Offset.zero, begin: Offset(Offset.zero.dx, -50)).animate(logoAnimationController);

    logoAnimationController.forward();
    nameAnimationController.forward();
  }

}