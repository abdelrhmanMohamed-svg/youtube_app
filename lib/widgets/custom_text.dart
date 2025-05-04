import 'package:flutter/material.dart';

class CustomText extends StatelessWidget {
  const CustomText(
      {super.key,
      required this.txt,
      this.fontsize,
      this.color = Colors.white,
      this.fontWeight,
      this.maxline});

  final String txt;
  final double? fontsize;
  final Color? color;
  final FontWeight? fontWeight;
  final int? maxline;
  @override
  Widget build(BuildContext context) {
    return Text(
      txt,
      maxLines: maxline,
      style:
          TextStyle(fontSize: fontsize, color: color, fontWeight: fontWeight),
    );
  }
}
