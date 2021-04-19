
import 'package:ande_app/src/resources/Constants.dart';
import 'package:ande_app/src/utilities/NetworkUtilities.dart';
import 'package:bloc/bloc.dart';
import 'package:ande_app/src/blocs/events/VoucherEvents.dart';
import 'package:ande_app/src/blocs/states/VoucherStates.dart';



class VoucherBloc extends Bloc<VoucherEvents, VoucherStates> {
  @override
  VoucherStates get initialState => InitialVoucherState();

  @override
  Stream<VoucherStates> mapEventToState(VoucherEvents event) async* {


    bool isConnected = await NetworkUtilities.isConnected();
    if (isConnected == false) {
      yield VoucherLoadingError(event: event, error: Constants.connectionTimeoutException);

      return;
    }




    if (event is CheckVoucher) {
      yield VoucherLoadingState();
      String inputVoucher = event.voucherCode;
      double voucherValue = 8.0;
      //await DummyDataRepository.validateVoucherCode(inputVoucher);
      if (voucherValue == null) {
        yield InvalidVoucherState(voucherName: inputVoucher);
      } else {
        yield ValidVoucherState(
            discountValue: voucherValue, voucherName: inputVoucher);
      }
      return;
    } else if (event is RemoveVoucher) {
      yield InitialVoucherState();
      return;
    }
  }
}
