import 'dart:io';

import 'package:ande_app/src/data_providers/APIs/LoginAPIs.dart';
import 'package:ande_app/src/data_providers/models/ErrorViewModel.dart';
import 'package:ande_app/src/data_providers/models/ResponseModel.dart';
import 'package:ande_app/src/data_providers/models/UserViewModel.dart';
import 'package:ande_app/src/resources/Constants.dart';
import 'package:ande_app/src/resources/Repository.dart';
import 'package:ande_app/src/utilities/LocalKeys.dart';
import 'package:ande_app/src/utilities/NetworkUtilities.dart';
import 'package:bloc/bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

import '../events/AuthenticationEvents.dart';
import '../events/LoginEvents.dart';
import '../states/LoginStates.dart';
import 'AuthenticationBloc.dart';

class LoginBloc extends Bloc<LoginEvents, LoginStates> {
  BehaviorSubject<String> phoneUser = BehaviorSubject<String>();
  Stream<String> get phoneAuthStream => phoneUser.stream;

  @override
  LoginStates get initialState => LoginInitialized();
  final AuthenticationBloc authenticationBloc;
  LoginBloc({@required this.authenticationBloc});

  @override
  Stream<LoginStates> mapEventToState(LoginEvents event) async* {
    bool isConnected = await NetworkUtilities.isConnected();
    if (isConnected == false) {
      yield LoginError(
        event: event,
        error: Constants.connectionTimeoutException,
      );
      return;
    }

    if (event is CodeRequestFinished) {
      yield event.afterRequestState;
      return;
    }

    yield LoginLoading();
    if (event is RequestPhoneAuthCode) {
      LoginAPIs.requestPhoneCode(
          phoneNumber: getEnglishPhoneNumber(event.userPhone),
          onAuthFail: onAuthFailed,
          onAuthComplete: onAuthCompleted,
          onCodeSent: onMessageReceived,
          onTimeout: onAuthVerificationCodeIdChange);
      return;
    }

    if (event is PerformLogin) {
      yield* _handleLoginUser(event);
      return;
    }
  }

  Future<ResponseViewModel<String>> performLogin(LoginMethods loginMethod,
      {AuthCredential credential}) async {
    try {
      await Repository.deleteAnonymousUser();
    } catch (e){
      debugPrint(e.toString());
    }
    ResponseViewModel<String> userToken;
    if (loginMethod == LoginMethods.FACEBOOK) {
      userToken = await Repository.loginWithFacebook();
    } else if (loginMethod == LoginMethods.APPLE) {
      userToken = await Repository.loginWithApple();
    }
    else if (loginMethod == LoginMethods.PHONE) {
      userToken = await Repository.loginWithPhone(credential);
    } else if (loginMethod == LoginMethods.TWITTER) {
      userToken = await Repository.loginWithTwitter();
    }
    return userToken;
  }

  String getEnglishPhoneNumber(String userPhone) {
    String enPhoneCode = "";
    for (int i = 0; i < userPhone.length; i++) {
      if (userPhone[i] == '٠')
        enPhoneCode += '0';
      else if (userPhone[i] == '١')
        enPhoneCode += '1';
      else if (userPhone[i] == '٢')
        enPhoneCode += '2';
      else if (userPhone[i] == '٣')
        enPhoneCode += '3';
      else if (userPhone[i] == '٤')
        enPhoneCode += '4';
      else if (userPhone[i] == '٥')
        enPhoneCode += '5';
      else if (userPhone[i] == '٦')
        enPhoneCode += '6';
      else if (userPhone[i] == '٧')
        enPhoneCode += '7';
      else if (userPhone[i] == '٨')
        enPhoneCode += '8';
      else if (userPhone[i] == '٩')
        enPhoneCode += '9';
      else
        enPhoneCode += userPhone[i];
    }
    return enPhoneCode;
  }

  Stream<LoginStates> _handleLoginUser(PerformLogin event) async* {


    AuthCredential _loginCredentials;


    if(event.loginMethod == LoginMethods.PHONE){
     _loginCredentials = event.authCredentials;
      if (_loginCredentials == null)
        _loginCredentials = PhoneAuthProvider.credential(verificationId: phoneUser.value, smsCode: event.smsCode);
    }

    // Handle Social Media Login and get Token to use it for Server Login
    ResponseViewModel<String> userTokenResponse = await performLogin(event.loginMethod, credential: _loginCredentials);

    if (userTokenResponse.isSuccess) {
      ResponseViewModel<UserViewModel> userInformation =
          await Repository.serverLogin(
              socialMediaToken: userTokenResponse.responseData);
      if (userInformation.isSuccess) {
        await Repository.saveAccessToken(userInformation.responseData.userToken);
        await Repository.saveUserId(userInformation.responseData.userId);
        authenticationBloc
            .add(Login(userToken: userTokenResponse.responseData));
        yield LoginSuccess(loginMethod: event.loginMethod);
        return;
      } else {
        await FirebaseAuth.instance.signOut();
        yield LoginError(error: userInformation.serverError);
      }
    } else {
      // if the user can't pass social media login sign him out and sign him as Anonymous
      await FirebaseAuth.instance.signOut();
      await Repository.loginAnonymously();
      yield LoginError(error: userTokenResponse.serverError);
    }
  }

//-----------------------------------------------------------------------------------
  // Firebase PhoneAuth callbacks
  onMessageReceived(String verificationId) {
    phoneUser.sink.add(verificationId);
    add(CodeRequestFinished(afterRequestState: WaitingAuthCode()));
  }

  onAuthCompleted(AuthCredential credentials) {
    add(PerformLogin(
      authCredentials: credentials,
      loginMethod: LoginMethods.PHONE,
    ));
  }

  onAuthFailed(FirebaseAuthException error) {
    String errorMessage = '';
    if (error.code.contains('invalid-verification-code')) {
      errorMessage = (LocalKeys.INVALID_AUTH_CODE).tr();
    }
    else if (error.code.contains('too-many-requests')) {
      errorMessage = (LocalKeys.PHONE_NUMBER_IS_BLOCKED).tr();
    }
    else {
      errorMessage = (LocalKeys.INVALID_PHONE_NUMBER).tr();
    }
    add(CodeRequestFinished(
        afterRequestState: LoginError(
            error: ErrorViewModel(errorMessage: errorMessage, errorCode: HttpStatus.notFound))));
    return;
  }

  onAuthVerificationCodeIdChange(String verificationId) {
    phoneUser.sink.add(verificationId);
  }
}
