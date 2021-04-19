import 'package:flutter/material.dart';

class LineContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      color: Colors.grey[100],
      width: MediaQuery.of(context).size.width - 25,
    );
  }
}
