import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AndeImageNetwork extends StatelessWidget {

  final ImageProvider  placeHolder;
  final String image;
  final double width , height ;
  final BoxFit fit;
  final bool constrained ;
  final BlendMode blend ;

  AndeImageNetwork( this.image ,{this.placeHolder , this.blend , this.width , this.height , this.fit , this.constrained});


  @override
  Widget build(BuildContext context) {
    bool showSVG = ((image != null) ? image.toLowerCase().endsWith('.svg') : false);
    return showSVG ?
    SvgPicture.network(
      image,
      width: width ?? 50,
      height: height ?? 50,
      placeholderBuilder: (context) => Image.asset('assets/images/app_logo.png', width: 30, height: 30,),
    ) :
    (constrained ?? false) ? SizedBox(width: width ?? 50, height: height ?? 50, child: FadeInImage(
      imageErrorBuilder: (BuildContext context,
          Object exception,
          StackTrace stackTrace) {
        return  placeHolder != null ? Image(image: placeHolder,) :  Image.asset('assets/images/app_logo.png' , width: width ?? 50, height: height ?? 50,);
      },
      fit: fit ?? BoxFit.cover,
      width: width ?? 50,
      height: height ?? 50,
      placeholder: placeHolder ?? AssetImage('assets/images/app_logo.png') ,
      image: NetworkImage(image.toString()),
    ),) :
    FadeInImage(
      imageErrorBuilder: (BuildContext context,
          Object exception,
          StackTrace stackTrace) {
        return placeHolder != null ? Image(image: placeHolder,) : Image.asset(
            'assets/images/app_logo.png');
      },
      fit: fit ?? BoxFit.cover,
      placeholder: placeHolder ?? AssetImage(
          'assets/images/app_logo.png'),
      image:NetworkImage(image.toString() ?? ''),
    );
  }
}
