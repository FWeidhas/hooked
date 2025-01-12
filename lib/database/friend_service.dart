import 'package:cloud_firestore/cloud_firestore.dart';

class FriendService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendFriendRequest(String senderId, String receiverEmail) async {
    final usersCollection = _firestore.collection('users');
    
    final querySnapshot = await usersCollection.where('email', isEqualTo: receiverEmail).get();

    if (querySnapshot.docs.isEmpty) {
      throw Exception('Benutzer mit dieser E-Mail wurde nicht gefunden.');
    }

    final receiverId = querySnapshot.docs.first.id;

    await usersCollection.doc(receiverId).update({
      'friendRequests': FieldValue.arrayUnion([senderId]),
    });
  }

  Future<void> acceptFriendRequest(String userId, String friendId) async {
    final usersCollection = _firestore.collection('users');

    await usersCollection.doc(userId).update({
      'friendRequests': FieldValue.arrayRemove([friendId]),
      'friends': FieldValue.arrayUnion([friendId]),
    });

    await usersCollection.doc(friendId).update({
      'friends': FieldValue.arrayUnion([userId]),
    });
  }

  Future<void> declineFriendRequest(String userId, String friendId) async {
    final usersCollection = _firestore.collection('users');

    // Entferne die Anfrage
    await usersCollection.doc(userId).update({
      'friendRequests': FieldValue.arrayRemove([friendId]),
    });
  }
}