import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendService {
  final _firestore = FirebaseFirestore.instance;

  /// Send a friend request by [receiverEmail]:
  /// 1) Find the user with that email
  /// 2) Add the current user's UID to their 'friendRequests'
  Future<void> sendFriendRequest(String senderId, String receiverEmail) async {
    final users = _firestore.collection('User');
    final querySnapshot = await users.where('email', isEqualTo: receiverEmail).get();

    if (querySnapshot.docs.isEmpty) {
      throw Exception('User with email "$receiverEmail" not found.');
    }

    final receiverDoc = querySnapshot.docs.first;
    final receiverId = receiverDoc.id;

    // Optional: prevent sending request to yourself
    if (receiverId == senderId) {
      throw Exception('Cannot send a friend request to yourself.');
    }

    // Add senderId to the receiver's friendRequests array
    await users.doc(receiverId).update({
      'friendRequests': FieldValue.arrayUnion([senderId]),
    });
  }

  /// Accept a friend request:
  /// - Remove [friendId] from the current user's 'friendRequests'
  /// - Add [friendId] to current user's 'contacts'
  /// - Add current user to [friendId]'s 'contacts'
  Future<void> acceptFriendRequest(String currentUserId, String friendId) async {
    final users = _firestore.collection('User');

    // Remove the request from current user
    await users.doc(currentUserId).update({
      'friendRequests': FieldValue.arrayRemove([friendId]),
      'contacts': FieldValue.arrayUnion([friendId]),
    });

    // Add currentUserId to friend’s contacts
    await users.doc(friendId).update({
      'contacts': FieldValue.arrayUnion([currentUserId]),
    });
  }

  /// Decline a friend request:
  /// - Just remove [friendId] from current user's 'friendRequests'
  Future<void> declineFriendRequest(String currentUserId, String friendId) async {
    final users = _firestore.collection('User');
    await users.doc(currentUserId).update({
      'friendRequests': FieldValue.arrayRemove([friendId]),
    });
  }
}
