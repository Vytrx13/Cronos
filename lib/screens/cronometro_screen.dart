import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:teste_cronos/resources/sidebar.dart';
import 'package:teste_cronos/utils/utils.dart';

class StopwatchPage extends StatefulWidget {
  @override
  _StopwatchPageState createState() => _StopwatchPageState();
}

class _StopwatchPageState extends State<StopwatchPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool isRunning = false;
  bool isPaused = false;
  int milliseconds = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 100));
    _animationController.addListener(() {
      if (_animationController.status == AnimationStatus.completed &&
          isRunning) {
        setState(() {
          milliseconds += 100;
        });
        _animationController.forward(from: 0.0);
      }
    });
  }

  void resetTimer() {
    setState(() {
      isPaused = false;
      isRunning = false;
      milliseconds = 0;
    });
  }

  void toggleTimer() {
    setState(() {
      isRunning = !isRunning;
    });
    if (isRunning) {
      _animationController.forward(from: 0.0);
      isPaused = false;
    } else {
      isPaused = true;
      _animationController.stop();
    }
  }

  String formatMilliseconds(int milliseconds) {
    int seconds = (milliseconds ~/ 1000) % 60;
    int minutes = (milliseconds ~/ (1000 * 60)) % 60;
    int hours = (milliseconds ~/ (1000 * 60 * 60)) % 24;

    String secondsStr = seconds.toString().padLeft(2, '0');
    String minutesStr = minutes.toString().padLeft(2, '0');
    String hoursStr = hours.toString().padLeft(2, '0');

    return "$hoursStr:$minutesStr:$secondsStr";
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: colorDark,

      //AppBar=====================================
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(MdiIcons.menu),
          onPressed: () {
            _scaffoldKey.currentState!.openDrawer();
          },
        ),
        shadowColor: colorGreen,
        backgroundColor: colorGreen,
        elevation: 1,
        surfaceTintColor: Colors.white,
        title: const Text(
          'Cronos App - Cronômetro',
          style: TextStyle(
            color: colorDark,
          ),
        ),
      ),

      drawer: AppSideBar(),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              formatMilliseconds(milliseconds),
              style: TextStyle(fontSize: 48),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
                backgroundColor: isRunning ? colorRed : colorGreen,
              ),
              onPressed: toggleTimer,
              child: Text(isRunning ? 'Stop' : (isPaused ? 'Resume' : 'Start')),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
                backgroundColor: colorGreen,
              ),
              onPressed: resetTimer,
              child: Text('Reset'),
            ),
          ],
        ),
      ),
    );
  }
}
