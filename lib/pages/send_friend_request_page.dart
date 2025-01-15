import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SendFriendRequestPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> sendFriendRequest(String senderId, String receiverEmail) async {
    final usersCollection = firestore.collection('User');

    final querySnapshot = await usersCollection.where('email', isEqualTo: receiverEmail).get();

    if (querySnapshot.docs.isEmpty) {
      throw Exception('Benutzer mit dieser E-Mail wurde nicht gefunden.');
    }

    final receiverId = querySnapshot.docs.first.id;

    await usersCollection.doc(receiverId).update({
      'friendRequests': FieldValue.arrayUnion([senderId]),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Freund hinzufügen')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'E-Mail-Adresse',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final currentUser = FirebaseAuth.instance.currentUser;

                if (currentUser == null) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Du bist nicht eingeloggt.'),
                  ));
                  return;
                }

                try {
                  await sendFriendRequest(
                    currentUser.uid,
                    emailController.text.trim(),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Freundesanfrage gesendet!'),
                  ));
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(e.toString()),
                  ));
                }
              },
              child: Text('Anfrage senden'),
            ),
          ],
        ),
      ),
    );
  }
}
