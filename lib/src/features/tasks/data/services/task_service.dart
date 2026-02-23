import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/shared_task_model.dart';

class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get stream of tasks for a specific couple
  Stream<List<SharedTask>> getTasksStream(String coupleId) {
    return _firestore
        .collection('couples')
        .doc(coupleId)
        .collection('tasks')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => SharedTask.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  // Add a new task
  Future<void> addTask(String coupleId, SharedTask task) async {
    await _firestore
        .collection('couples')
        .doc(coupleId)
        .collection('tasks')
        .add(task.toMap());
  }

  // Update a task (e.g., toggle completion, edit details)
  Future<void> updateTask(String coupleId, SharedTask task) async {
    await _firestore
        .collection('couples')
        .doc(coupleId)
        .collection('tasks')
        .doc(task.id)
        .update(task.toMap());
  }

  // Delete a task
  Future<void> deleteTask(String coupleId, String taskId) async {
    await _firestore
        .collection('couples')
        .doc(coupleId)
        .collection('tasks')
        .doc(taskId)
        .delete();
  }
}
