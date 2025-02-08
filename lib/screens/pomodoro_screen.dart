import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:teste_cronos/utils/utils.dart';
import 'package:teste_cronos/resources/sidebar.dart';

class PomodoroPage extends StatefulWidget {
  @override
  _PomodoroPageState createState() => _PomodoroPageState();
}

class _PomodoroPageState extends State<PomodoroPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  int _workDuration = 25;
  int _breakDuration = 5;
  int _timeRemaining = 0;
  bool _isStudying = false;
  bool _isRunning = false;
  bool _isPaused = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          if (!_isPaused) {
            if (_timeRemaining > 0) {
              _timeRemaining--;
            } else {
              _isStudying = !_isStudying;
              _timeRemaining =
                  _isStudying ? _workDuration * 60 : _breakDuration * 60;
            }
          }
        });
        _animationController.reset();
        _animationController.forward();
      }
    });

    if (_isRunning) {
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void startTimer() {
    _timeRemaining = _isStudying ? _workDuration * 60 : _breakDuration * 60;
    _animationController.reset();
    _animationController.forward();
  }

  void stopTimer() {
    _animationController.stop();
  }

  void resetTimer() {
    stopTimer();
    if (_isStudying) {
      setState(() {
        _isStudying = true;
        _isRunning = false;
        _isPaused = false;
        _timeRemaining = _workDuration * 60;
      });
    } else {
      setState(() {
        _isStudying = false;
        _isRunning = false;
        _isPaused = false;
        _timeRemaining = _breakDuration * 60;
      });
    }
  }

  String formatDuration(int duration) {
    int minutes = (duration ~/ 60) % 60;
    int seconds = duration % 60;

    String minutesStr = minutes.toString().padLeft(2, '0');
    String secondsStr = seconds.toString().padLeft(2, '0');

    return "$minutesStr:$secondsStr";
  }

  void toggleTimer() {
    setState(() {
      _isRunning = !_isRunning;
      if (_isRunning) {
        if (_isPaused) {
          _animationController.forward();
          _isPaused = false;
        } else {
          if (_timeRemaining <= 0) {
            _isStudying = !_isStudying;
            _timeRemaining =
                _isStudying ? _workDuration * 60 : _breakDuration * 60;
          }
          startTimer();
        }
        _isPaused = false;
      } else {
        stopTimer();
        _isPaused = true;
      }
    });
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
          'Cronos App - Pomodoro',
          style: TextStyle(
            color: colorDark,
          ),
        ),
      ),

      //Drawer=====================================
      drawer: AppSideBar(),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Flexible(child: Container(), flex: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (!_isStudying) {
                      setState(() {
                        _isStudying = true;
                        _isPaused = false;
                        if (!_isRunning) {
                          _timeRemaining = _workDuration * 60;
                        }
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(primary: colorGreen),
                  child: Text('Modo Estudo'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    if (_isStudying) {
                      setState(() {
                        _isStudying = false;
                        _isPaused = false;
                        if (!_isRunning) {
                          _timeRemaining = _breakDuration * 60;
                        }
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(primary: colorGreen),
                  child: Text('Modo Break'),
                ),
              ],
            ),
            Flexible(child: Container(), flex: 1),
            Text(
              _isStudying ? 'Estudo' : 'Break',
              style: TextStyle(fontSize: 32),
            ),
            SizedBox(height: 16),
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Text(
                  formatDuration(_timeRemaining),
                  style: TextStyle(fontSize: 48),
                );
              },
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: resetTimer,
                  child: Text('Reset'),
                  style: ElevatedButton.styleFrom(primary: colorGreen),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: toggleTimer,
                  style: _isRunning
                      ? ElevatedButton.styleFrom(primary: colorRed)
                      : ElevatedButton.styleFrom(primary: colorGreen),
                  child: Text(
                      _isRunning ? 'Pause' : (_isPaused ? 'Resume' : 'Start')),
                ),
              ],
            ),
            Flexible(child: Container(), flex: 3),
          ],
        ),
      ),
    );
  }
}
