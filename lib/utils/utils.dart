import 'package:flutter/material.dart';

//my color pallete
const colorDark = Color.fromARGB(255, 239, 232, 227);
const colorGreen = Color.fromARGB(255, 102, 127, 72);
const colorRed = Color.fromARGB(255, 255, 150, 143);

//show snack bar function
showSnackBar(BuildContext context, String content) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(content),
    duration: const Duration(seconds: 3),
  ));
}

//change screen function
changeScreen(BuildContext context, Widget widget) {
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (context) => widget),
    (Route<dynamic> route) => false,
  );
}

extension DateTimeExtensions on DateTime {
  bool isSameDay(DateTime other) {
    return this.year == other.year &&
        this.month == other.month &&
        this.day == other.day;
  }
}
