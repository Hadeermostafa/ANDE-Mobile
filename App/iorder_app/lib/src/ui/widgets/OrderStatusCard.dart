import 'package:ande_app/src/resources/Constants.dart';
import 'package:ande_app/src/utilities/LocalKeys.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../data_providers/models/OrderViewModel.dart';

class OrderStatusWidget extends StatefulWidget {
  final double _width;
  final List<ORDER_STATUES> _statues;
  final List<String> _titles;
  final int _curStep;

  OrderStatusWidget(
      {Key key,
      @required List<ORDER_STATUES> statues,
      @required int curStep,
      List<String> titles,
      @required double width,
      @required Color color})
      : _statues = statues,
        _titles = titles,
        _curStep = curStep,
        _width = width,
        assert(width > 0),
        super(key: key);

  @override
  _OrderStatusWidgetState createState() => _OrderStatusWidgetState();
}

class _OrderStatusWidgetState extends State<OrderStatusWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.transparent,
        padding: EdgeInsets.only(
          top: 24.0,
          bottom: 14.0,
          left: 24.0,
          right: 24.0,
        ),
        width: widget._width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _statusView(),
        ));
  }

  List<Widget> _statusView() {
    var list = <Widget>[];
    widget._statues.asMap().forEach((i, icon) {
      list.add(Stack(
        alignment: Alignment.center,
        overflow: Overflow.visible,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  spreadRadius: .5,
                  blurRadius: 20,
                  color: Colors.black45.withOpacity(.2),
                ),
              ],
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(10),
            ),
            width: widget._curStep == i
                ? (MediaQuery.of(context).size.width) / widget._statues.length
                : (MediaQuery.of(context).size.width - 100) /
                    widget._statues.length,
            height: Constants.currentAppLocale == 'en' ? 100 : 110,
            child: Padding(
              padding: widget._curStep == i
                  ? EdgeInsets.only(top: 30)
                  : EdgeInsets.only(top: 50),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  widget._statues[i] == ORDER_STATUES.PENDING
                      ? Text(
                          LocalKeys.PENDING,
                          textAlign: TextAlign.center,
                        ).tr()
                      : widget._statues[i] == ORDER_STATUES.CONFIRMED
                          ? Text(
                              LocalKeys.CONFIRMED,
                              textAlign: TextAlign.center,
                            ).tr()
                          : widget._statues[i] == ORDER_STATUES.ON_ITS_WAY
                              ? Text(
                                  LocalKeys.ON_ITS_WAY,
                                  textAlign: TextAlign.center,
                                ).tr()
                              : Text(
                                  LocalKeys.DELIVERED,
                                  textAlign: TextAlign.center,
                                ).tr(),
                  Visibility(
                    visible: (widget._curStep == i) &&
                        (widget._statues[i] == ORDER_STATUES.CONFIRMED),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                          maxWidth: (MediaQuery.of(context).size.width) /
                                  widget._statues.length -
                              20),
                      child: Text(
                        LocalKeys.CURRENT_STATUS_HINT_TEXT,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ).tr(),
                    ),
                  )
                ],
              ),
            ),
          ),
          Positioned(
            top: i == widget._curStep ? -25 : 15,
            right: widget._curStep == i
                ? ((MediaQuery.of(context).size.width) /
                        (widget._statues.length * 2)) -
                    29
                : ((MediaQuery.of(context).size.width - 100) /
                        (widget._statues.length * 2)) -
                    22,
            child: Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                  color: widget._curStep == i
                      ? Colors.white
                      : widget._curStep > i
                          ? Color(0xffF1F8E3)
                          : Color(0xffF8F8F8),
                  borderRadius: BorderRadius.circular(30)),
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Image(
                    image: widget._curStep > i
                        ? AssetImage(LocalKeys.COMPLETED_BACKGROUND)
                        : widget._curStep == i
                            ? AssetImage(LocalKeys.PROCESSING_BACKGROUND)
                            : AssetImage(LocalKeys.PENDING_BACKGROUND),
                    width: widget._curStep == i ? 50 : 35,
                    height: widget._curStep == i ? 50 : 35,
                    fit: BoxFit.fill,
                  ),
                  Visibility(
                    visible: i >= widget._curStep,
                    child: Text(
                      "${i + 1}",
                      style: TextStyle(
                          color: i == widget._curStep
                              ? Colors.white
                              : Colors.black26),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Visibility(
            visible: widget._curStep == i,
            child: Positioned(
              bottom: -11,
              right: ((MediaQuery.of(context).size.width - 100) /
                  (widget._statues.length * 2)),
              child: CustomPaint(
                size: Size(20, 10),
                painter: TrianglePainter(color: Colors.grey[50]),
              ),
            ),
          )
        ],
      ));
    });

    return list;
  }

  List<Widget> _titleViews() {
    var list = <Widget>[];
    widget._titles.asMap().forEach((i, text) {
      list.add(Text(
        text,
      ));
    });
    return list;
  }
}

class TrianglePainter extends CustomPainter {
  bool isDown;
  Color color;

  TrianglePainter({this.isDown = true, this.color});

  @override
  void paint(Canvas canvas, Size size) {
    Paint _paint = new Paint();
    _paint.strokeWidth = 2.0;
    _paint.color = color;
    _paint.style = PaintingStyle.fill;

    Path path = new Path();
    if (isDown) {
      path.moveTo(0.0, -1.0);
      path.lineTo(size.width, -1.0);
      path.lineTo(size.width / 2.0, size.height);
    } else {
      path.moveTo(size.width / 2.0, 0.0);
      path.lineTo(0.0, size.height + 1);
      path.lineTo(size.width, size.height + 1);
    }

    canvas.drawPath(path, _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
