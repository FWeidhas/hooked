import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooked/models/fish.dart';
import 'package:hooked/models/fishingSpot.dart';
import 'package:hooked/database/fishing_spot_service.dart';

final CollectionReference fishRef =
    FirebaseFirestore.instance.collection('Fish');

Future<void> addFish(Fish fish) async {
  try {
    final docRef = await fishRef.add(fish.toMap());
    // Optionally update the id of the Fish object with the Firestore document ID
    fish.id = docRef.id;
  } catch (e) {
    print('Error adding fishing spot: $e');
    throw e;
  }
}

// Get all fishing spots
Stream<QuerySnapshot> getAllFishes() {
  return fishRef.snapshots();
}

// Update fishing spot
Future<void> updateFish(String docId, Fish fish) async {
  await fishRef.doc(docId).update(fish.toMap());
}

// Delete fishing spot
Future<void> deleteFish(String docId) async {
  bool hasReferences = await hasFishingSpotsWithFish(docId);
  if (hasReferences) {
    throw Exception(
        'Cannot delete fish. It is referenced by one or more fishing spots.');
  }
  await fishRef.doc(docId).delete();
}

Future<DocumentReference?> getFishByName(String name) async {
  QuerySnapshot querySnapshot =
      await fishRef.where('name', isEqualTo: name).get();
  if (querySnapshot.docs.isNotEmpty) {
    return querySnapshot.docs.first.reference;
  }
  return null;
}

Future<Fish?> getFish(String docId) async {
  DocumentSnapshot doc = await fishRef.doc(docId).get();
  if (!doc.exists) {
    return null;
  }
  Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
  return Fish(id: data['id'], name: data['name'], picture: data['picture']);
}

// Method to fetch all fish for a fishing spot
Future<List<Fish>> getFishesForSpot(FishingSpot fishingSpot) async {
  if (fishingSpot.fishes == null || fishingSpot.fishes!.isEmpty) {
    return [];
  }

  List<Fish> fishList = [];

  // Fetch each fish document
  for (DocumentReference fishRef in fishingSpot.fishes!) {
    try {
      DocumentSnapshot fishDoc = await fishRef.get();
      if (fishDoc.exists) {
        Fish fish = Fish.fromMap(
          fishDoc.data() as Map<String, dynamic>,
          fishDoc.id,
        );
        fishList.add(fish);
      }
    } catch (e) {
      print('Error fetching fish document: $e');
    }
  }

  return fishList;
}
