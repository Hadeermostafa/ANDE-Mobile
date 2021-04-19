import 'package:ande_app/src/utilities/HelperFunctions.dart';

class PaymentMethodViewModel {
  int paymentMethodId;
  String paymentMethodName;

  @override
  String toString() {
    return 'PaymentMethodViewModel{paymentMethodId: $paymentMethodId, paymentMethodName: $paymentMethodName}';
  }

  PaymentMethodViewModel({this.paymentMethodId, this.paymentMethodName});
  static PaymentMethodViewModel fromJson(Map<String, dynamic> passedJson) {
    return PaymentMethodViewModel(
      paymentMethodId: ParseHelper.parseNumber(passedJson[PaymentMethodJsonKeys.PAYMENT_METHOD_ID]),
      paymentMethodName: passedJson[PaymentMethodJsonKeys.PAYMENT_METHOD_NAME] ?? '',
    );
  }
}

class PaymentMethodJsonKeys {
  static const PAYMENT_METHOD_ID = "id";
  static const PAYMENT_METHOD_NAME = "name";
}
