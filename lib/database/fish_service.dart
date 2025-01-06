import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooked/models/fish.dart';
import 'package:hooked/models/fishingSpot.dart';

final CollectionReference fishRef =
    FirebaseFirestore.instance.collection('Fish');

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
