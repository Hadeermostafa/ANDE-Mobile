import 'package:ande_app/src/data_providers/models/OrderViewModel.dart';
import 'package:ande_app/src/ui/dialogs/AndeRatingDialog.dart';
import 'package:ande_app/src/utilities/HelperFunctions.dart';
import 'package:ande_app/src/utilities/LocalKeys.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class HistoryOrderTile extends StatefulWidget {
  final OrderViewModel orderViewModel;
  final Function onPressed;

  HistoryOrderTile({@required this.orderViewModel, @required this.onPressed});

  @override
  _HistoryOrderTileState createState() => _HistoryOrderTileState();
}

class _HistoryOrderTileState extends State<HistoryOrderTile> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: widget.onPressed,
      child: Container(
        width: size.width,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              spreadRadius: 0.0002,
              blurRadius: 3,
            ),
          ]
        ),
        child: Card(
          elevation: 0.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: ImageHelper.getImage(widget
                      .orderViewModel
                      .restaurantViewModel
                      .restaurantListViewModel
                      .restaurantImagePath),
                ),
                SizedBox(
                  width: size.width * 0.05,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(widget.orderViewModel.restaurantViewModel
                          .restaurantListViewModel.restaurantName
                          .toString(),
                            style: TextStyle(color: Color(0xFF333333),
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                      Text(
                        widget.orderViewModel.getAllOrderMealsTitles(),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        softWrap: false,
                        textAlign: TextAlign.start,
                        style: TextStyle(color: Color(0xFF8e8e8e)),
                      ),
                      SizedBox(
                        height: 5.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${tr(LocalKeys.TOTAL_LABEL)}: ${(widget.orderViewModel.totalPrice - (widget.orderViewModel.promoCodeViewModel.discountValue ?? 0.0)).toStringAsFixed(2)} ${ widget.orderViewModel.restaurantViewModel.restaurantCurrency.currencyName ?? ''}',
                            style: TextStyle(
                                color: Color(0xFF2b9100),
                                fontWeight: FontWeight.bold),
                          ),
                          Visibility(
                            visible: false,
                            replacement: Container(height: 0.0, width: 0.0,),
                            child: GestureDetector(
                              onTap: () async {
                                await showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) {
                                    return AndeRatingsDialog();
                                  },
                                );
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(tr(LocalKeys.ADD_RATE)),
                                  Icon(Icons.star_border),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 5.0,
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
}
