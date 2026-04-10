import 'package:firebase_auth/firebase_auth.dart'; // auth
import 'package:cloud_firestore/cloud_firestore.dart'; //database
import 'package:flutter/foundation.dart';

class PendingApprovalException implements Exception {
  const PendingApprovalException();
}

class AccountNotApprovedException implements Exception {
  const AccountNotApprovedException();
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance; // creates singleton
  final FirebaseFirestore _db = FirebaseFirestore.instance; // read and write to database

  /// Returns the currently signed-in org user only if account status is approved.
  /// If user exists but the org document is missing/pending/not-approved, signs out.
  Future<User?> getApprovedCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) {
      return null;
    }

    final doc = await _db.collection('organizations').doc(user.uid).get();
    if (!doc.exists) {
      await _auth.signOut();
      return null;
    }

    final data = doc.data();
    final status = (data?['status'] as String? ?? '').toLowerCase();
    if (status != 'approved') {
      await _auth.signOut();
      return null;
    }

    return user;
  }

  Future<User?> registerOrg({ //async function that returns a user (or null if failed)
    required String email,
    required String password,
    required String orgName,
    required String webURL,
    required String regNumber,
    required String orgDescription,
  }) async {
    try {

      //Creates a Firebase Auth account
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      //Extracts the actual user object
      User? user = result.user;

      //Creates a document in Firestore
      if (user != null) {
        await _db.collection('organizations').doc(user.uid).set({ //Document ID = user UID
          'orgName': orgName,
          'email': email,
          'webURL': webURL,
          'regNumber': regNumber,
          'orgDescription': orgDescription,
          'status': 'pending',
          'createdAt': FieldValue.serverTimestamp(), //Stores server time
        });

        return user;
      }

      return null;

    } catch (e) {
      debugPrint('registerOrg error: $e');
      return null;
    }
  }

  //login
  Future<User?> loginOrg({
    required String email,
    required String password,
  }) async {

    //logs user in
    UserCredential result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    User? user = result.user; //gets logged in user

    if (user == null) {
      return null;
    }

    DocumentSnapshot<Map<String, dynamic>> doc =
        await _db.collection('organizations').doc(user.uid).get();

    if (!doc.exists) { //logs user out if account doesn't exist
      await _auth.signOut();
      return null;
    }

    final data = doc.data();
    final status = (data?['status'] as String? ?? '').toLowerCase();

    if (status == 'pending') {
      await _auth.signOut();
      throw const PendingApprovalException();
    }

    if (status != 'approved') {
      await _auth.signOut();
      throw const AccountNotApprovedException();
    }

    return user;
  }

  Future<void> signOut() async { //logs user out
    await _auth.signOut();
  }

  Stream<User?> get user { // real time stream. tells if user is logged in or not
    return _auth.authStateChanges();
  }
}