import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../drawer.dart';
import '../components/themetoggle.dart';
import '../database/friend_service.dart';

class AddFriendPage extends StatefulWidget {
  const AddFriendPage({Key? key}) : super(key: key);

  @override
  State<AddFriendPage> createState() => _AddFriendPageState();
}

class _AddFriendPageState extends State<AddFriendPage> {
  final _emailController = TextEditingController();
  final _friendService = FriendService();
  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    Color primaryColor = Theme.of(context).colorScheme.primaryContainer;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Friend'),
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
      body: currentUser == null
          ? const Center(child: Text('Please log in first.'))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Friend\'s Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      final email = _emailController.text.trim();
                      if (email.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter an email')),
                        );
                        return;
                      }
                      try {
                        await _friendService.sendFriendRequest(
                          currentUser!.uid,
                          email,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Friend request sent!'),
                          ),
                        );
                        Navigator.pop(context); // Go back to the friends list
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.toString())),
                        );
                      }
                    },
                    child: const Text('Send Request'),
                  ),
                ],
              ),
            ),
    );
  }
}
