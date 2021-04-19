import 'package:ande_app/src/data_providers/models/OrderItemViewModel.dart';
import 'package:ande_app/src/resources/Constants.dart';
import 'package:ande_app/src/resources/external_resource/AndeImageNetwork.dart';
import 'package:ande_app/src/utilities/LocalKeys.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class CartItem extends StatefulWidget {
  final OrderItemViewModel orderItem;
  final String customCurrency;

  CartItem({this.orderItem, this.customCurrency});

  final kTextStyle = TextStyle(
    fontSize: 13,
    color: Colors.grey[700],
  );

  @override
  _CartItemState createState() => _CartItemState();
}

class _CartItemState extends State<CartItem> {
  @override
  Widget build(BuildContext context) {
    double totalPrice =
        widget.orderItem.calculateItemPrice() * widget.orderItem.quantity;
    return Padding(
      padding: const EdgeInsets.only(
        top: 8,
      ),
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(8),
        child: Container(
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
//                  color: Colors.grey,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(9),
                            border: Border.all(
                              color: Colors.grey[200],
                            )),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: AndeImageNetwork(
                            widget.orderItem.itemViewModel.images != null && widget.orderItem.itemViewModel.images.length > 0 ?
                            widget.orderItem.itemViewModel.images[0]: null,
                            constrained: true,
                            width: 60,
                            height: 60,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Expanded(
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: Text(
                                                widget
                                                        .orderItem
                                                        .itemViewModel.name ??
                                                    '',
                                                textScaleFactor: 1,
                                                softWrap: true,
                                                textAlign: TextAlign.start,
                                                style:
                                                    widget.kTextStyle.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: Colors.black,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Visibility(
                                              visible:
                                                  widget.orderItem.quantity > 1,
                                              child: Text(
                                                "(X ${widget.orderItem.quantity ?? ''})",
                                                style: TextStyle(
                                                    color: Colors.grey[500]),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      Visibility(
                                        replacement: Container(
                                          width: 0,
                                          height: 0,
                                        ),
                                        visible: widget.orderItem.itemViewModel
                                                .isSpicy ??
                                            false,
                                        child: Image.asset(
                                          'assets/images/spicy_icon.png',
                                          width: 15,
                                          height: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '${totalPrice.truncateToDouble().toStringAsFixed(2)} ${widget.customCurrency ?? Constants.currentRestaurantCurrency}',
                                  textAlign: TextAlign.end,
                                  textScaleFactor: 1,
                                  style: widget.kTextStyle.copyWith(
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            RichText(
                              text: TextSpan(
                                style: DefaultTextStyle.of(context).style,
                                children: <TextSpan>[
                                  TextSpan(
                                    text: '${(LocalKeys.SIZES_LABEL).tr()}: ',
                                    style: widget.kTextStyle,
                                  ),
                                  TextSpan(
                                    text:
                                        '${widget.orderItem.mealSize.name}',
                                    style: widget.kTextStyle.copyWith(
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            ...getMealExtras(),
                            Visibility(
                              visible: (widget.orderItem.userNote != null) &&
                                  (widget.orderItem.userNote.length > 0),
                              child: Text(
                                "${LocalKeys.NOTES_LABEL.tr()}:",
                                style: TextStyle(color: Colors.grey[500]),
                              ),
                            ),
                            Visibility(
                              visible: (widget.orderItem.userNote != null) &&
                                  (widget.orderItem.userNote.length > 0),
                              child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth: MediaQuery.of(context).size.width,
                                  ),
                                  child: Text(widget.orderItem.userNote ?? '')),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  getMealExtras() {
    List<String> mealExtras = [];
    List<String> mealOptions = [];

    // widget.orderItem.mealExtrasMap.forEach((k, v) {
    //   v.forEach((extra) {
    //     if (extra.isComponentExtra)
    //       mealExtras.add(extra.extraName);
    //     else
    //       mealOptions.add(extra.extraName);
    //   });
    // });

    widget.orderItem.userSelectedExtras.forEach((element) {
        mealExtras.add(element.name);
    });

    String extrasString = mealExtras.join(',');
    String optionsString = mealOptions.join(',');

    List<Widget> optionsAndExtras = [];

    // if (extrasString.length > 0) {
    //   optionsAndExtras.add(Column(
    //     mainAxisAlignment: MainAxisAlignment.start,
    //     crossAxisAlignment: CrossAxisAlignment.start,
    //     children: <Widget>[
    //       Text('${LocalKeys.EXTRAS_LABEL.tr()}: ',
    //           textScaleFactor: 1, style: widget.kTextStyle),
    //       SizedBox(
    //         height: 2.5,
    //       ),
    //       Text(
    //         extrasString,
    //         textScaleFactor: 1,
    //         style: widget.kTextStyle.copyWith(
    //           color: Colors.black,
    //         ),
    //       ),
    //     ],
    //   ));
    // }
    //
    // if (optionsString.length > 0) {
    //   optionsAndExtras.add(Column(
    //     mainAxisAlignment: MainAxisAlignment.start,
    //     crossAxisAlignment: CrossAxisAlignment.start,
    //     children: <Widget>[
    //       Text('${LocalKeys.OPTIONS_LABEL.tr()}: ',
    //           textScaleFactor: 1, style: widget.kTextStyle),
    //       SizedBox(
    //         height: 2.5,
    //       ),
    //       Text(
    //         optionsString,
    //         textScaleFactor: 1,
    //         style: widget.kTextStyle.copyWith(
    //           color: Colors.black,
    //         ),
    //       ),
    //     ],
    //   ));
    // }

    return optionsAndExtras;
  }
}
