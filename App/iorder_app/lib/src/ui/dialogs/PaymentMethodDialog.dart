import 'package:ande_app/src/utilities/LocalKeys.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../data_providers/models/PaymentMethodViewModel.dart';
import '../../resources/external_resource/RadioButtonListTile.dart';

class PaymentMethodDialog extends StatefulWidget {
  final PaymentMethodViewModel initialPaymentMethod;
  final Function paymentMethodSelected;
  final List<PaymentMethodViewModel> restaurantSupportedPaymentMethods;

  PaymentMethodDialog(
      {this.initialPaymentMethod,
      this.paymentMethodSelected,
      this.restaurantSupportedPaymentMethods});

  @override
  _PaymentMethodDialogState createState() => _PaymentMethodDialogState();
}

class _PaymentMethodDialogState extends State<PaymentMethodDialog> {
  PaymentMethodViewModel paymentMethod;

  @override
  void initState() {
    paymentMethod = widget.initialPaymentMethod;

    if (widget.initialPaymentMethod == null) {
      paymentMethod = widget.restaurantSupportedPaymentMethods[0];
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      elevation: 5,
      contentPadding: EdgeInsets.symmetric(horizontal: 10),
      backgroundColor: Colors.white,
      title: Text(
        (LocalKeys.PAYMENT_METHOD).tr(),
        textScaleFactor: 1,
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: getPaymentMethodsAsList(),
            ),
          ),
          SizedBox(
            height: 5,
          ),
        ],
      ),
    );
  }

  getPaymentMethodsAsList() {
    List<Widget> widgetsList = List();

    for (int i = 0; i < widget.restaurantSupportedPaymentMethods.length; i++)
      widgetsList.add(
        SizedBox(
          height: 30,
          child: GestureDetector(
            onTap: (){
              widget.paymentMethodSelected(paymentMethod);
            },
            child: RadioButtonListTile(
              key: GlobalKey(),
              dense: false,
              title: Text(
                widget.restaurantSupportedPaymentMethods[i].paymentMethodName,
                textScaleFactor: 1,
              ),
              value: widget.restaurantSupportedPaymentMethods[i],
              groupValue: paymentMethod,
              activeColor: Colors.grey[900],
              onChanged: (val) {
                setState(() {
                  paymentMethod = val;
                });
              },
            ),
          ),
        ),
      );
    return widgetsList;
  }
}
