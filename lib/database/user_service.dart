import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooked/models/fishingSpot.dart';
import 'package:hooked/models/user.dart' as model;

final CollectionReference userRef =
    FirebaseFirestore.instance.collection('User');

Future<DocumentReference?> getUserByEmail(String email) async {
  try {
    QuerySnapshot querySnapshot =
        await userRef.where('email', isEqualTo: email).get();
    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first.reference;
    }
    return null;
  } catch (e) {
    print('Error fetching user by email: $e');
    return null;
  }
}

Future<model.User?> getUser(String docId) async {
  try {
    DocumentSnapshot doc = await userRef.doc(docId).get();
    if (!doc.exists) {
      return null;
    }
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return model.User.fromMap(data, docId);
  } catch (e) {
    print('Error fetching user by ID: $e');
    return null;
  }
}

Future<bool> createUser(model.User user) async {
  try {
    // Use doc(user.id).set(...) so the doc ID == user.id (Auth UID)
    await userRef.doc(user.id).set(user.toMap());
    print('User created successfully at doc ID = ${user.id}');
    return true;
  } catch (e) {
    print('Error creating user: $e');
    return false;
  }
}

Future<bool> updateUser(String docId, Map<String, dynamic> updates) async {
  try {
    await userRef.doc(docId).update(updates);
    print('User updated successfully');
    return true;
  } catch (e) {
    print('Error updating user: $e');
    return false;
  }
}

Future<bool> deleteUser(String docId) async {
  try {
    await userRef.doc(docId).delete();
    print('User deleted successfully');
    return true;
  } catch (e) {
    print('Error deleting user: $e');
    return false;
  }
}

Future<bool> doesUserExist(String email) async {
  try {
    QuerySnapshot querySnapshot =
        await userRef.where('email', isEqualTo: email).get();
    return querySnapshot.docs.isNotEmpty;
  } catch (e) {
    print('Error checking user existence: $e');
    return false;
  }
}

// For fishing spots (unchanged)
Future<model.User?> getUserForSpot(FishingSpot fishingSpot) async {
  if (fishingSpot.creator == null) {
    return null;
  }

  try {
    DocumentSnapshot userDoc = await userRef.doc(fishingSpot.creator!.id).get();
    if (userDoc.exists) {
      return model.User.fromMap(
          userDoc.data() as Map<String, dynamic>, userDoc.id);
    } else {
      return null;
    }
  } catch (e) {
    print('Error fetching user document: $e');
    return null;
  }
}
