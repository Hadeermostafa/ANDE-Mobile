import 'package:flutter/cupertino.dart';

abstract class AuthenticationEvents {}

class AppStart extends AuthenticationEvents {
  BuildContext context;
  AppStart({this.context});
}

class Login extends AuthenticationEvents {
  final String userToken;
  Login({this.userToken});
}

class Logout extends AuthenticationEvents {}
