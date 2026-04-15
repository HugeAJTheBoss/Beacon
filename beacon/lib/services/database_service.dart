import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Map<String, dynamic> _mapOpportunityDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();

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

  Future<void> deleteOpportunity(String id) async {
    await _db.collection('opportunities').doc(id).delete();
  }

  Future<void> updateOpportunity(String id, Map<String, dynamic> data) async {
    await _db.collection('opportunities').doc(id).update(data);
  }

  Stream<List<Map<String, dynamic>>> getOpportunities() {
    return _db.collection('opportunities').snapshots().map((snapshot) {
      return snapshot.docs.map(_mapOpportunityDoc).toList();
    });
  }

  // real-time stream of opportunities
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