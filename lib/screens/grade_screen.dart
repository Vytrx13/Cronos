import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:teste_cronos/utils/utils.dart';
import 'package:teste_cronos/resources/sidebar.dart';

class GradeHorariaScreen extends StatefulWidget {
  @override
  GradeHorariaScreenState createState() => GradeHorariaScreenState();
}

class Aulas {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<void> deleteClass(String classId) async {
    try {
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser != null) {
        final uid = currentUser.uid;

        final classRef = _firestore
            .collection('users')
            .doc(uid)
            .collection('classes')
            .doc(classId);

        await classRef.delete();
      }
    } catch (error) {
      print('Error deleting task: $error');
      throw error;
    }
  }

  Future<void> updateClass(
      String classId, Map<String, dynamic> updatedData) async {
    try {
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser != null) {
        final uid = currentUser.uid;

        final classRef = _firestore
            .collection('users')
            .doc(uid)
            .collection('classes')
            .doc(classId);

        await classRef.update(updatedData);
      }
    } catch (e) {
      print('Error updating task: $e');
    }
  }

  Future<void> addClass(Map<String, dynamic> classData) async {
    try {
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser != null) {
        final uid = currentUser.uid;

        final classRef =
            _firestore.collection('users').doc(uid).collection('classes').doc();

        classRef.set(classData);
      }
    } catch (e) {
      print('Error adding class: $e');
    }
  }

  Stream<QuerySnapshot<Object?>> getClasses() {
    try {
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser != null) {
        final uid = currentUser.uid;

        final classRef =
            _firestore.collection('users').doc(uid).collection('classes');

        return classRef.snapshots();
      } else {
        return const Stream<QuerySnapshot<Object?>>.empty();
      }
    } catch (e) {
      print('Error getting tasks: $e');
      return const Stream<QuerySnapshot<Object?>>.empty();
    }
  }
}

class ClassData {
  final String className;
  final String startTime;
  final String endTime;
  final String day;

  ClassData({
    required this.className,
    required this.startTime,
    required this.endTime,
    required this.day,
  });
}

class GradeHorariaScreenState extends State<GradeHorariaScreen> {
  List<List<String>> timetable = List.generate(
    24,
    (index) => List.generate(7, (index) => ''),
  );

  List<String> weekdays = [
    'Segunda',
    'Terça',
    'Quarta',
    'Quinta',
    'Sexta',
  ];

  List<ClassData> classes = [];

  String _selectedDay = '';

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp();
    int today = DateTime.now().weekday;
    switch (today) {
      case 1:
        _selectedDay = weekdays[0];
        break;
      case 2:
        _selectedDay = weekdays[1];
        break;
      case 3:
        _selectedDay = weekdays[2];
        break;
      case 4:
        _selectedDay = weekdays[3];
        break;
      case 5:
        _selectedDay = weekdays[4];
        break;
      default:
        _selectedDay = weekdays[0];
    }
  }

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();

  @override
  void dispose() {
    // Cancel or dispose of ongoing operations
    _titleController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  void _addClass() async {
    showDialog(
      context: context,
      builder: (context) {
        final aulas = Aulas();
        return AlertDialog(
          title: Text('Adicionar Aula'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: InputDecoration(labelText: 'Nome da Matéria'),
                    controller: _titleController,
                  ),
                  SizedBox(height: 8.0),
                  TextField(
                    decoration:
                        InputDecoration(labelText: 'Hora de Início (hh:mm)'),
                    controller: _startTimeController,
                  ),

                  SizedBox(height: 8.0),
                  TextField(
                    decoration:
                        InputDecoration(labelText: 'Hora do Final (hh:mm)'),
                    controller: _endTimeController,
                  ),
                  SizedBox(height: 8.0),
                  DropdownButton(
                    icon: Icon(MdiIcons.arrowDownDropCircleOutline),
                    hint: Text('Dia da semana'),
                    value: _selectedDay,
                    items: weekdays.map((day) {
                      return DropdownMenuItem(
                        value: day,
                        child: Text(day),
                      );
                    }).toList(),
                    onChanged: (selectedDay) {
                      setState(() {
                        _selectedDay = selectedDay.toString();
                      });
                    },
                  ),
                  // Add other class properties fields here
                ],
              );
            },
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final classData = {
                  'className': _titleController.text,
                  'startTime': _startTimeController.text,
                  'endTime': _endTimeController.text,
                  'day': _selectedDay,
                  // Add other class properties here
                };

                try {
                  aulas.addClass(classData);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Class added successfully')),
                  );
                } catch (e) {
                  print('Error adding class: $e');
                }

                _titleController.clear();
                _startTimeController.clear();
                _endTimeController.clear();
                // Clear other text controllers for class properties
              },
              child: Text('Add'),
              style: ElevatedButton.styleFrom(
                primary: colorGreen,
                onPrimary: colorDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32.0),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _editClassDialog(String classId, Map<String, dynamic> classData) {
    // Create TextEditingController for editing class properties
    TextEditingController titleController =
        TextEditingController(text: classData['className']);
    TextEditingController startTimeController =
        TextEditingController(text: classData['startTime']);
    TextEditingController endTimeController =
        TextEditingController(text: classData['endTime']);

    String selectedDay = classData['day'];

    showDialog(
      context: context,
      builder: (context) {
        final aulas = Aulas();
        return AlertDialog(
          backgroundColor: colorDark,
          title: Text('Edit Class'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: InputDecoration(labelText: 'Nome da Matéria'),
                    controller: titleController,
                  ),
                  SizedBox(height: 8.0),
                  TextField(
                    decoration:
                        InputDecoration(labelText: 'Hora de Início (hh:mm)'),
                    controller: startTimeController,
                  ),
                  SizedBox(height: 8.0),
                  TextField(
                    decoration:
                        InputDecoration(labelText: 'Hora do Final (hh:mm)'),
                    controller: endTimeController,
                  ),
                  SizedBox(height: 8.0),
                  DropdownButton(
                    icon: Icon(MdiIcons.arrowDownDropCircleOutline),
                    hint: Text('Dia da Semana'),
                    value: selectedDay,
                    items: weekdays.map((day) {
                      return DropdownMenuItem(
                        value: day,
                        child: Text(day),
                      );
                    }).toList(),
                    onChanged: (selected) {
                      setState(() {
                        selectedDay = selected.toString();
                      });
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Update task data
                aulas.updateClass(classId, {
                  'className': titleController.text,
                  'day': selectedDay,
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

  void _confirmDeleteClassDialog(String classId) {
    final aulas = Aulas();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: colorDark,
          title: const Text('Confirme a Remoção'),
          content: const Text('Você tem certeza que deseja remover essa aula?'),
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
                aulas.deleteClass(classId);
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

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

//build==============================================================================================================
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
      drawer: AppSideBar(),
      body: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: weekdays.length,
        itemBuilder: (context, index) {
          final day = weekdays[index];
          return Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                child: DayCard(
                    day: day,
                    editClass: _editClassDialog,
                    deleteClass: _confirmDeleteClassDialog),
              ));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addClass,
        backgroundColor: colorGreen,
        child: Icon(MdiIcons.plusBox),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class DayCard extends StatelessWidget {
  final aulas = Aulas();
  final String day;
  final Function(String, Map<String, dynamic>) editClass;
  final Function(String) deleteClass;

  DayCard(
      {required this.day, required this.editClass, required this.deleteClass});

  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: Axis.vertical,
      children: [
        Expanded(
          flex: 0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 8.0),
              Card(
                color: colorGreen,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    day,
                    style: TextStyle(
                      color: colorDark,
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8.0),
              Visibility(
                child: StreamBuilder<QuerySnapshot>(
                  stream: aulas.getClasses(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final classes = snapshot.data!.docs;

                      print("Classes:");
                      print(snapshot.data!.docs);

                      final selectedClasses = classes.where((aula) {
                        final classData = aula.data() as Map<String, dynamic>?;
                        if (classData != null && classData.containsKey('day')) {
                          final classDay = classData['day'] as String?;
                          if (classDay != null) {
                            print("classdata: $classData");
                            return classDay == day;
                          }
                        }
                        return false;
                      }).toList();

                      selectedClasses.sort((a, b) {
                        final classDataA = a.data() as Map<String, dynamic>?;
                        final classDataB = b.data() as Map<String, dynamic>?;
                        if (classDataA != null && classDataB != null) {
                          final startTimeA = classDataA['startTime'] as String?;
                          final startTimeB = classDataB['startTime'] as String?;
                          if (startTimeA != null && startTimeB != null) {
                            return startTimeA.compareTo(startTimeB);
                          }
                        }
                        return 0;
                      });

                      return selectedClasses.isNotEmpty
                          ? ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: selectedClasses.length,
                              itemBuilder: (context, index) {
                                final aula = selectedClasses[index];
                                print("AulaID: ${aula.id}");
                                final classData =
                                    aula.data() as Map<String, dynamic>?;

                                if (classData != null) {
                                  return ClassCard(
                                    className: classData['className'] ?? '',
                                    startTime: classData['startTime'] ?? '',
                                    endTime: classData['endTime'] ?? '',
                                    day: classData['day'] ?? '',
                                    classId: aula.id,
                                    editClass: editClass,
                                    deleteClass: deleteClass,
                                  );
                                } else {
                                  return const SizedBox();
                                }
                              },
                            )
                          : const SizedBox();
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
        ),
      ],
    );
  }
}

class ClassCard extends StatefulWidget {
  final String className;
  final String startTime;
  final String endTime;
  final String day;
  final String classId;
  final Function(String, Map<String, dynamic>) editClass;
  final Function(String) deleteClass;

  ClassCard({
    super.key,
    required this.className,
    required this.startTime,
    required this.endTime,
    required this.day,
    required this.classId,
    required this.editClass,
    required this.deleteClass,
  });

  @override
  State<ClassCard> createState() => _ClassCardState();
}

class _ClassCardState extends State<ClassCard> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width:
          MediaQuery.of(context).size.width * 0.5, // Adjust the width as needed
      child: Card(
        color: colorGreen,
        child: ListTile(
          title: Text(
            widget.className,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            widget.startTime + ' - ' + widget.endTime,
            style: TextStyle(
              color: colorDark,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  MdiIcons.squareEditOutline,
                  color: Colors.black,
                ),
                onPressed: () {
                  print("ClassID: ${widget.classId}");
                  final classData = {
                    'className': widget.className,
                    'startTime': widget.startTime,
                    'endTime': widget.endTime,
                    'day': widget.day,
                  };
                  if (mounted) {
                    widget.editClass(widget.classId.toString(), classData);
                  }
                },
              ),
              IconButton(
                icon: Icon(
                  MdiIcons.delete,
                  color: Colors.black,
                ),
                onPressed: () {
                  if (mounted) {
                    widget.deleteClass(widget.classId.toString());
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
