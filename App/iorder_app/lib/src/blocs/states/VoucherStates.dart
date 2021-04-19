import 'package:ande_app/src/blocs/events/VoucherEvents.dart';
import 'package:ande_app/src/data_providers/models/ErrorViewModel.dart';

abstract class VoucherStates {}
class InvalidVoucherState extends VoucherStates {
  final String voucherName;
  InvalidVoucherState({this.voucherName});
}
class ValidVoucherState extends VoucherStates {
  final double discountValue;
  final String voucherName;
  ValidVoucherState({this.discountValue, this.voucherName});
}
class VoucherLoadingError extends VoucherStates{
  final VoucherEvents event ;
  final ErrorViewModel error ;
  VoucherLoadingError({this.event , this.error});

}
class InitialVoucherState extends VoucherStates {}
class VoucherLoadingState extends VoucherStates {}
