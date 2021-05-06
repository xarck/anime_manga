import 'package:flutter/material.dart';

Widget title({text, styles}) {
  return Text(text.length > 15 ? text.substring(0, 15) + '...' : text,
      style: styles);
}
