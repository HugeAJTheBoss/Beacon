import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // real-time stream of opportunities
  Stream<List<Map<String, dynamic>>> getOpportunities() {
    return _db.collection('opportunities').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();

        return {
          'title': data['title'],
          'org': data['orgName'],
          'location': data['location'],
          'distance': data['distance'] ?? 0,
          'date': data['date'],
          'link': data['link'],
          'description': data['description'],
          'category': data['category'],
          'type': data['type'],
          'ageMin': data['ageMin'],
          'ageMax': data['ageMax'],
        };
      }).toList();
    });
  }
}