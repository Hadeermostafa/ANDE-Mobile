import 'dart:core';

import 'package:ande_app/src/data_providers/models/NotificationObjectModel.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class NotificationEvents {}

class OnNotificationReceived extends NotificationEvents {
  final RemoteMessage notification;
  OnNotificationReceived({this.notification});
}

class NotificationHandled extends NotificationEvents {}

abstract class NotificationStates {}

class NewNotificationState extends NotificationStates {
  final NotificationObjectModel notification;
  NewNotificationState({this.notification});
}

class NoNotificationInStack extends NotificationStates {}

class NotificationBloc extends Bloc<NotificationEvents, NotificationStates> {
  @override
  NotificationStates get initialState => NoNotificationInStack();

  @override
  Stream<NotificationStates> mapEventToState(NotificationEvents event) async* {
    if (event is OnNotificationReceived) {
      yield NewNotificationState(
          notification: NotificationObjectModel.fromJson(event.notification));
      return;
    } else if (event is NotificationHandled) {
      yield NoNotificationInStack();
      return;
    }
  }
}
