import 'package:ande_app/src/blocs/bloc/UserBloc.dart';
import 'package:ande_app/src/resources/external_resource/phone_input/international_phone_input.dart';
import 'package:ande_app/src/utilities/LocalKeys.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:modal_progress_hud/modal_progress_hud.dart';

import '../../../main.dart';
import '../../blocs/bloc/LoginBloc.dart';
import '../../blocs/events/LoginEvents.dart';
import '../../blocs/states/LoginStates.dart';

class PhoneAuthenticationDialog extends StatefulWidget {
  PhoneAuthenticationDialog({this.loginBloc});
  final List<String> supportedCountriesCodes = ['+20', '+966'];

  final LoginBloc loginBloc;

  @override
  _PhoneAuthenticationDialogState createState() =>
      _PhoneAuthenticationDialogState();
}

class _PhoneAuthenticationDialogState extends State<PhoneAuthenticationDialog> {
  TextEditingController _phoneNumberController, _smsCodeController;
  LoginBloc _loginBloc;
  bool shouldEnterCode = false, hasError = false;
  var _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _phoneNumberController = TextEditingController();
    _smsCodeController = TextEditingController();
    this._loginBloc = widget.loginBloc;

    if (BlocProvider.of<UserBloc>(context).userCountry != null &&
        BlocProvider.of<UserBloc>(context).userCountry.countryDialCode != null) {
      String userCountryCode =
          BlocProvider.of<UserBloc>(context).userCountry.countryDialCode;
      if (widget.supportedCountriesCodes.contains(userCountryCode)) {
        phoneIsoCode = userCountryCode;
      }
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer(
      listener: (context, state) {},
      bloc: _loginBloc,
      builder: (context, state) {
        return ModalProgressHUD(
          progressIndicator: loadingFlare,
          inAsyncCall: state is LoginLoading,
          child: Dialog(
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: dialogContent(context),
          ),
        );
      },
    );
  }

  dialogContent(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(
            height: 20,
          ),
          StreamBuilder<String>(
            stream: _loginBloc.phoneAuthStream,
            builder: (context, snapshot){
              if (snapshot.hasData == false || snapshot.data == null) {
                return Text(
                  (LocalKeys.PHONE_AUTH_DIALOG_TITLE).tr(),
                  textScaleFactor: 1,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    // fontFamily: Constants.FONT_MONTSERRAT_ARIAL,
                  ),
                );
              } else {
                return Text(
                  (LocalKeys.VERIFICATION_CODE_HINT).tr(),
                  textScaleFactor: 1,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    // fontFamily: Constants.FONT_MONTSERRAT_ARIAL,
                  ),
                );
              }
            },
          ),
          SizedBox(
            height: 20,
          ),
          Divider(
            height: 1,
            color: Colors.black,
          ),
          SizedBox(
            height: 10,
          ),
          StreamBuilder<String>(
              stream: _loginBloc.phoneAuthStream,
              builder: (context, snapshot) {
                if (snapshot.hasData == false || snapshot.data == null) {
                  return getPhoneAuthForm(context);
                } else {
                  return getOldValidationForm(context);
                }
              })
        ],
      ),
    );
  }

  getOldValidationForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Form(
          key: _formKey,
          child: TextFormField(
            key: Key('code'),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp("[0-9]"))
            ],
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: InputDecoration(
              focusedBorder: UnderlineInputBorder(),
              labelText: (LocalKeys.VERIFICATION_CODE_HINT).tr(),
            ),
            controller: _smsCodeController,
            validator: (text) {
              return (text.length == 0) ? 'Please Enter the sms code' : null;
            },
          ),
        ),
        FlatButton(
          onPressed: () {
            if (_formKey.currentState.validate()) {
              _loginBloc.add(PerformLogin(
                loginMethod: LoginMethods.PHONE,
                smsCode: _smsCodeController.text,
              ));
            }
          },
          child: Text(
            (LocalKeys.VERIFY_PHONE_BUTTON).tr(),
            textScaleFactor: 1,
            key: Key('sendcode'),
          ),
        ),
      ],
    );
  }

  getPhoneAuthForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Form(
          key: _formKey,
          child: Container(
            key: Key("inputphone"),
            child: InternationalPhoneInput(
              errorText: (LocalKeys.INVALID_PHONE_FORMAT).tr(),
              onPhoneNumberChange: onPhoneNumberChange,
              initialPhoneNumber: phoneNumber,
              initialSelection: phoneIsoCode,
              enabledCountries: widget.supportedCountriesCodes,
            ),
          ),
        ),
        //   InternationalNumberWidget(),
        FlatButton(
          key: Key('verify'),
          onPressed: () {
            if (_formKey.currentState.validate() &&
                (phoneNumber != null && phoneNumber.length > 0)) {
              _loginBloc.add(RequestPhoneAuthCode(userPhone: phoneNumber));
              setState(() {});
            }
          },
          child: Text(
            (LocalKeys.VERIFY_PHONE_BUTTON).tr(),
            textScaleFactor: 1,
          ).tr(),
        ),
      ],
    );
  }

  String phoneNumber;
  String phoneIsoCode = '+966';

  void onPhoneNumberChange(
      String number, String internationalizedPhoneNumber, String isoCode) {
    setState(() {
      phoneNumber = internationalizedPhoneNumber;
      phoneIsoCode = isoCode;
    });
  }
}
