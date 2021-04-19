
import 'package:ande_app/src/data_providers/models/ResponseModel.dart';
import 'package:ande_app/src/data_providers/models/UserViewModel.dart';
import 'package:ande_app/src/resources/Constants.dart';
import 'package:ande_app/src/resources/Repository.dart';
import 'package:ande_app/src/utilities/NetworkUtilities.dart';
import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../events/AuthenticationEvents.dart';
import '../states/AuthenticationStates.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvents, AuthenticationStates> {
  @override
  AuthenticationStates get initialState => UserUnInitialized();

  @override
  Stream<AuthenticationStates> mapEventToState(
      AuthenticationEvents event) async* {
    bool isConnected = await NetworkUtilities.isConnected();
    if (isConnected == false) {
      yield UserAuthenticationFailed(error: Constants.connectionTimeoutException, event: event);
      return;
    }

    if (event is AppStart) {
      yield UserAuthenticating();
      if(FirebaseAuth.instance.currentUser != null) {
        ResponseViewModel<UserViewModel> loginResult = await Repository.silentUserLogin();
        if (loginResult.isSuccess) {
          await Repository.saveAccessToken(loginResult.responseData.userToken);
          yield UserAuthenticated(userToken: loginResult.responseData.userToken);
          try {
            await Repository.saveUserId(loginResult.responseData.userId);
          } catch (e) {
            debugPrint(e.toString());
          }
          yield UserAuthenticated(userToken: loginResult.responseData.userToken);
          return;
        }
        else {
          yield* _loginAnonymously(event);
          return;
        }
      }
      else {
        yield* _loginAnonymously(event);
        return;
      }
    }
     else if (event is Logout) {
      yield UserAuthenticating();
      await Repository.serverLogout();
      yield UserUnInitialized();
      return;
    } else if (event is Login) {
      yield UserAuthenticated(userToken: event.userToken);
      return;
    }
  }

  Stream<AuthenticationStates> _loginAnonymously(AppStart event) async* {
    ResponseViewModel<User> userResponse = await Repository.loginAnonymously();
    if(userResponse.isSuccess){
      String userToken = (await userResponse.responseData.getIdToken());
      yield UserAuthenticated(userToken: userToken);
      return;
    } else {
      yield UserAuthenticationFailed(event: event , error: userResponse.serverError);
      return;
    }
  }
}
