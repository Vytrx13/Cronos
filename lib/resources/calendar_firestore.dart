import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CalendarFirestore {
  final CollectionReference _tasksCollection =
      FirebaseFirestore.instance.collection('tasks');

  Future<void> addTask(String title, DateTime date) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final userId = user?.uid;
      
      if (userId != null) {
        await _tasksCollection.doc(userId).collection('userTasks').add({
          'title': title,
          'date': Timestamp.fromDate(date),
          'completed': false,
        });
      } else {
        print('User not authenticated.');
      }
    } catch (error) {
      print('Error adding task: $error');
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getTasks() {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid;

    if (userId != null) {
      return _tasksCollection
          .doc(userId)
          .collection('userTasks')
          .orderBy('date')
          .snapshots();
    } else {
      // Return an empty stream if user is not authenticated
      return Stream.empty();
    }
  }

  Future<void> updateTask(String taskId, Map<String, dynamic> updatedData) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final userId = user?.uid;

      if (userId != null) {
        await _tasksCollection
            .doc(userId)
            .collection('userTasks')
            .doc(taskId)
            .update(updatedData);
      } else {
        print('User not authenticated.');
      }
    } catch (error) {
      print('Error updating task: $error');
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final userId = user?.uid;

      if (userId != null) {
        await _tasksCollection
            .doc(userId)
            .collection('userTasks')
            .doc(taskId)
            .delete();
      } else {
        print('User not authenticated.');
      }
    } catch (error) {
      print('Error deleting task: $error');
    }
  }
}
