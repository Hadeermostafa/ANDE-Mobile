import 'package:ande_app/src/data_providers/models/OrderItemViewModel.dart';
import 'package:ande_app/src/utilities/LocalKeys.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../resources/Constants.dart';

class ProductCustomizationClosedStateTile extends StatelessWidget {
  final OrderItemViewModel orderItemViewModel;
  final Function onItemClicked, onItemRemoveClicked;
  final int itemIndex;
  final bool shouldAnimate;
  final double sectionPadding = 10.0, headerPadding = 5.0;

  ProductCustomizationClosedStateTile(
      {this.orderItemViewModel,
        this.onItemClicked,
        this.shouldAnimate,
        this.onItemRemoveClicked,
        this.itemIndex});
  final headerStyle = TextStyle(
    color: Colors.grey[400],
    fontSize: 12,
  );

  final infoStyle = TextStyle(
    color: Colors.black,
    fontSize: 14,
  );

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(seconds: shouldAnimate ? 5 : 0),
      padding: EdgeInsets.symmetric(vertical: 4.0),
      child: GestureDetector(
        onTap: () {
          onItemClicked(itemIndex);
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey[200],
            ),
            color: Colors.white,
          ),
          child: Padding(
            padding: const EdgeInsets.all(0.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        // (LocalKeys.CUSTOMIZE_ITEM_LABEL).tr(),
                        orderItemViewModel.itemViewModel.name,
                        style: TextStyle(
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[400],
                        ),
                        child: Center(
                          child: FittedBox(
                            child: Text(
                              (itemIndex + 1).toString(),
                              textScaleFactor: 0.8,
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        replacement: Container(
                          width: 0,
                          height: 0,
                        ),
                        visible: onItemRemoveClicked != null,
                        child: Expanded(
                          child: Align(
                            alignment: AlignmentDirectional.centerEnd,
                            child: Padding(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 0),
                              child: Container(
                                width: 25,
                                height: 25,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Constants.mainThemeColor,
                                ),
                                child: Center(
                                  child: IconButton(
                                    padding:
                                    EdgeInsets.symmetric(horizontal: 0),
                                    icon: Icon(
                                      Icons.remove,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      onItemRemoveClicked(itemIndex);
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Divider(
                  color: Colors.grey[400],
                  height: 1,
                  indent: 0,
                ),
                SizedBox(
                  height: 10,
                ),
                Visibility(
                  visible: orderItemViewModel.mealSize != null &&
                      orderItemViewModel.mealSize?.name != null &&
                      orderItemViewModel.mealSize.name.length > 0,
                  replacement: Container(
                    height: 0,
                    width: 0,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: RichText(
                      text: TextSpan(children: [
                        TextSpan(
                          text: '${(LocalKeys.SIZES_LABEL).tr()}: ',
                          style: infoStyle.copyWith(
                            fontSize: 13,
                          ),
                        ),
                        TextSpan(
                          text: orderItemViewModel.mealSize?.name ??
                              (LocalKeys.NOT_SET_LABEL).tr(),
                          style: infoStyle.copyWith(
                            fontSize: 13,
                          ),
                        ),
                      ]),
                    ),
                  ),
                ),


                Visibility(
                  visible: orderItemViewModel.userSelectedExtras != null && orderItemViewModel.userSelectedExtras.length > 0,
                  replacement: Container(width: 0, height: 0,),
                  child: buildSection(context,
                      sectionHeaderName: (LocalKeys.EXTRAS_LABEL).tr(),
                      sectionValue: getExtrasList(context)),
                ),


                Visibility(
                  replacement: Container(width: 0, height: 0,),
                  visible: orderItemViewModel.userNote != null && orderItemViewModel.userNote.isNotEmpty,
                  child: buildSection(context,
                      sectionHeaderName: (LocalKeys.NOTES_LABEL).tr(),
                      sectionValue: orderItemViewModel.userNote != null
                          ? orderItemViewModel.userNote.length > 0
                          ? orderItemViewModel.userNote
                          : ''
                          : (LocalKeys.NOT_SET_LABEL).tr()),
                ),
                SizedBox(
                  height: sectionPadding,
                ),
                Divider(
                  color: Colors.grey[400],
                  height: 1,
                  indent: 0,
                ),
                SizedBox(
                  height: 5,
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Text(
                        tr(LocalKeys.ITEM_PRICE_LABEL),
                        style: infoStyle.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${orderItemViewModel.calculateItemPrice().toString()} ${(Constants.currentRestaurantCurrency)}',
                        style: infoStyle.copyWith(
                          color: Colors.green,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String getExtrasList(context) {
    String extras = "";

    List<String> extrasNames = [];

    if(orderItemViewModel.userSelectedExtras != null) {
      orderItemViewModel.userSelectedExtras.forEach((element) {
        extrasNames.add(element.name);
      });
      extras += "(${extrasNames.join(',')})";
    }

    if (extras == null || extras.length == 0)
      extras = (LocalKeys.NOT_SET_LABEL).tr();

    return extras;
  }

  Widget buildSection(context,
      {String sectionHeaderName, String sectionValue}) {
    if (sectionValue == (LocalKeys.NOT_SET_LABEL).tr()) {
      return Container(
        width: 0,
        height: 0,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: sectionPadding,
          ),
          Text(
            sectionHeaderName ?? '',
            style: headerStyle,
          ),
          SizedBox(
            height: headerPadding,
          ),
          Text(
            sectionValue ?? '',
            maxLines: 4,
            style: infoStyle,
          ),
        ],
      ),
    );
  }
}
