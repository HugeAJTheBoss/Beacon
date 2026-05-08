// Auth + org-account state for Beacon.
// Firebase Auth (Flutter): https://firebase.google.com/docs/auth/flutter/start
// Cloud Firestore (Flutter): https://firebase.flutter.dev/docs/firestore/usage/

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';


// Custom exceptions for the org-approval flow so the UI can react differently
// to "still pending" vs. "rejected / unknown" outcomes.
class PendingApprovalException implements Exception {
  const PendingApprovalException();
}

class AccountNotApprovedException implements Exception {
  const AccountNotApprovedException();
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Future<String?> getCurrentOrgName() async {
    final user = _auth.currentUser;
    if (user == null) {
      return null;
    }

    final doc = await _db.collection('organizations').doc(user.uid).get();
    final rawOrgName = doc.data()?['orgName'];
    if (rawOrgName is! String) {
      return null;
    }

    final orgName = rawOrgName.trim();
    return orgName.isEmpty ? null : orgName;
  }

  /// Returns the currently signed-in org user only if their account is approved.
  /// If the user exists but their org doc is missing or not approved, signs out
  /// so the app falls back to the welcome screen.
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

  // Creates a new Firebase Auth account and a matching Firestore org doc with
  // status 'pending' so admins can approve it before the org can sign in.
  // Password auth: https://firebase.google.com/docs/auth/flutter/password-auth
  Future<User?> registerOrg({
    required String email,
    required String password,
    required String orgName,
    required String webURL,
    required String regNumber,
    required String orgDescription,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;

      if (user != null) {
        // Document ID matches the auth UID so we can look the org up directly.
        // Tutorial reference: https://www.geeksforgeeks.org/flutter-read-and-write-data-on-firebase/
        await _db.collection('organizations').doc(user.uid).set({
          'orgName': orgName,
          'email': email,
          'webURL': webURL,
          'regNumber': regNumber,
          'orgDescription': orgDescription,
          'status': 'pending',
          'createdAt': FieldValue.serverTimestamp(),
        });

        return user;
      }

      return null;

    } catch (e) {
      debugPrint('registerOrg error: $e');
      return null;
    }
  }

  // Signs an org in. Throws if the account exists but isn't approved yet so
  // the sign-in screen can show a friendly "still under review" message.
  Future<User?> loginOrg({
    required String email,
    required String password,
  }) async {
    UserCredential result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    User? user = result.user;

    if (user == null) {
      return null;
    }
    // DocumentSnapshot holds the data of a Firestore document at a point in time
    // Source: https://firebase.flutter.dev/docs/firestore/usage/
    DocumentSnapshot<Map<String, dynamic>> doc =
        await _db.collection('organizations').doc(user.uid).get();

    if (!doc.exists) {
      await _auth.signOut();
      return null;
    }

    final data = doc.data();
    final status = (data?['status'] as String? ?? '').toLowerCase();

    // signOut() signs the current user out of Firebase Auth
    // Source: https://firebase.flutter.dev/docs/auth/usage/
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

  // signOut() signs the current user out of Firebase Auth
  // Source: https://firebase.flutter.dev/docs/auth/usage/
  Future<void> signOut() async { //logs user out
    await _auth.signOut();
  }

  // authStateChanges() returns a Stream that updates whenever the user signs in or out
  // Source: https://firebase.google.com/docs/auth/flutter/start
  Stream<User?> get user { // real time stream. tells if user is logged in or not
    return _auth.authStateChanges();
  }
}
