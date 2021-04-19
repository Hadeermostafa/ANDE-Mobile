import 'dart:io';

import 'package:ande_app/src/data_providers/models/ErrorViewModel.dart';
import 'package:ande_app/src/data_providers/models/ResponseModel.dart';
import 'package:ande_app/src/data_providers/models/UserViewModel.dart';
import 'package:ande_app/src/resources/Constants.dart';
import 'package:ande_app/src/resources/Repository.dart';
import 'package:ande_app/src/resources/URL.dart';
import 'package:ande_app/src/utilities/LocalKeys.dart';
import 'package:ande_app/src/utilities/NetworkUtilities.dart';
import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter_twitter_login/flutter_twitter_login.dart';
//import 'package:flutter_twitter_login/flutter_twitter_login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utilities/FirebaseHelper.dart';

class LoginAPIs {
  static Future<ResponseViewModel<User>> signInAnonymously() async {
    FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    User firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) {
      try {
        firebaseUser = (await _firebaseAuth.signInAnonymously()).user;
      } catch (exception) {
        debugPrint(exception.toString());
      }
    }
    return ResponseViewModel<User>(
      serverData: firebaseUser,
      isSuccess: firebaseUser != null,
      serverError:
          firebaseUser != null ? null : Constants.connectionTimeoutException,
    );
  }

  static bool isAnonymousUser() {
    return FirebaseAuth.instance.currentUser.isAnonymous;
  }

  static requestPhoneCode(
      {String phoneNumber,
      Function onTimeout,
      Function onAuthComplete,
      Function onAuthFail,
      Function onCodeSent}) {
    FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (AuthCredential credentials) {
          onAuthComplete(credentials);
          return;
        },
        verificationFailed: (FirebaseAuthException exception) {
          debugPrint("Exception in verification => ${exception.message}");
          onAuthFail(exception);
          return;
        },
        codeSent: (String tokenId, int foreResend) {
          onCodeSent(tokenId);
          return;
        },
        codeAutoRetrievalTimeout: (String tokenId) {
          onTimeout(tokenId);
          return;
        });
  }

  static Future<ResponseViewModel<String>> loginWithPhone(AuthCredential authCredential) async {
    try {
      final User user =
          (await FirebaseAuth.instance.signInWithCredential(authCredential))
              .user;
      final String token = await user.getIdToken(true);
      return ResponseViewModel<String>(
        isSuccess: user != null,
        serverData: token,
        serverError: user == null
            ? ErrorViewModel(
                errorMessage: (LocalKeys.INVALID_AUTH_CODE).tr(),
              )
            : null,
      );
    } catch (authException) {
      try {
        FirebaseAuthException outerException =
            authException as FirebaseAuthException;
        String errorMessage = "";
        try {
          if (outerException.code.contains('invalid-verification-code')) {
            errorMessage = (LocalKeys.INVALID_AUTH_CODE).tr();
          }
          else if (outerException.code.contains('too-many-requests')) {
            errorMessage = (LocalKeys.PHONE_NUMBER_IS_BLOCKED).tr();
          }
          else {
            errorMessage = (LocalKeys.INVALID_PHONE_NUMBER).tr();
          }
        } catch (innerException) {
          debugPrint("Exception with Firebase Login $innerException");
        }
        return ResponseViewModel<String>(
          isSuccess: false,
          serverData: null,
          serverError: ErrorViewModel(
            errorCode: 320,
            errorMessage: errorMessage,
          ),
        );
      } catch (exception) {
        debugPrint("Exception with Firebase Login $exception");
        return ResponseViewModel<String>(
          isSuccess: false,
          serverData: null,
          serverError: ErrorViewModel(
            errorCode: 320,
            errorMessage: '',
          ),
        );
      }
    }
  }

  static Future<ResponseViewModel<String>> loginWithFacebook() async {
    final facebookLogin = FacebookLogin();
    facebookLogin.logOut();

    final result = await facebookLogin.logIn(['email']);

    if (result.status == FacebookLoginStatus.loggedIn) {
      final token = result.accessToken.token;
      AuthCredential credential = FacebookAuthProvider.credential(token);
      User firebaseUser;
      try {
        firebaseUser =
            (await FirebaseAuth.instance.signInWithCredential(credential)).user;
        String userToken = (await firebaseUser.getIdToken());
        return ResponseViewModel<String>(
          serverData: userToken,
          isSuccess: true,
        );
      } catch (exception) {
        debugPrint("Exception while sign in with Twitter => $exception");
        return ResponseViewModel<String>(
          isSuccess: false,
          serverData: null,
          serverError: ErrorViewModel(
            errorCode: 320,
            errorMessage: (LocalKeys.PRIVATE_FACEBOOK).tr(),
          ),
        );
      }
    } else {
      return ResponseViewModel<String>(
        isSuccess: false,
        serverData: null,
        serverError: ErrorViewModel(
          errorCode: 320,
          errorMessage: (LocalKeys.PRIVATE_FACEBOOK).tr(),
        ),
      );
    }
  }

  static Future<ResponseViewModel<String>> loginWithApple() async {
    final AuthorizationResult result = await AppleSignIn.performRequests([
      AppleIdRequest(requestedScopes: [Scope.email, Scope.fullName])
    ]);

    switch (result.status) {
      case AuthorizationStatus.authorized:
        final appleCredentials = result.credential;
        final oAuthProvider = OAuthProvider('apple.com');
        final credential = oAuthProvider.credential(
            accessToken:
                String.fromCharCodes(appleCredentials.authorizationCode),
            idToken: String.fromCharCodes(appleCredentials.identityToken));

        User firebaseUser;
        try {
          firebaseUser =
              (await FirebaseAuth.instance.signInWithCredential(credential))
                  .user;
          String userToken = (await firebaseUser.getIdToken());
          return ResponseViewModel<String>(
            serverData: userToken,
            isSuccess: true,
          );
        } catch (exception) {
          debugPrint("Exception while sign in with Twitter => $exception");
          return ResponseViewModel<String>(
            isSuccess: false,
            serverData: null,
            serverError: ErrorViewModel(
              errorCode: 320,
              errorMessage: (LocalKeys.PRIVATE_FACEBOOK).tr(),
            ),
          );
        }
        break;
      case AuthorizationStatus.error:
        return ResponseViewModel<String>(
          isSuccess: false,
          serverData: null,
          serverError: ErrorViewModel(
            errorCode: 320,
            errorMessage: result.error.localizedDescription,
          ),
        );
        break;

      case AuthorizationStatus.cancelled:
        return ResponseViewModel<String>(
          isSuccess: false,
          serverData: null,
          serverError: ErrorViewModel(
            errorCode: 320,
            errorMessage: '',
          ),
        );
        break;
    }
    return ResponseViewModel<String>(
      isSuccess: false,
      serverData: null,
      serverError: ErrorViewModel(
        errorCode: 320,
        errorMessage: '',
      ),
    );
  }

  static Future<ResponseViewModel<String>> loginWithTwitter() async {

    var twitterLogin = new TwitterLogin(
      consumerKey: Constants.twitterCustomerKey,
      consumerSecret: Constants.twitterAppSecret,
    );

    final TwitterLoginResult result = await twitterLogin.authorize();

    switch (result.status) {
      case TwitterLoginStatus.loggedIn:
        try{
          var session = result.session;
          AuthCredential credential = TwitterAuthProvider.credential(accessToken: session.token, secret: session.secret);
          User firebaseUser = (await FirebaseAuth.instance.signInWithCredential(credential)).user;
          String userToken = (await firebaseUser.getIdToken());
          return ResponseViewModel<String>(
            isSuccess: true,
            serverData: userToken,
          );
        } catch(exception){
          return ResponseViewModel<String>(
            isSuccess: false,
            serverData: null,
            serverError: ErrorViewModel(
              errorCode: 320,
              errorMessage: (LocalKeys.TWITTER_LOGIN_ERROR).tr(),
            ),
          );
        }
        break;
      case TwitterLoginStatus.cancelledByUser:
        return ResponseViewModel<String>(
          isSuccess: false,
          serverData: null,
          serverError: ErrorViewModel(
            errorCode: HttpStatus.serviceUnavailable,
            errorMessage: (LocalKeys.TWITTER_LOGIN_ERROR).tr(),
          ),
        );
        break;
      case TwitterLoginStatus.error:
        return ResponseViewModel<String>(
          isSuccess: false,
          serverData: null,
          serverError: ErrorViewModel(
            errorCode: 320,
            errorMessage: result.errorMessage,
          ),
        );
        break;
    }
    return ResponseViewModel<String>(
      isSuccess: false,
      serverData: null,
      serverError: ErrorViewModel(
        errorCode: 320,
        errorMessage: (LocalKeys.TWITTER_LOGIN_ERROR).tr(),
      ),
    );
  }

  static getCurrentUser() async {
    User user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user;
    }
  }

  static Future<ResponseViewModel<UserViewModel>> serverLogin(
      {String socialMediaToken}) async {



    String serverLoginURL =
        URL.getURL(functionName: URL.POST_LOGIN_OR_REGISTER);
    String notificationId = await FireBaseHelper.getPushToken();

    Map<String, dynamic> loginInfo = {};
    if (notificationId != null)
      loginInfo.putIfAbsent('device_token', () => notificationId);
    Map<String, String> requestHeaders =
        await NetworkUtilities.getHttpHeaders();

    if (socialMediaToken != null)
      requestHeaders['Authorization'] = 'Bearer $socialMediaToken';

    ResponseViewModel responseViewModel =
        await NetworkUtilities.handlePostRequest(
      parserFunction: (Map<String, dynamic> loginResponse) {
        try {
          if (loginResponse.containsKey('data')){
            return UserViewModel.fromClosedJson(loginResponse);
          }
        } catch (e) {
          debugPrint(e.toString());
        }
        return UserViewModel(userToken: socialMediaToken);
      },
      requestBody: loginInfo,
      methodURL: serverLoginURL,
      requestHeaders: requestHeaders,
      acceptJson: true,
    );

    return ResponseViewModel<UserViewModel>(
      serverError: responseViewModel.serverError ?? null,
      isSuccess: responseViewModel.isSuccess,
      serverData: responseViewModel.responseData,
    );
  }

  static saveAccessToken({String userToken}) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(Constants.USER_TOKEN_PREFERENCE_KEY, userToken);
  }

  static saveUserId({String userId}) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(Constants.USER_ID_PREFERENCE_KEY, userId);
  }

  static getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(Constants.USER_TOKEN_PREFERENCE_KEY) ;
  }

  static Future<String> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(Constants.USER_ID_PREFERENCE_KEY);
  }

  static serverLogout() async {
    await removeAccessToken();
    await removeUserId();
    await FirebaseAuth.instance.signOut();
    await signInAnonymously();
    return ResponseViewModel<bool>(
      isSuccess: true,
      serverData: true,
    );
  }

  static removeAccessToken({userToken}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(Constants.USER_TOKEN_PREFERENCE_KEY);
  }

  static removeUserId({userToken}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(Constants.USER_ID_PREFERENCE_KEY);
  }

  static deleteAnonymousUser() async {
    if (FirebaseAuth.instance.currentUser.isAnonymous) {
      await FirebaseAuth.instance.currentUser.delete();
    }
  }

  static Future<ResponseViewModel<UserViewModel>> silentUserLogin() async {

    String token = await FirebaseAuth.instance.currentUser.getIdToken().timeout(Duration(seconds: 2));

    if (token != null) {
      ResponseViewModel<UserViewModel> response = await Repository.serverLogin(socialMediaToken: token);
      return ResponseViewModel<UserViewModel>(
        isSuccess: response.isSuccess,
        serverData: response.responseData,
        serverError: response.serverError,
      );
    }  else {
      return ResponseViewModel<UserViewModel>(
        isSuccess: false,
        serverData: null,
        serverError: ErrorViewModel(errorMessage: tr(LocalKeys.USER_LOGIN_ERROR), errorCode: HttpStatus.unauthorized),
      );
    }
  }
}
