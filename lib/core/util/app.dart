import 'package:flutter/material.dart';

class AppUtils{
  static void showSnackBar(BuildContext ctx , String msg, {bool err = false}){
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(content: Text(msg),
      backgroundColor: err ? Colors.red : Colors.green,
      )
    );
  }

  static double getResponsiveWidth(BuildContext ctx, {double desktopWidth = 1000, double tabletWidth = 1000}){
    final width = MediaQuery.of(ctx).size.width;

    if(width > desktopWidth){
      return desktopWidth;
    }else if (width > tabletWidth){
      return tabletWidth;
    }else {
      return width * 0.9; //모바일에서 
    }
  }


}