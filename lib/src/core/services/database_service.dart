import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/couple_model.dart';
import '../models/todo_model.dart';
import '../models/memory_model.dart';
import '../models/cycle_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- Couple Data ---
  Future<CoupleModel?> getCouple(String coupleId) async {
    final doc = await _db.collection('couples').doc(coupleId).get();
    if (doc.exists) {
      return CoupleModel.fromJson(doc.data()!);
    }
    return null;
  }

  Future<void> createCouple(CoupleModel couple) async {
    await _db.collection('couples').doc(couple.id).set(couple.toJson());
  }

  // --- Todos ---
  Stream<List<TodoModel>> streamTodos(String coupleId) {
    return _db
        .collection('couples')
        .doc(coupleId)
        .collection('todos')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => TodoModel.fromJson(doc.data()))
              .toList();
        });
  }

  Future<void> addTodo(String coupleId, TodoModel todo) async {
    await _db
        .collection('couples')
        .doc(coupleId)
        .collection('todos')
        .doc(todo.id)
        .set(todo.toJson());
  }

  Future<void> toggleTodo(String coupleId, String todoId, bool isDone) async {
    await _db
        .collection('couples')
        .doc(coupleId)
        .collection('todos')
        .doc(todoId)
        .update({'isDone': isDone});
  }

  Future<void> deleteTodo(String coupleId, String todoId) async {
    await _db
        .collection('couples')
        .doc(coupleId)
        .collection('todos')
        .doc(todoId)
        .delete();
  }

  // --- Memories ---
  Stream<List<MemoryModel>> streamMemories(String coupleId) {
    return _db
        .collection('couples')
        .doc(coupleId)
        .collection('memories')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => MemoryModel.fromJson(doc.data()))
              .toList();
        });
  }

  Future<void> addMemory(String coupleId, MemoryModel memory) async {
    await _db
        .collection('couples')
        .doc(coupleId)
        .collection('memories')
        .doc(memory.id)
        .set(memory.toJson());
  }

  // --- Cycles ---
  Stream<List<CycleModel>> streamCycles(String coupleId) {
    // Assuming you might want past cycles ordered by date
    return _db
        .collection('couples')
        .doc(coupleId)
        .collection('cycles')
        .orderBy('startDate', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => CycleModel.fromJson(doc.data()))
              .toList();
        });
  }

  Future<void> addCycle(String coupleId, CycleModel cycle) async {
    await _db
        .collection('couples')
        .doc(coupleId)
        .collection('cycles')
        .doc(cycle.id)
        .set(cycle.toJson());
  }
}
