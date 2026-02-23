import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CycleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection reference
  CollectionReference get _usersCollection => _firestore.collection('users');

  /// Generate a unique ID for the cycle log
  String get _newId => _firestore.collection('tmp').doc().id;

  /// Save a new cycle log
  Future<void> saveCycleLog({
    required DateTime startDate,
    // Optional end date if user inputs it, or calculated later
    DateTime? endDate,
    required List<String> moods,
    required List<String> symptoms,
    String? note,
    String? userId, // Target user ID
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('User not logged in');

    final targetUid = userId ?? currentUser.uid;

    try {
      final logId = _newId;
      await _usersCollection
          .doc(targetUid)
          .collection('cycle_logs')
          .doc(logId)
          .set({
            'id': logId,
            'startDate': Timestamp.fromDate(startDate),
            'endDate': endDate != null ? Timestamp.fromDate(endDate) : null,
            'moods': moods,
            'symptoms': symptoms,
            'note': note,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedBy': currentUser.uid, // Track who made the update
          });
    } catch (e) {
      rethrow;
    }
  }

  /// Get cycle logs stream
  Stream<List<Map<String, dynamic>>> getCycleLogs({String? userId}) {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return const Stream.empty();

    final targetUid = userId ?? currentUser.uid;

    return _usersCollection
        .doc(targetUid)
        .collection('cycle_logs')
        .orderBy('startDate', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => doc.data()).toList();
        });
  }
}
