import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teste_cronos/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:teste_cronos/resources/sidebar.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class Utils {
  static String dateToString(DateTime date) {
    final formatter = DateFormat('yyyy-MM-dd');
    return formatter.format(date);
  }
}

class CalendarFirestore {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<void> addTask(String date, Map<String, dynamic> taskData) async {
    try {
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser != null) {
        final uid = currentUser.uid;

        final taskRef = _firestore
            .collection('users')
            .doc(uid)
            .collection('tasks')
            .doc(); // Generate a new document ID

        final taskWithDate = {
          ...taskData,
          'date': date
        }; // Add the 'date' field to the task data

        await taskRef.set(taskWithDate);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao adicionar tarefa: $e');
      }
    }
  }

  Stream<QuerySnapshot<Object?>> getTasks() {
    try {
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser != null) {
        final uid = currentUser.uid;

        final tasksRef =
            _firestore.collection('users').doc(uid).collection('tasks');

        return tasksRef.snapshots();
      } else {
        return const Stream<QuerySnapshot<Object?>>.empty();
      }
    } catch (e) {
      print('Error getting tasks: $e');
      return const Stream<QuerySnapshot<Object?>>.empty();
    }
  }

  Future<void> updateTask(
      String taskId, Map<String, dynamic> updatedData) async {
    try {
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser != null) {
        final uid = currentUser.uid;

        final taskRef = _firestore
            .collection('users')
            .doc(uid)
            .collection('tasks')
            .doc(taskId);

        await taskRef.update(updatedData);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating task: $e');
      }
    }
  }

  // Delete task
  Future<void> deleteTask(String taskId) async {
    try {
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser != null) {
        final uid = currentUser.uid;

        final taskRef = _firestore
            .collection('users')
            .doc(uid)
            .collection('tasks')
            .doc(taskId);

        await taskRef.delete();
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error deleting task: $error');
      }
      throw error;
    }
  }

  //more functions
}

class _CalendarPageState extends State<CalendarPage> {
  ValueNotifier<DateTime> _selectedDate =
      ValueNotifier<DateTime>(DateTime.now());
  CalendarFirestore _calendarFirestore = CalendarFirestore();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _startTimeController = TextEditingController();
  TextEditingController _endTimeController = TextEditingController();

  @override
  void dispose() {
    _selectedDate.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

// Edit task dialog
  void _editTaskDialog(String taskId, Map<String, dynamic> taskData) {
    // Create TextEditingController for editing task properties
    TextEditingController titleController =
        TextEditingController(text: taskData['title']);
    TextEditingController descriptionController =
        TextEditingController(text: taskData['description']);
    TextEditingController startTimeController =
        TextEditingController(text: taskData['startTime']);
    TextEditingController endTimeController =
        TextEditingController(text: taskData['endTime']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: colorDark,
          title: Text('Edit Task'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Título'),
                controller: titleController,
              ),
              SizedBox(height: 8.0),
              TextField(
                decoration: const InputDecoration(labelText: 'Descrição'),
                controller: descriptionController,
              ),
              SizedBox(height: 8.0),
              TextField(
                decoration: const InputDecoration(labelText: 'Início (hh:mm)'),
                controller: startTimeController,
              ),
              SizedBox(height: 8.0),
              TextField(
                decoration: const InputDecoration(labelText: 'Fim (hh:mm)'),
                controller: endTimeController,
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Update task data
                _calendarFirestore.updateTask(taskId, {
                  'title': titleController.text,
                  'description': descriptionController.text,
                  'startTime': startTimeController.text,
                  'endTime': endTimeController.text,
                });
              },
              style: ElevatedButton.styleFrom(
                primary: colorGreen,
                onPrimary: colorDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32.0),
                ),
              ),
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteTaskDialog(String taskId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: colorDark,
          title: const Text('Confirme a Remoção'),
          content:
              const Text('Você tem certeza que deseja remover essa tarefa?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                primary: colorGreen,
                onPrimary: colorDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32.0),
                ),
              ),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Delete task
                _calendarFirestore.deleteTask(taskId);
              },
              style: ElevatedButton.styleFrom(
                primary: colorGreen,
                onPrimary: colorDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32.0),
                ),
              ),
              child: Text('Remover'),
            ),
          ],
        );
      },
    );
  }

  void _addTask() async {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Adicionar Tarefa'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(labelText: 'Título'),
                  controller: _titleController,
                ),
                SizedBox(height: 8.0),
                TextField(
                  decoration: InputDecoration(labelText: 'Descrição'),
                  controller: _descriptionController,
                ),
                SizedBox(height: 8.0),
                TextField(
                  decoration: InputDecoration(labelText: 'Início (hh:mm)'),
                  autofillHints: Characters('00:00'),
                  controller: _startTimeController,
                ),

                SizedBox(height: 8.0),

                TextField(
                  decoration: InputDecoration(labelText: 'Fim (hh:mm)'),
                  autofillHints: Characters('00:00'),
                  controller: _endTimeController,
                )
                // Add other task properties fields here
              ],
            ),
            actions: [
              ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    final taskData = {
                      'title': _titleController.text,
                      'description': _descriptionController.text,
                      'completed': false,
                      'startTime': _startTimeController.text,
                      'endTime': _endTimeController.text,

                      // Adicione outras propriedades da tarefa aqui
                    };

                    final selectedDate =
                        Utils.dateToString(_selectedDate.value);
                    _calendarFirestore.addTask(selectedDate, taskData);
                    _titleController.clear();
                    _descriptionController.clear();
                    _startTimeController.clear();
                    _endTimeController.clear();
                    // Limpe os outros controladores de propriedades da tarefa
                  },
                  child: Text('Adicionar'),
                  style: ElevatedButton.styleFrom(
                    primary: colorGreen,
                    onPrimary: colorDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32.0),
                    ),
                  )),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorDark,
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(MdiIcons.menu),
          onPressed: () {
            _scaffoldKey.currentState!.openDrawer();
          },
        ),
        shadowColor: colorGreen,
        backgroundColor: colorGreen,
        surfaceTintColor: Colors.white,
        title: const Text(
          'Cronos App - Calendar',
          style: TextStyle(
            color: colorDark,
          ),
        ),
      ),

      //SideBar(drawer)======================================
      drawer: AppSideBar(),

      //BODY=======================================
      body: Column(
        children: [
          TableCalendar(
            headerStyle: HeaderStyle(
              leftChevronIcon: Icon(MdiIcons.chevronLeft),
              rightChevronIcon: Icon(MdiIcons.chevronRight),
            ),
            calendarStyle: CalendarStyle(
              selectedDecoration: const BoxDecoration(
                color: colorGreen,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: colorGreen.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              selectedTextStyle: TextStyle(color: colorDark),
              todayTextStyle: TextStyle(color: colorDark),
            ),
            firstDay: DateTime.utc(2010, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            focusedDay: DateTime.now(),
            selectedDayPredicate: (date) {
              return isSameDay(_selectedDate.value, date);
            },
            onDaySelected: (date, _) {
              setState(() {
                _selectedDate.value = date;
              });
            },
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _calendarFirestore.getTasks(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final tasks = snapshot.data!.docs;
                  print('Tasks:');
                  print(snapshot.data!.docs);

                  print(
                      'Selected date: ${Utils.dateToString(_selectedDate.value)}');

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
                  
                  return ListView.builder(
                    itemCount: selectedTasks.length,
                    itemBuilder: (context, index) {
                      final task = selectedTasks[index];
                      print('Task: ${task.id}');
                      final taskData = task.data() as Map<String, dynamic>?;

                      if (taskData != null) {
                        return Card(
                          color: colorDark,
                          elevation: 5,
                          margin:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: ListTile(
                            title: Text(
                              taskData['title'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            subtitle: Text(
                              taskData['description'] +
                                  '\n' +
                                  taskData['startTime'] +
                                  '-' +
                                  taskData['endTime'],
                              style: TextStyle(fontSize: 16),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(MdiIcons.squareEditOutline),
                                  onPressed: () {
                                    // Open edit task dialog
                                    print('Edit task: ${task.id}');
                                    _editTaskDialog(task.id, taskData);
                                  },
                                ),
                                IconButton(
                                  icon: Icon(MdiIcons.delete),
                                  onPressed: () {
                                    // Show confirmation dialog before deleting task
                                    _confirmDeleteTaskDialog(task.id);
                                  },
                                ),
                                Checkbox(
                                  value: taskData['completed'] ?? false,
                                  onChanged: (value) {
                                    _calendarFirestore.updateTask(task.id, {
                                      'completed': value,
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      } else {
                        return SizedBox(); // Empty widget if task data is null
                      }
                    },
                  );
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        backgroundColor: colorGreen,
        child: Icon(MdiIcons.plus),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
