import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hooked/database/friend_service.dart';

class FriendRequestsPage extends StatefulWidget {
  final List<String> friendRequests;

  const FriendRequestsPage({Key? key, required this.friendRequests}) : super(key: key);

  @override
  State<FriendRequestsPage> createState() => _FriendRequestsPageState();
}

class _FriendRequestsPageState extends State<FriendRequestsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _emailController = TextEditingController();
  final FriendService _friendService = FriendService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Freundesanfragen')),
        body: const Center(
          child: Text('Du bist nicht eingeloggt.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Freunde'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.send), text: 'Anfrage senden'),
            Tab(icon: Icon(Icons.inbox), text: 'Erhaltene Anfragen'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSendFriendRequestTab(currentUser.uid),
          _buildReceivedRequestsTab(currentUser.uid),
        ],
      ),
    );
  }

  Widget _buildSendFriendRequestTab(String userId) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'E-Mail-Adresse des Freundes',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              final email = _emailController.text.trim();

              if (email.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Bitte E-Mail eingeben.')),
                );
                return;
              }

              try {
                await _friendService.sendFriendRequest(userId, email);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Freundesanfrage gesendet!')),
                );
                _emailController.clear();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Fehler: ${e.toString()}')),
                );
              }
            },
            child: const Text('Anfrage senden'),
          ),
        ],
      ),
    );
  }

  Widget _buildReceivedRequestsTab(String userId) {
    return ListView.builder(
      itemCount: widget.friendRequests.length,
      itemBuilder: (context, index) {
        final friendId = widget.friendRequests[index];
        return ListTile(
          title: Text('Anfrage von Benutzer-ID: $friendId'),
          trailing: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.check),
                onPressed: () async {
                  await _friendService.acceptFriendRequest(userId, friendId);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Freundesanfrage akzeptiert!')),
                  );
                  setState(() {
                    widget.friendRequests.remove(friendId);
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () async {
                  await _friendService.declineFriendRequest(userId, friendId);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Freundesanfrage abgelehnt.')),
                  );
                  setState(() {
                    widget.friendRequests.remove(friendId);
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }
}