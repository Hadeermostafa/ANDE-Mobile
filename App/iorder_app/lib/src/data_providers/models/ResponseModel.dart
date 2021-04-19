import 'ErrorViewModel.dart';

class ResponseViewModel<T> {
  T responseData;
  ErrorViewModel serverError;
  bool isSuccess;

  @override
  String toString() {
    return 'ResponseViewModel{responseData: $responseData, serverError: $serverError, isSuccess: $isSuccess}';
  }

  ResponseViewModel({serverData, this.serverError, this.isSuccess}) {
    this.responseData = serverData;
  }
}
