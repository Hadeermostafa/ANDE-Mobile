import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
class BlocLoggerDelegate extends BlocDelegate {
  @override
  void onEvent(Bloc bloc, Object event) {
    debugPrint("*****************************************");
    debugPrint("Bloc => $bloc dispatched event => $event");
    debugPrint("*****************************************");
    super.onEvent(bloc, event);
  }

  @override
  void onError(Bloc bloc, Object error, StackTrace stacktrace) {
    super.onError(bloc, error, stacktrace);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
  }
}
