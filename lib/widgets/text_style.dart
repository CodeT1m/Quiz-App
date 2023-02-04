import 'package:flutter/material.dart';
import 'package:quiz_app/constants/colors.dart';

// custom text widgets

Widget normalText(String? text, Color? color, double? size,) {
  
 return Text(
  text!,
  style: TextStyle(
    fontFamily: "quick_semi",
    fontSize: size,
    color: color
  ),
 );
}

Widget headingText(String? text, Color? color, double? size,) {
  
 return Text(
  text!,
  style: TextStyle(
    fontFamily: "quick_bold",
    fontSize: size,
    color: color
  ),
 );
}