import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:teste_cronos/screens/grade_screen.dart';
import 'package:teste_cronos/screens/home_screen.dart';
import 'package:teste_cronos/utils/utils.dart';
import 'package:teste_cronos/screens/calendar_screen.dart';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:teste_cronos/screens/login_screen.dart';
import 'package:teste_cronos/screens/pomodoro_screen.dart';
import 'package:teste_cronos/screens/cronometro_screen.dart';

class AppSideBar extends StatelessWidget {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  AppSideBar({Key? key}) : super(key: key);

  void _logout(BuildContext context) async {
    await _firebaseAuth.signOut();
    changeScreen(context, LoginScreen());
  }

  void _navigateToCronometro(BuildContext context){
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => StopwatchPage()),
    );
  }

  void _navigateToCalendar(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CalendarPage()),
    );
  }

  void _navigateToHome(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }

  
  void _navigateToGrade(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GradeHorariaScreen()),
    );
  }

  void _navigateToPomodoro(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PomodoroPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: min(MediaQuery.of(context).size.width * 0.75, 300),
      backgroundColor: colorDark,
      child: ListView(padding: EdgeInsets.zero, children: [
        const DrawerHeader(
          decoration: BoxDecoration(
            color: colorGreen,
          ),
          child: Text(
            'Menu',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: colorDark,
              fontSize: 24.0,
            ),
          ),
        ),


        //BOTÃO HOME
        ElevatedButton(
          onPressed: () =>
              _navigateToHome(context), // Navigate to the calendar page
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Icon(MdiIcons.home),SizedBox(width: 8.0,), Text('Home')],
          ),
          style: ElevatedButton.styleFrom(
            primary: colorGreen,
            onPrimary: colorDark,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32.0),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            textStyle: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),


        SizedBox(height: 8.0),


        //BOTÃO CALENDÁRIO
        ElevatedButton(
          onPressed: () =>
              _navigateToCalendar(context), // Navigate to the calendar page
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Icon(MdiIcons.calendar),SizedBox(width: 8.0,), Text('Calendário')],
          ),
          style: ElevatedButton.styleFrom(
            primary: colorGreen,
            onPrimary: colorDark,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32.0),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            textStyle: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),


        SizedBox(height: 8.0),


        //BOTÃO POMODORO
                ElevatedButton(
          onPressed: () =>
              _navigateToPomodoro(context), // Navigate to the calendar page
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Icon(MdiIcons.timerSand),SizedBox(width: 8.0,), Text('Pomodoro')],
          ),
          style: ElevatedButton.styleFrom(
            primary: colorGreen,
            onPrimary: colorDark,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32.0),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            textStyle: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        
                SizedBox(height: 8.0),


        //BOTÃO CALENDÁRIO
        ElevatedButton(
          onPressed: () =>
              _navigateToGrade(context), // Navigate to the calendar page
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Icon(MdiIcons.tableClock),SizedBox(width: 8.0,), Text('Grade Horária')],
          ),
          style: ElevatedButton.styleFrom(
            primary: colorGreen,
            onPrimary: colorDark,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32.0),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            textStyle: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        SizedBox(height: 8.0),

                //BOTÃO CALENDÁRIO
        ElevatedButton(
          onPressed: () =>
            _navigateToCronometro(context), // Navigate to the calendar page
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Icon(MdiIcons.clock), 
            SizedBox(width: 8.0,),
            Text('Cronômetro')],
          ),
          style: ElevatedButton.styleFrom(
            primary: colorGreen,
            onPrimary: colorDark,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32.0),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            textStyle: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        SizedBox(height: 8.0),


        //BOTÃO LOGOUT
        ElevatedButton(
          onPressed: () => _logout(context),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Icon(MdiIcons.logout),SizedBox(width: 8.0,), Text('Logout')],
          ),
          style: ElevatedButton.styleFrom(
            primary: colorGreen,
            onPrimary: colorDark,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32.0),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            textStyle: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        SizedBox(height: 8.0),
      ]),
    );
  }
}
