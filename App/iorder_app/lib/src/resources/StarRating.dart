import 'package:ande_app/src/utilities/LocalKeys.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

typedef void RatingChangeCallback(double rating);

class StarRating extends StatelessWidget {
  final int starCount;
  final double rating;
  final RatingChangeCallback onRatingChanged;
  final Color color;
  final double size;
  final MainAxisAlignment alignment;
  StarRating(
      {this.starCount = 5,
      this.rating = .0,
      this.onRatingChanged,
      this.color,
      this.size = 40,
      this.alignment = MainAxisAlignment.center});
  Widget buildStar(BuildContext context, int index) {
    String icon;
    if (index >= rating - .2) {
      icon = LocalKeys.STAR_EMPTY;
    } else if (index > rating - .8 && index < rating - .2) {
      icon = LocalKeys.STAR_HALF;
    } else {
      icon = LocalKeys.STAR_FULL;
    }
    return new GestureDetector(
      onTap:
          onRatingChanged == null ? null : () => onRatingChanged(index + 1.0),
      child: Image.asset(
        icon,
        height: size,
        width: size,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Row(
        mainAxisAlignment: alignment,
        children:
            new List.generate(starCount, (index) => buildStar(context, index)));
  }
}
