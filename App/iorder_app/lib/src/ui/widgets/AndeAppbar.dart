import 'package:flutter/material.dart';

class AndeAppbar extends StatelessWidget implements PreferredSizeWidget{

  final String screenTitle ;
  final bool hasBackButton ;
  final List<Widget> actions;
  final Widget leading ;
  AndeAppbar({this.screenTitle , this.hasBackButton , this.actions , this.leading});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/images/background.jpg'),
              fit: BoxFit.cover)),
      child: AppBar(
        actions: actions ?? [],
        automaticallyImplyLeading: leading != null &&  hasBackButton == false ,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        brightness: Brightness.light,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        title: Text(
          screenTitle,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18
          ),
        ),
        leading: leading != null ? leading :  hasBackButton ? IconButton(
          icon: Icon(Icons.chevron_left),
          onPressed: () => Navigator.of(context).pop(),
        ) : Container(width: 0, height: 0,),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(55.0);
}
