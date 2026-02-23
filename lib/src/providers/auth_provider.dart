import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../core/services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  User? get user => _user;

  Map<String, dynamic>? _userData;
  Map<String, dynamic>? get userData => _userData;

  Map<String, dynamic>? _partnerData;
  Map<String, dynamic>? get partnerData => _partnerData;

  Map<String, dynamic>? _coupleData;
  Map<String, dynamic>? get coupleData => _coupleData;
  StreamSubscription<DocumentSnapshot>? _coupleSubscription;

  String? get gender => _userData?['gender'];
  String? get partnerId => _userData?['partnerId'];
  String? get coupleId => _userData?['coupleId'];

  bool get isConnected => partnerId != null;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isInitializing = true;
  bool get isInitializing => _isInitializing;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _authService.authStateChanges.listen((User? user) async {
      _user = user;
      if (user != null) {
        _userData = await _authService.getUserData(user.uid);

        // Pre-fetch Partner Data
        if (partnerId != null) {
          try {
            final pDoc = await FirebaseFirestore.instance
                .collection('users')
                .doc(partnerId)
                .get();
            _partnerData = pDoc.data();
          } catch (e) {
            print("Error pre-fetching partner data: $e");
          }
        }

        // Pre-fetch Couple Data
        if (coupleId != null) {
          try {
            final cDoc = await FirebaseFirestore.instance
                .collection('couples')
                .doc(coupleId)
                .get();
            _coupleData = cDoc.data();
          } catch (e) {
            print("Error pre-fetching couple data: $e");
          }
        }

        _listenToCoupleData();
      } else {
        _userData = null;
        _partnerData = null;
        _coupleData = null;
        _coupleSubscription?.cancel();
      }
      _isInitializing = false;
      notifyListeners();
    });
  }

  void _listenToCoupleData() {
    _coupleSubscription?.cancel();
    final cId = _userData?['coupleId'];
    if (cId != null) {
      _coupleSubscription = FirebaseFirestore.instance
          .collection('couples')
          .doc(cId)
          .snapshots()
          .listen((snapshot) {
            _coupleData = snapshot.data();
            notifyListeners();
          });
    } else {
      // Only clear if we really expected one but don't have it?
      // No, if cId is null, coupleData should probably be null.
      if (_coupleData != null && cId == null) {
        _coupleData = null;
        notifyListeners();
      }
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> refreshUserData() async {
    if (_user != null) {
      _userData = await _authService.getUserData(_user!.uid);
      _listenToCoupleData();
      notifyListeners();
    }
  }

  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _authService.signInWithEmailAndPassword(email, password);
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message;
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = "An unexpected error occurred.";
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String gender,
    required String avatarUrl,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      // 1. Create Auth User
      final user = await _authService.createUserWithEmailAndPassword(
        email,
        password,
      );

      if (user != null) {
        // 2. Save User Data to Firestore
        await _authService.saveUserData(
          uid: user.uid,
          email: email,
          firstName: firstName,
          lastName: lastName,
          gender: gender,
          avatarUrl: avatarUrl,
        );

        // 3. Update Display Name in Auth (optional but good practice)
        final fullName = '$lastName $firstName'.trim();
        await user.updateDisplayName(fullName);
        await user.reload();
        _user = _authService.currentUser;
      }

      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message;
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = "An unexpected error occurred: $e";
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateUser(Map<String, dynamic> data) async {
    if (_user == null) return false;
    _setLoading(true);
    try {
      await _authService.updateUserProfile(_user!.uid, data);
      await refreshUserData();
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateCoupleData(Map<String, dynamic> data) async {
    if (_user == null) return false;

    // Check if we need to migrate/create couple doc (for existing connections)
    if (coupleId == null && partnerId != null) {
      _setLoading(true);
      try {
        // Create new couple doc
        final coupleRef = FirebaseFirestore.instance
            .collection('couples')
            .doc();
        await coupleRef.set({
          'users': [_user!.uid, partnerId],
          'createdAt': FieldValue.serverTimestamp(),
          ...data, // Set initial data directly
        });

        // Update users
        final batch = FirebaseFirestore.instance.batch();
        batch.update(
          FirebaseFirestore.instance.collection('users').doc(_user!.uid),
          {'coupleId': coupleRef.id},
        );
        batch.update(
          FirebaseFirestore.instance.collection('users').doc(partnerId),
          {'coupleId': coupleRef.id},
        );
        await batch.commit();

        await refreshUserData(); // Load new coupleId
        _setLoading(false);
        return true;
      } catch (e) {
        _errorMessage = "Migration failed: $e";
        _setLoading(false);
        return false;
      }
    }

    if (coupleId == null) return false;

    _setLoading(true);
    try {
      await FirebaseFirestore.instance
          .collection('couples')
          .doc(coupleId)
          .update(data);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }
}
