// Sources also used in auth_service.dart
// Cloud Firestore Flutter package:  https://firebase.flutter.dev/docs/firestore/usage/
// Reading/writing Firestore docs:   https://firebase.google.com/docs/firestore
// GeeksforGeeks Firestore tutorial: https://www.geeksforgeeks.org/flutter-read-and-write-data-on-firebase/
// FieldValue.serverTimestamp():     https://firebase.flutter.dev/docs/firestore/usage/

import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // QueryDocumentSnapshot - represents a document returned from a Firestore query
  // Source: https://pub.dev/documentation/cloud_firestore/latest/cloud_firestore/QueryDocumentSnapshot-class.html
  Map<String, dynamic> _mapOpportunityDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();

    // doc.id - the unique document ID auto-assigned by Firestore
    // ?? operator provides a default value if the field is null (Dart null safety)
    // Source: https://dart.dev/null-safety
    return {
      'id': doc.id,
      'title': data['title'] ?? '',
      'org': data['orgName'] ?? '',
      'location': data['location'] ?? '',
      'date': data['date'] ?? '',
      'link': data['link'] ?? '',
      'description': data['description'] ?? '',
      'category': data['category'] ?? 'Other',
      'type': data['type'] ?? 'Event',
      'ageMin': data['ageMin'] ?? 0,
      'ageMax': data['ageMax'] ?? 99,
      'status': 'Upcoming',
      'websiteVisits': 0,
    };
  }

  // .add() creates a new Firestore document with an auto-generated ID
  // Unlike .set(), .add() generates the ID for you
  // Tutorial: https://www.geeksforgeeks.org/flutter-read-and-write-data-on-firebase/
    Future<void> createOpportunity({
    required String title,
    required String orgName,
    required String location,
    required String date,
    required String link,
    required String description,
    required String category,
    required String type,
    required int ageMin,
    required int ageMax,
    required String orgId,
    }) async {
    await _db.collection('opportunities').add({
        'title': title,
        'orgName': orgName,
        'location': location,
        'date': date,
        'link': link,
        'description': description,
        'category': category,
        'type': type,
        'ageMin': ageMin,
        'ageMax': ageMax,
        'orgId': orgId,
        'createdAt': FieldValue.serverTimestamp(),
    });
    }
  // .delete() removes a Firestore document by its ID
  // Tutorial: https://dev.to/tjgrapes/cloud-firestore-basics-in-flutter-how-to-get-add-edit-and-delete-data-in-cloud-firestore-demonstrated-in-a-real-flutter-app-2d06
  Future<void> deleteOpportunity(String id) async {
    await _db.collection('opportunities').doc(id).delete();
  }

  // .update() modifies specific fields in a document without overwriting the whole thing
  // Tutorial: https://dev.to/tjgrapes/cloud-firestore-basics-in-flutter-how-to-get-add-edit-and-delete-data-in-cloud-firestore-demonstrated-in-a-real-flutter-app-2d06
  Future<void> updateOpportunity(String id, Map<String, dynamic> data) async {
    await _db.collection('opportunities').doc(id).update(data);
  }

  // .snapshots() returns a real-time Stream that emits a new value whenever data changes
  // .map() transforms each snapshot into a List using _mapOpportunityDoc
  // Source: https://firebase.flutter.dev/docs/firestore/usage/
  // Dart streams: https://dart.dev/tutorials/language/streams
  Stream<List<Map<String, dynamic>>> getOpportunities() {
    return _db.collection('opportunities').snapshots().map((snapshot) {
      return snapshot.docs.map(_mapOpportunityDoc).toList();
    });
  }

  // real-time stream of opportunities
  // Tutorial: https://medium.com/@samra.sajjad0001/getting-started-with-firebase-firestore-in-flutter-a-comprehensive-guide-with-crud-operations-ec75f2188355
  Stream<List<Map<String, dynamic>>> getOrgOpportunities(String orgId) {
    return _db
        .collection('opportunities')
        .where('orgId', isEqualTo: orgId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map(_mapOpportunityDoc).toList();
    });
  }
}