import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooked/models/fishingSpot.dart';
import 'package:hooked/models/user.dart';

final CollectionReference userRef =
    FirebaseFirestore.instance.collection('User');

Future<DocumentReference?> getUserByEmail(String email) async {
  QuerySnapshot querySnapshot =
      await userRef.where('email', isEqualTo: email).get();
  if (querySnapshot.docs.isNotEmpty) {
    return querySnapshot.docs.first.reference;
  }
  return null;
}

Future<User?> getUser(String docId) async {
  DocumentSnapshot doc = await userRef.doc(docId).get();
  if (!doc.exists) {
    return null;
  }
  Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
  return User(
    id: data['id'],
    name: data['name'],
    surname: data['surname'],
    email: data['email'],
    contacts: data['contacts'],
  );
}

// Method to fetch the user for a fishing spot
Future<User?> getUserForSpot(FishingSpot fishingSpot) async {
  if (fishingSpot.creator == null) {
    return null;
  }

  try {
    DocumentSnapshot userDoc = await userRef.doc(fishingSpot.creator!.id).get();
    if (userDoc.exists) {
      return User.fromMap(userDoc.data() as Map<String, dynamic>, userDoc.id);
    } else {
      return null;
    }
  } catch (e) {
    print('Error fetching user document: $e');
    return null;
  }
}
