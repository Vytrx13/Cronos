import 'package:flutter/material.dart';
import 'package:teste_cronos/screens/calendar_screen.dart';

_navigateToCalendar(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => CalendarPage()),
  );
}
