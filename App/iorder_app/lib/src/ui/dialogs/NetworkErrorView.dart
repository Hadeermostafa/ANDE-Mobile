import 'package:flutter/material.dart';

class NetworkErrorView extends StatefulWidget {
  @override
  _NetworkErrorViewState createState() => _NetworkErrorViewState();
}

class _NetworkErrorViewState extends State<NetworkErrorView>
    with TickerProviderStateMixin {
  AnimationController _animController, _colorController;
  var opacityAnimation, colorAnimation;

  Animatable<Color> background = TweenSequence<Color>(
    [
      TweenSequenceItem(
        weight: 1.0,
        tween: ColorTween(
          begin: Colors.white,
          end: Colors.red,
        ),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }

  @override
  void initState() {
    _animController =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    _colorController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 100))
          ..repeat();
    opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_animController);

    _animController.addStatusListener((statues) {
      if (statues == AnimationStatus.completed)
        _animController.reverse();
      else if (statues == AnimationStatus.dismissed) _animController.forward();
    });

    _animController.forward();

    super.initState();
  }

  dialogContent(BuildContext context) {
    return FadeTransition(
      opacity: opacityAnimation,
      child: Container(
        width: 45,
        height: 45,
        color: Colors.transparent,
        child: AnimatedBuilder(
          animation: _colorController,
          builder: (context, child) => Image.asset(
            'assets/images/connection_error.png',
            color: background
                .evaluate(AlwaysStoppedAnimation(_colorController.value)),
            fit: BoxFit.scaleDown,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    _colorController.dispose();
    super.dispose();
  }
}
