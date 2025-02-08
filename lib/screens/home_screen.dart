import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:teste_cronos/resources/sidebar.dart';
import 'package:teste_cronos/utils/utils.dart';
import 'package:teste_cronos/screens/calendar_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class Utils {
  static String dateToString(DateTime date) {
    final formatter = DateFormat('yyyy-MM-dd');
    return formatter.format(date);
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ValueNotifier<DateTime> _selectedDate =
      ValueNotifier<DateTime>(DateTime.now());
  final String uid = FirebaseAuth.instance.currentUser!.uid;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Stream<QuerySnapshot<Object?>> getTasks() {
    try {
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser != null) {
        final uid = currentUser.uid;

        final tasksRef =
            _firestore.collection('users').doc(uid).collection('tasks');

        return tasksRef.snapshots();
      } else {
        return Stream<QuerySnapshot<Object?>>.empty();
      }
    } catch (e) {
      print('Error getting tasks: $e');
      return Stream<QuerySnapshot<Object?>>.empty();
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = _firebaseAuth.currentUser;
    print(user);
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
          'Cronos App - Home',
          style: TextStyle(
            color: colorDark,
            fontSize: 25.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      //SideBar(drawer)======================================
      drawer: AppSideBar(),

      //BODY=======================================
      body: Center(
        child: Container(
          padding: EdgeInsets.all(16.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              'Bem Vindo,',
              style: TextStyle(
                color: colorGreen,
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            //display user's username from firebase
            Text(
              user != null ? user.displayName ?? '' : '',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 24.0),
            const Text(
              'Today\'s Tasks',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: getTasks(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final tasks = snapshot.data!.docs;

                    final selectedTasks = tasks.where((task) {
                      final taskData = task.data() as Map<String,
                          dynamic>?; // Cast to Map<String, dynamic>?
                      if (taskData != null && taskData.containsKey('date')) {
                        final taskDate = taskData['date'] as String?;
                        if (taskDate != null) {
                          final parsedDate = DateTime.parse(taskDate);
                          final selectedDate = DateTime(
                            _selectedDate.value.year,
                            _selectedDate.value.month,
                            _selectedDate.value.day,
                          ).toUtc();
                          print(
                              'Selected date: ${Utils.dateToString(selectedDate)}');
                          print('Task data: $taskData');
                          return parsedDate.year == selectedDate.year &&
                              parsedDate.month == selectedDate.month &&
                              parsedDate.day == selectedDate.day;
                        }
                      }
                      return false;
                    }).toList();
                    selectedTasks.sort((a, b) {
                      final taskDataA = a.data() as Map<String, dynamic>?;
                      final taskDataB = b.data() as Map<String, dynamic>?;
                      if (taskDataA != null && taskDataB != null) {
                        final startTimeA = taskDataA['startTime'] as String?;
                        final startTimeB = taskDataB['startTime'] as String?;
                        if (startTimeA != null && startTimeB != null) {
                          return startTimeA.compareTo(startTimeB);
                        }
                      }
                      return 0;
                    });

                    return selectedTasks.isNotEmpty
                        ? ListView.builder(
                            itemCount: selectedTasks.length,
                            itemBuilder: (context, index) {
                              final task = selectedTasks[index];
                              final taskData =
                                  task.data() as Map<String, dynamic>?;

                              if (taskData != null) {
                                return TaskCard(
                                  taskTitle: task['title'],
                                  taskStartTime: task['startTime'],
                                  taskEndTime: task['endTime'],
                                  task: task,
                                );
                              } else {
                                return const SizedBox();
                              }
                            },
                          )
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Que mamata!',
                                style: TextStyle(
                                  color: colorGreen,
                                  fontSize: 32.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8.0),
                              Text(
                                'Você não tem tarefas para hoje!',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          );
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                },
              ),
            )
          ]),
        ),
      ),
    );
  }
}

class TaskCard extends StatelessWidget {
  final String taskTitle;
  final String taskStartTime;
  final String taskEndTime;
  final DocumentSnapshot task;

  const TaskCard(
      {required this.taskTitle,
      required this.taskStartTime,
      required this.taskEndTime,
      required this.task});

  @override
  Widget build(BuildContext context) {
    CalendarFirestore _calendarFirestore = CalendarFirestore();
    bool isCompleted = task['completed'] ?? false;

    return Card(
      color: isCompleted ? colorGreen : colorRed,
      child: ListTile(
        title: Text(
          taskTitle,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          taskStartTime + ' - ' + taskEndTime,
          style: TextStyle(
            color: colorDark,
          ),
        ),
        trailing: IconButton(
          icon: Icon(
            isCompleted ? MdiIcons.checkCircleOutline : MdiIcons.circleOutline,
            color: Colors.black,
          ),
          onPressed: () {
            _calendarFirestore.updateTask(task.id, {
              'completed': !isCompleted,
            });
          },
        ),
      ),
    );
  }
}
