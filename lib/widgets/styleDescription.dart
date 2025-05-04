import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';


Widget styledDescription(String text,bool isDesc) {
  final pattern = RegExp(r'(https?:\/\/[^\s]+|#[\w]+)');
  final matches = pattern.allMatches(text);

  List<TextSpan> spans = [];
  int lastEnd = 0;

  for (final match in matches) {
    if (match.start > lastEnd) {
      spans.add(TextSpan(text: text.substring(lastEnd, match.start)));
    }

    final matchedText = match.group(0)!;
    spans.add(
      TextSpan(
        text: matchedText,
        style: TextStyle(color: Colors.blue),
      ),
    );

    lastEnd = match.end;
  }

  if (lastEnd < text.length) {
    spans.add(TextSpan(text: text.substring(lastEnd)));
  }

  return GestureDetector(
    onTap: () {
      
      isDesc = !isDesc;
    },
    child: RichText(
      text: TextSpan(
        style: TextStyle(color: Colors.white70),
        children: spans,
      ),
    ),
  );
}
