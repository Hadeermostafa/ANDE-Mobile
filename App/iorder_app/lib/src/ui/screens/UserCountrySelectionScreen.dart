import 'dart:convert';
import 'dart:io';

import 'package:ande_app/main.dart';
import 'package:ande_app/src/blocs/bloc/ApplicaitonDataBloc.dart';
import 'package:ande_app/src/blocs/bloc/UserBloc.dart';
import 'package:ande_app/src/data_providers/models/CountryModel.dart';
import 'package:ande_app/src/resources/Constants.dart';
import 'package:ande_app/src/ui/screens/LandingScreen.dart';
import 'package:ande_app/src/ui/widgets/AndeAppbar.dart';
import 'package:ande_app/src/ui/widgets/CountryPickerCard.dart';
import 'package:ande_app/src/ui/widgets/HelperWidgets.dart';
import 'package:ande_app/src/ui/widgets/ListViewAnimatorWidget.dart';
import 'package:ande_app/src/utilities/LocalKeys.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserCountrySelectionScreen extends StatefulWidget {
  @override
  _UserCountrySelectionScreenState createState() =>
      _UserCountrySelectionScreenState();
}
class _UserCountrySelectionScreenState extends State<UserCountrySelectionScreen> {

  GlobalKey<ScaffoldState> _scaffoldKey ;
  ApplicationDataBloc appDataBloc;

  @override
  void initState() {
    super.initState();
    appDataBloc = BlocProvider.of<ApplicationDataBloc>(context);
    _scaffoldKey = GlobalKey<ScaffoldState>();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      key: _scaffoldKey,
      appBar: AndeAppbar(
        screenTitle: (LocalKeys.CHOOSE_COUNTRY).tr(),
        hasBackButton: false,
      ),
      body: BlocConsumer(
        bloc: appDataBloc,
        listener: (context, state) async {
          if (state is ApplicationDataLoadingFailed) {
            if (state.error.errorCode == HttpStatus.requestTimeout) {
              HelperWidget.showNetworkErrorDialog(context);
              await Future.delayed(Duration(seconds: 2), () {});
              HelperWidget.removeNetworkErrorDialog(context);
              resolveNeedRedispatch(state.failureEvent);
              return;
            }
            else if (state.error.errorCode == HttpStatus.serviceUnavailable) {
              HelperWidget.showToast(message: (LocalKeys.SERVER_UNREACHABLE).tr(), isError: true);
            }
            else {
              HelperWidget.showToast(message: state.error.errorMessage ?? '' , isError: true);
            }
          }
        },
        builder: (context, state) {
          if (state is ApplicationDataLoaded) {
            return ListViewAnimatorWidget(
              isScrollEnabled : true ,
              listChildrenWidgets: (appDataBloc.supportedCountries ?? []).map((CountryModel country) => CountryPickerCard(
                onTap: (){
                  onCountryTapped(country , context);
                  return;
                },
                supportedCountry: country,
              )).toList(),
            );
          }
          else {
            return Center(child: loadingFlare);
          }
        },
      ),
    );
  }
  void onCountryTapped(CountryModel supportedCountry , context) async{

    // set the user country to the selected user location
    // and set the last known place for him also

    BlocProvider.of<UserBloc>(context).currentLoggedInUser.userLastKnownLocation.countryId = supportedCountry.countryId;
    BlocProvider.of<UserBloc>(context).userCountry = supportedCountry;
    await FirebaseAnalytics().logEvent(name: "Country_Selection", parameters: {
      "country" : supportedCountry.countryName,
    });

    SharedPreferences preference = await SharedPreferences.getInstance();
    await preference.setString(Constants.USER_PREFERENCE_COUNTRY_KEY, json.encode(supportedCountry.toJson()));

    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
        builder: (context) => LandingScreen()) , (_)=> false);
  }
  void resolveNeedRedispatch(ApplicationDataBlocEvents failureEvent) {
    appDataBloc.add(failureEvent);
    return;
  }
}


