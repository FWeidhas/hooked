import 'package:cloud_firestore/cloud_firestore.dart';

class TripService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createTrip({
    required String creatorId,
    required String name,
    required List<String> participants,
    required List<String> spots,
    required DateTime date,
  }) async {
    final tripsCollection = _firestore.collection('trips');

    final tripData = {
      'name': name,
      'creatorId': creatorId,
      'participants': participants,
      'spots': spots,
      'date': date.toIso8601String(),
    };

    await tripsCollection.add(tripData);
  }

  Future<List<Map<String, dynamic>>> getTrips(String userId) async {
    final tripsCollection = _firestore.collection('trips');

    final querySnapshot = await tripsCollection
        .where('participants', arrayContains: userId)
        .get();

    return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }
}
