
import 'package:ande_app/src/data_providers/models/CountryModel.dart';
import 'package:ande_app/src/data_providers/models/ErrorViewModel.dart';
import 'package:ande_app/src/data_providers/models/ResponseModel.dart';
import 'package:ande_app/src/data_providers/models/UserViewModel.dart';
import 'package:ande_app/src/resources/Constants.dart';
import 'package:ande_app/src/resources/Repository.dart';
import 'package:ande_app/src/utilities/NetworkUtilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class ApplicationDataBlocState {}

class ApplicationDataLoading extends ApplicationDataBlocState {}

class ApplicationDataLoaded extends ApplicationDataBlocState {}

class ApplicationDataLoadingFailed extends ApplicationDataBlocState {
  final ApplicationDataBlocEvents failureEvent;
  final ErrorViewModel error;
  ApplicationDataLoadingFailed({this.failureEvent, this.error});
}

abstract class ApplicationDataBlocEvents {}

class LoadApplicationData extends ApplicationDataBlocEvents {}

class ApplicationDataBloc
    extends Bloc<ApplicationDataBlocEvents, ApplicationDataBlocState> {
  @override
  ApplicationDataBlocState get initialState => ApplicationDataLoading();
  PackageInfo appInfo ;


  ApplicationDataBloc(){
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
       appInfo = packageInfo ;
    });
  }

  List<CountryModel> supportedCountries = List();
  @override
  Stream<ApplicationDataBlocState> mapEventToState(
      ApplicationDataBlocEvents event) async* {
    bool isConnected = await NetworkUtilities.isConnected();
    if (!isConnected) {
      yield ApplicationDataLoadingFailed(
        failureEvent: event,
        error: Constants.connectionTimeoutException,
      );
      return;
    }
    if (event is LoadApplicationData) {
      yield* _handleAppDataLoadingEvent(event);
    }
  }

  Stream<ApplicationDataBlocState> _handleAppDataLoadingEvent(
      LoadApplicationData event) async* {
    yield ApplicationDataLoading();
    final prefs = await SharedPreferences.getInstance();

    if (prefs.getString(Constants.USER_TOKEN_PREFERENCE_KEY) != null) {
      ResponseViewModel<UserViewModel> loginResult = await Repository.silentUserLogin();
      if(loginResult.isSuccess) {
        await Repository.saveAccessToken(loginResult.responseData.userToken);
        try {
          await Repository.saveUserId(loginResult.responseData.userId);
        } catch (e) {
          debugPrint(e.toString());
        }
      }
    }
    ResponseViewModel<List<CountryModel>> supportedCountriesResponse = await Repository.loadSupportedCountries();
    if (supportedCountriesResponse.isSuccess) {
      supportedCountries = supportedCountriesResponse.responseData;
      yield ApplicationDataLoaded();
      return;
    } else {
      yield ApplicationDataLoadingFailed(
        error: supportedCountriesResponse.serverError,
        failureEvent: event,
      );
      return;
    }
  }
}
