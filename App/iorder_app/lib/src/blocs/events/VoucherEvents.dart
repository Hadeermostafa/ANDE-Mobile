abstract class VoucherEvents {}

class CheckVoucher extends VoucherEvents {
  final String voucherCode;
  CheckVoucher({this.voucherCode});
}
class RemoveVoucher extends VoucherEvents {}
