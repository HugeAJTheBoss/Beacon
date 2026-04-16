import 'package:firebase_auth/firebase_auth.dart'; // auth
import 'package:cloud_firestore/cloud_firestore.dart'; //database

// Flutter foundation library (provides debugPrint)
// Source: https://api.flutter.dev/flutter/foundation/foundation-library.html
import 'package:flutter/foundation.dart';


// Custom exception classes - learned from:
// https://www.tutorialspoint.com/dart_programming/dart_programming_exceptions.htm
// https://developermemos.com/posts/custom-exceptions-dart/
class PendingApprovalException implements Exception {
  const PendingApprovalException();
}

class AccountNotApprovedException implements Exception {
  const AccountNotApprovedException();
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance; // creates singleton
  final FirebaseFirestore _db = FirebaseFirestore.instance; // read and write to database

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

  // Registers a new organisation using Firebase Auth + Firestore
  // Learned from: https://www.bacancytechnology.com/blog/email-authentication-using-firebase-auth-and-flutter
  // and: https://firebase.google.com/docs/auth/flutter/password-auth
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
      // Source: https://firebase.google.com/docs/auth/flutter/password-auth
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      //Extracts the actual user object
      User? user = result.user;

      //Creates a document in Firestore
      if (user != null) {
        // .set() creates a Firestore document at a specific path (Document ID = user UID)
        // Tutorial reference: https://www.geeksforgeeks.org/flutter-read-and-write-data-on-firebase/
        await _db.collection('organizations').doc(user.uid).set({ //Document ID = user UID
          'orgName': orgName,
          'email': email,
          'webURL': webURL,
          'regNumber': regNumber,
          'orgDescription': orgDescription,
          'status': 'pending',
          // Source: https://firebase.flutter.dev/docs/firestore/usage/
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
  // Tutorial reference: https://dev.to/kcl/flutter-firebase-authentication-email-and-password-1g1p
  Future<User?> loginOrg({
    required String email,
    required String password,
  }) async {

    // signInWithEmailAndPassword signs in a user with email and password
    // Source: https://firebase.google.com/docs/auth/flutter/password-auth
    //logs user in
    UserCredential result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    User? user = result.user; //gets logged in user

    if (user == null) {
      return null;
    }

    // DocumentSnapshot holds the data of a Firestore document at a point in time
    // Source: https://firebase.flutter.dev/docs/firestore/usage/
    DocumentSnapshot<Map<String, dynamic>> doc =
        await _db.collection('organizations').doc(user.uid).get();

    if (!doc.exists) { //logs user out if account doesn't exist
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