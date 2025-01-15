import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../drawer.dart';
import '../components/themetoggle.dart';
import '../database/friend_service.dart';
import '../main.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({Key? key}) : super(key: key);

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  final _auth = FirebaseAuth.instance;
  final _friendService = FriendService();

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primaryContainer;
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Friends'),
          backgroundColor: primaryColor,
          leading: Builder(
            builder: (context) {
              return IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
              );
            },
          ),
          actions: const [ThemeToggleWidget()],
        ),
        drawer: const CustomDrawer(),
        body: const Center(child: Text('Please log in first.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends'),
        backgroundColor: primaryColor,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            );
          },
        ),
        actions: const [ThemeToggleWidget()],
      ),
      drawer: const CustomDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add_friend');
        },
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('User')
            .doc(currentUser.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('No user data found.'));
          }

          final userDoc = snapshot.data!;
          final userData = userDoc.data() as Map<String, dynamic>;

          final List<dynamic> contacts = userData['contacts'] ?? [];
          final List<dynamic> friendRequests = userData['friendRequests'] ?? [];

          return ListView(
            children: [
              const SizedBox(height: 16),
              _buildRequestsSection(friendRequests),
              const Divider(),
              _buildFriendsSection(contacts),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRequestsSection(List<dynamic> requestIds) {
    if (requestIds.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('No incoming requests.'),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Incoming Requests',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...requestIds.map((requesterId) {
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('User')
                  .doc(requesterId)
                  .get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const ListTile(
                    title: Text('Unknown request'),
                  );
                }
                final requesterData =
                    snapshot.data!.data() as Map<String, dynamic>;
                final requesterEmail = requesterData['email'] ?? 'No email';

                return ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: Text(requesterEmail),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check),
                        onPressed: () async {
                          final currentUser = FirebaseAuth.instance.currentUser;
                          if (currentUser != null) {
                            await _friendService.acceptFriendRequest(
                              currentUser.uid,
                              requesterId,
                            );
                            // 2) Use the global scaffoldMessenger
                            rootScaffoldMessengerKey.currentState?.showSnackBar(
                              SnackBar(content: Text('Accepted $requesterEmail')),
                            );
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () async {
                          final currentUser = FirebaseAuth.instance.currentUser;
                          if (currentUser != null) {
                            await _friendService.declineFriendRequest(
                              currentUser.uid,
                              requesterId,
                            );
                            rootScaffoldMessengerKey.currentState?.showSnackBar(
                              SnackBar(content: Text('Declined $requesterEmail')),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildFriendsSection(List<dynamic> friendIds) {
    if (friendIds.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('No friends yet.'),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'My Friends',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...friendIds.map((friendId) {
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('User')
                  .doc(friendId)
                  .get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const ListTile(
                    title: Text('Unknown friend'),
                  );
                }
                final friendData =
                    snapshot.data!.data() as Map<String, dynamic>;
                final friendEmail = friendData['email'] ?? 'No email';
                return ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(friendEmail),
                );
              },
            );
          }).toList(),
        ],
      ),
    );
  }
}
