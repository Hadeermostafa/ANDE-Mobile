import 'package:ande_app/src/data_providers/models/OrderItemViewModel.dart';
import 'package:ande_app/src/resources/external_resource/AndeImageNetwork.dart';
import 'package:ande_app/src/ui/widgets/HelperWidgets.dart';
import 'package:ande_app/src/utilities/HelperFunctions.dart';
import 'package:ande_app/src/utilities/LocalKeys.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../resources/Constants.dart';

class ViewOrderItemTile extends StatelessWidget {
  final kTextStyle = TextStyle(
    fontSize: 13,
    color: Color(0xffD1D1D1),
  );

  double totalPrice = 0.0;

  final OrderItemViewModel orderViewModel;
  final double restaurantTaxes, restaurantService;

  ViewOrderItemTile({
    this.orderViewModel,
    this.restaurantTaxes,
    this.restaurantService,
  });

  @override
  Widget build(BuildContext context) {
    totalPrice = orderViewModel.calculateItemPrice() * orderViewModel.quantity;
    String imageUrl;
    try {
      imageUrl = orderViewModel.itemViewModel.images[0];
    } catch(exception){
      debugPrint(exception.toString());
      imageUrl = '';
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Container(
        child: Material(
          shape: Border(
              bottom: BorderSide(
                color: Colors.black.withOpacity(.09),
              ),
              top: BorderSide(
                color: Colors.black.withOpacity(.09),
              )),
          shadowColor: Colors.black.withOpacity(.2),
          color: Colors.white,
          child: Stack(
            children: <Widget>[
              Positioned.directional(
                top: 8,
                end: 10,
                textDirection: DirectionalityHelper.getDirectionalityForLocale(
                    context, Locale(Constants.currentAppLocale)),
                child: Container(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    padding: EdgeInsets.all(6.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        width: 1,
                        color: Colors.grey[400],
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: orderViewModel.itemStatues.stateColor,
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          EasyLocalization.of(context).locale.languageCode ==
                                  'en'
                              ? orderViewModel.itemStatues.stateNameEn
                              : orderViewModel.itemStatues.stateNameAr,
                          textScaleFactor: 1,
                          style: TextStyle(
                            color: Color(0xffc4c4c4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: <Widget>[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: Colors.grey[200],
                                  )),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: AndeImageNetwork(
                                    imageUrl,
                                    constrained: true,
                                ),
                              ),
                            ),
                            HelperWidget.horizontalSpacer(widthVal: 10),
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Expanded(
                                        child: Padding(
                                          padding:
                                              const EdgeInsetsDirectional.only(
                                                  end: 90),
                                          child: Row(
                                            children: <Widget>[
                                              Text(
                                                orderViewModel
                                                    .itemViewModel
                                                    .name,
                                                textScaleFactor: 1,
                                                textAlign: TextAlign.start,
                                                style: kTextStyle.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: Colors.black,
                                                ),
                                                maxLines: 2,
                                                overflow:
                                                    TextOverflow.ellipsis,
                                              ),
                                              Visibility(
                                                visible: orderViewModel
                                                        .itemViewModel
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
                                      ),
                                    ],
                                  ),
                                  HelperWidget.verticalSpacer(heightVal: 8),
                                  Text(
                                    orderViewModel.itemViewModel.description ?? '',
                                    maxLines: 2,
                                    textScaleFactor: 1,
                                    style: kTextStyle.copyWith(
                                      color: Colors.black,
                                    ),
                                  ),
                                  HelperWidget.verticalSpacer(heightVal: 5),
                                  RichText(
                                    text: TextSpan(
                                      style: DefaultTextStyle.of(context).style,
                                      children: <TextSpan>[
                                        TextSpan(
                                          text:
                                              '${(LocalKeys.SIZES_LABEL).tr()}: ',
                                          style: kTextStyle,
                                        ),
                                        TextSpan(
                                            text:
                                                '${orderViewModel.mealSize.name}',
                                            style: kTextStyle.copyWith(
                                                color: Colors.black)),
                                      ],
                                    ),
                                  ),
                                  HelperWidget.verticalSpacer(heightVal: 5),
                                  ...getMealExtras(context),
                                  Visibility(
                                    visible: orderViewModel.userNote != null &&
                                        orderViewModel.userNote.length > 0,
                                    child: Text(
                                      orderViewModel.userNote ?? '',
                                      textScaleFactor: 1,
                                    ),
                                    replacement: Container(
                                      width: 0,
                                      height: 0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  HelperWidget.verticalSpacer(heightVal: 5),
                  HelperWidget.horizontalDashedLine(
                    dashesColor: Colors.grey[200],
                    dashesWith: 8,
                    dashesLength: 30,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  getMealExtras(context) {
    List<String> mealExtras = [];

    if(orderViewModel.userSelectedExtras != null) {
      orderViewModel.userSelectedExtras.forEach((element) {
        mealExtras.add(element.name);
      });
    }

    String extrasString = mealExtras.join(',');

    List<Widget> optionsAndExtras = [];

    if (extrasString.length > 0) {
      optionsAndExtras.add(Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('${(LocalKeys.EXTRAS_LABEL).tr()}: ',
              textScaleFactor: 1, style: kTextStyle),
          SizedBox(
            height: 2.5,
          ),
          Text(
            extrasString,
            textScaleFactor: 1,
            style: kTextStyle.copyWith(
              color: Colors.black,
            ),
          ),
        ],
      ));
    }
    return optionsAndExtras;
  }
}
