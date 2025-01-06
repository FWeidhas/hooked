import 'package:cloud_firestore/cloud_firestore.dart';
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
