import 'package:cloud_firestore/cloud_firestore.dart';

class ConnectionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Send connection request
  Future<void> sendConnectionRequest(
    String targetEmail,
    String senderUid,
    String senderEmail,
  ) async {
    // 1. Check if target user exists
    final userQuery = await _firestore
        .collection('users')
        .where('email', isEqualTo: targetEmail)
        .limit(1)
        .get();

    if (userQuery.docs.isEmpty) {
      throw Exception('Không tìm thấy người dùng với email này');
    }

    final targetUser = userQuery.docs.first;
    final targetUid = targetUser.id;

    if (targetUid == senderUid) {
      throw Exception('Bạn không thể kết nối với chính mình');
    }

    // Check if target already has a partner
    if (targetUser.data()['partnerId'] != null) {
      throw Exception('Người dùng này đã có kết nối với người khác');
    }

    // 2. Check for existing pending requests (to avoid spam)
    final existingRequests = await _firestore
        .collection('connection_requests')
        .where('senderUid', isEqualTo: senderUid)
        .where('receiverUid', isEqualTo: targetUid)
        .where('status', isEqualTo: 'pending')
        .get();

    if (existingRequests.docs.isNotEmpty) {
      throw Exception('Bạn đã gửi lời mời cho người này rồi');
    }

    // 3. Create request
    await _firestore.collection('connection_requests').add({
      'senderUid': senderUid,
      'senderEmail': senderEmail,
      'receiverUid': targetUid,
      'receiverEmail': targetEmail,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Get requests received by the current user
  Stream<List<Map<String, dynamic>>> getReceivedRequests(String currentUid) {
    return _firestore
        .collection('connection_requests')
        .where('receiverUid', isEqualTo: currentUid)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList(),
        );
  }

  // Approve a request
  Future<void> approveConnectionRequest(
    String requestId,
    String requesterUid,
    String currentUid,
  ) async {
    final batch = _firestore.batch();
    final coupleRef = _firestore.collection('couples').doc();

    // 0. Create couples document
    batch.set(coupleRef, {
      'users': [currentUid, requesterUid],
      'createdAt': FieldValue.serverTimestamp(),
    });

    // 1. Update current user's partnerId & coupleId
    final currentUserRef = _firestore.collection('users').doc(currentUid);
    batch.update(currentUserRef, {
      'partnerId': requesterUid,
      'coupleId': coupleRef.id,
    });

    // 2. Update requester's partnerId & coupleId
    final requesterUserRef = _firestore.collection('users').doc(requesterUid);
    batch.update(requesterUserRef, {
      'partnerId': currentUid,
      'coupleId': coupleRef.id,
    });

    // 3. Delete the request (or mark as accepted)
    final requestRef = _firestore
        .collection('connection_requests')
        .doc(requestId);
    batch.delete(requestRef);

    await batch.commit();
  }

  // Reject a request
  Future<void> rejectConnectionRequest(String requestId) async {
    await _firestore.collection('connection_requests').doc(requestId).delete();
  }

  // Unpair/Disconnect
  Future<void> disconnect(String currentUid, String partnerUid) async {
    final userDoc = await _firestore.collection('users').doc(currentUid).get();
    final coupleId = userDoc.data()?['coupleId'];

    final batch = _firestore.batch();

    if (coupleId != null) {
      final coupleRef = _firestore.collection('couples').doc(coupleId);
      batch.delete(coupleRef);
    }

    final currentUserRef = _firestore.collection('users').doc(currentUid);
    batch.update(currentUserRef, {
      'partnerId': FieldValue.delete(),
      'coupleId': FieldValue.delete(),
    });

    final partnerUserRef = _firestore.collection('users').doc(partnerUid);
    batch.update(partnerUserRef, {
      'partnerId': FieldValue.delete(),
      'coupleId': FieldValue.delete(),
    });

    await batch.commit();
  }

  // Fetch specific user data (e.g., partner profile)
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print('Error fetching user data: $e');
      return null;
    }
  }
}
