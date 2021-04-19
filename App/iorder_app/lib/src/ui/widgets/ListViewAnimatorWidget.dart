import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class ListViewAnimatorWidget extends StatelessWidget {

  final GlobalKey listKey;
  final List<Widget> listChildrenWidgets ;
  final bool isScrollEnabled;
  final ScrollController scrollController;
  final Widget placeHolder ;
  final int delay;
  ListViewAnimatorWidget({this.listChildrenWidgets , this.placeHolder ,this.scrollController , this.isScrollEnabled, this.listKey, this.delay});

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: listChildrenWidgets != null && listChildrenWidgets.length > 0,
      replacement: Center(child: Container(
        child: placeHolder,
      )),
      child: AnimationLimiter(
        key: GlobalKey(),
        child: ListView.builder(
          key: listKey ?? GlobalKey(),
          controller: scrollController,
          physics: isScrollEnabled ?? true ? BouncingScrollPhysics() : NeverScrollableScrollPhysics(),
          itemCount: listChildrenWidgets.length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return AnimationConfiguration.staggeredList(
              delay: Duration(milliseconds: delay ?? 250),
              position: index,
              duration:  Duration(
                  milliseconds: delay ?? 700),
              child: SlideAnimation(
                horizontalOffset: 200.0,
                child: FadeInAnimation(
                  child: listChildrenWidgets[index],
                ),
              ),
            );
          },
        ),
      ),
    );



  }



}
