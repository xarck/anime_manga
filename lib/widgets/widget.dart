import 'package:flutter/material.dart';

Widget title({text, styles}) {
  return Text(text.length > 12 ? text.substring(0, 12) + '...' : text,
      style: styles);
}

Widget downloadTitle({text, styles}) {
  return Text(
      text.length > 18
          ? text.substring(0, 18) +
              '...' +
              text.substring(text.length - 10, text.length)
          : text,
      style: styles);
}
