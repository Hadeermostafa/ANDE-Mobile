import 'package:firebase_auth/firebase_auth.dart';

import '../states/LoginStates.dart';

abstract class LoginEvents {}

enum LoginMethods { ANONYMOUS, GOOGLE, FACEBOOK, PHONE, TWITTER, APPLE }

class PerformLogin extends LoginEvents {
  final LoginMethods loginMethod;
  final AuthCredential authCredentials;
  final String smsCode;

  PerformLogin({
    this.loginMethod,
    this.authCredentials,
    this.smsCode,
  });
}

class RequestPhoneAuthCode extends LoginEvents {
  final String userPhone;
  RequestPhoneAuthCode({this.userPhone});
}

class CodeRequestFinished extends LoginEvents {
  final LoginStates afterRequestState;
  CodeRequestFinished({this.afterRequestState});
}
