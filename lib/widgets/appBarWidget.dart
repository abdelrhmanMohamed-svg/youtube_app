import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'custom_text.dart';

class Appbarwidget extends StatelessWidget {
  const Appbarwidget(
      {super.key,
      required this.searchController,
      required this.searchFocusNode,
      required this.onTap,
      required this.onSubmitted, required this.suffix});
  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final Function() onTap;
  final Function(dynamic) onSubmitted;
  final Widget suffix;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Image.asset(
        'assets/y.png',
        width: 40,
      ),
      const SizedBox(width: 5.5),
      CustomText(
        txt: "YouTube",
        fontWeight: FontWeight.bold,
        fontsize: 20,
      ),
      SizedBox(
        width: 11,
      ),
      Expanded(
        child: CupertinoTextField(
          focusNode: searchFocusNode,
          controller: searchController,
          prefix: Padding(
            padding: const EdgeInsets.only(left: 7.0),
            child: Icon(CupertinoIcons.search, color: Colors.black45, size: 18),
          ),
          suffix:suffix ,
          placeholder: "Search...",
          placeholderStyle: TextStyle(color: Colors.black45),
          style: TextStyle(color: Colors.black),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white),
          ),
          onTap: onTap,
          onSubmitted: onSubmitted,
        ),
      )
    ]);
  }
}
