import 'package:flutter/foundation.dart';

class ErrorViewModel {
  final String errorMessage;
  final int errorCode;
  ErrorViewModel({@required this.errorMessage, this.errorCode});

  @override
  String toString() {
    return 'ErrorViewModel{errorMessage: $errorMessage, errorCode: $errorCode}';
  }
}
