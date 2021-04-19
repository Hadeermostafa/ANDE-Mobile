import 'package:ande_app/src/resources/Constants.dart';
import 'package:ande_app/src/resources/URL.dart';
import 'package:ande_app/src/resources/external_resource/AndeImageNetwork.dart';
import 'package:ande_app/src/ui/screens/SingleRestaurantMenuScreen.dart';
import 'package:ande_app/src/ui/widgets/HelperWidgets.dart';
import 'package:ande_app/src/utilities/LocalKeys.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/bloc/SingleRestaurantBloc.dart';
import '../../blocs/events/SingleRestaurantEvents.dart';
import '../../blocs/states/SingleRestaurantStates.dart';
import 'SingleRestaurantMenuScreen.dart';

class RestaurantSplashScreen extends StatefulWidget {
  final String restaurantID;
  final String restaurantImagePath;
  final String restaurantName;
  final RestaurantLoadingType type;

  RestaurantSplashScreen(
      {this.restaurantID,
      this.type,
      this.restaurantImagePath,
      this.restaurantName});

  @override
  _RestaurantSplashScreenState createState() => _RestaurantSplashScreenState();
}

class _RestaurantSplashScreenState extends State<RestaurantSplashScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  SingleRestaurantBloc _bloc = SingleRestaurantBloc();
  AnimationController nameAnimationController, logoAnimationController, fadeController;
  Animation nameAnimation, logoAnimation;
  RestaurantLoadingType type;
  Animation<double> _fadeInFadeOut;
  String _imageUrl;

  @override
  void initState() {
    nameAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    nameAnimation = Tween<Offset>(
            end: Offset(Offset.zero.dx, Offset.zero.dy + 10),
            begin: Offset(Offset.zero.dx, 50))
        .animate(nameAnimationController);
    logoAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    logoAnimation =
        Tween<Offset>(end: Offset.zero, begin: Offset(Offset.zero.dx, -50))
            .animate(logoAnimationController);
    fadeController = AnimationController(
        vsync: this,
        duration: Duration(seconds: 3),
    );
    fadeController.addStatusListener((status) { 
      if (status == AnimationStatus.completed) {
        fadeController.reverse();
      }  else if (status == AnimationStatus.dismissed) {
        fadeController.forward();
      }
    });
    _fadeInFadeOut = Tween<double>(begin: 1.0, end: 0.0).animate(fadeController);
    logoAnimationController.addStatusListener((status) { 
      if (status == AnimationStatus.completed) {
        fadeController.forward();
      }  
    });
    logoAnimationController.forward();
    nameAnimationController.forward();

    if (widget.type == null)
      type = RestaurantLoadingType.DINING;
    else
      type = widget.type;

    if (widget.restaurantID != null)
      _bloc.add(LoadRestaurantDetails(restaurantId: widget.restaurantID, as: type));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (widget.restaurantImagePath.contains(URL.BASE_IMAGE_URL)) {
      _imageUrl = widget.restaurantImagePath;
    }  else {
      _imageUrl = URL.BASE_IMAGE_URL + widget.restaurantImagePath;
    }
    return Scaffold(
      body: BlocListener(
        bloc: _bloc,
        listener: (context, state) async{
          if (state is RestaurantInformationLoadingError &&
              state.error.errorCode == Constants.connectionTimeoutException.errorCode) {
            HelperWidget.showBlockingNetworkErrorDialog(context);
            await Future.delayed(Duration(seconds: 2), () {
              Navigator.pop(context);
            });

            if (state.event is LoadRestaurantDetails) {
              _bloc.add(LoadRestaurantDetails(
                  restaurantId: widget.restaurantID, as: type));
            }
          } else if (state is RestaurantInformationLoadingError ||
              state is RestaurantInformationLoaded) {
            nameAnimationController.dispose();
            logoAnimationController.dispose();
            fadeController.dispose();
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) {
                  return BlocProvider.value(
                    value: _bloc,
                    child: SingleRestaurantMenuScreen(
                      restaurantType: type ?? RestaurantLoadingType.DINING,
                      restaurantID: widget.restaurantID,
                      restaurantItemViewModel:
                          state is RestaurantInformationLoaded
                              ? state.restaurantViewModel
                              : null,
                    ),
                  );
                },
              ),
            );
          }
        },
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/background.jpg'),
                fit: BoxFit.cover),
          ),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                AnimatedBuilder(
                  animation: logoAnimationController,
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    child: FadeTransition(
                      opacity: _fadeInFadeOut,
                      child: Material(
                        color: Colors.transparent,
                        elevation: 5,
                        child: AndeImageNetwork(
                          _imageUrl,
                          constrained: true,
                          height: 100,
                          width: 100,
                        ),
                      ),
                    ),
                  ),
                  builder: (context, child) {
                    return Transform.translate(
                      offset: logoAnimation.value,
                      child: child,
                    );
                  },
                ),
                AnimatedBuilder(
                  animation: nameAnimationController,
                  child: Text(
                    '${widget.restaurantName ?? (LocalKeys.INVALID_QR_NAME_PLACEHOLDER).tr()}',
                    textAlign: TextAlign.center,
                    textScaleFactor: 1,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                  builder: (context, child) {
                    return Transform.translate(
                      offset: nameAnimation.value,
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
  bool get wantKeepAlive => true;
}

enum RestaurantLoadingType {
  DINING,
  DELIVERY,
  PICKUP,
}
