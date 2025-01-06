import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooked/models/fishingSpot.dart';

final firestoreInstance = FirebaseFirestore.instance;
final CollectionReference fishingSpotRef =
    firestoreInstance.collection('FishingSpot');

Future<void> addFishingSpot(FishingSpot fishingSpot) async {
  try {
    final docRef = await fishingSpotRef.add(fishingSpot.toMap());
    // Optionally update the id of the FishingSpot object with the Firestore document ID
    fishingSpot.id = docRef.id;
  } catch (e) {
    print('Error adding fishing spot: $e');
    throw e;
  }
}

// Get all fishing spots
Stream<QuerySnapshot> getAllFishingSpots() {
  return fishingSpotRef.snapshots();
}

// Update fishing spot
Future<void> updateFishingSpot(String docId, FishingSpot fishingSpot) async {
  await fishingSpotRef.doc(docId).update(fishingSpot.toMap());
}

// Delete fishing spot
Future<void> deleteFishingSpot(String docId) async {
  await fishingSpotRef.doc(docId).delete();
}

// Get specific fishing spot by ID
Future<FishingSpot?> getFishingSpot(String docId) async {
  DocumentSnapshot doc = await fishingSpotRef.doc(docId).get();
  if (!doc.exists) {
    return null;
  }
  Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
  return FishingSpot(
    id: data['id'],
    title: data['title'],
    description: data['description'],
    picture: data['picture'],
    latitude: data['latitude'],
    longitude: data['longitude'],
    creator: data['creator'],
    fishes: data['fishes'],
  );
}
