import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

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
        'createdAt': FieldValue.serverTimestamp(),
    });
    }

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