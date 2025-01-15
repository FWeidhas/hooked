import 'package:flutter/material.dart';
import 'package:hooked/database/trip_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // <-- Add this import for date formatting
import '../components/themetoggle.dart';
import 'package:hooked/models/fishingSpot.dart';

class CreateTripPage extends StatefulWidget {
  const CreateTripPage({Key? key}) : super(key: key);

  @override
  _CreateTripPageState createState() => _CreateTripPageState();
}

class _CreateTripPageState extends State<CreateTripPage> {
  final TextEditingController nameController = TextEditingController();

  /// Store the final selected friend IDs here
  final List<String> selectedFriends = [];

  /// Store all friend data so we can display name/email in the dialog
  final List<Map<String, dynamic>> _allFriends = [];

  DateTime? selectedDate;
  List<FishingSpot> _allSpots = [];
  FishingSpot? _selectedSpot;

  final TripService tripService = TripService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _loadFishingSpots();
    _loadUserFriends();
  }

  /// Loads all FishingSpot documents for the spots dropdown
  Future<void> _loadFishingSpots() async {
    try {
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('FishingSpot').get();

      final spots = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return FishingSpot.fromMap(data, doc.id);
      }).toList();

      setState(() {
        _allSpots = spots;
      });
    } catch (e) {
      print('Error loading fishing spots: $e');
    }
  }

  /// Loads the current user's "contacts" (friend IDs),
  /// and fetches each friend's email so we can display it
  Future<void> _loadUserFriends() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    try {
      final docSnap = await FirebaseFirestore.instance
          .collection('User')
          .doc(currentUser.uid)
          .get();

      if (!docSnap.exists) {
        print('Current user doc not found!');
        return;
      }

      final userData = docSnap.data() as Map<String, dynamic>;
      final List<dynamic> contactIds = userData['contacts'] ?? [];

      // We'll gather a list of { 'id': friendId, 'email': friendEmail }
      final List<Map<String, dynamic>> friends = [];

      for (var friendId in contactIds) {
        final friendDoc = await FirebaseFirestore.instance
            .collection('User')
            .doc(friendId)
            .get();

        if (friendDoc.exists) {
          final data = friendDoc.data() as Map<String, dynamic>;
          final email = data['email'] ?? 'No email';
          friends.add({
            'id': friendId,
            'email': email,
          });
        }
      }

      setState(() {
        _allFriends.clear();
        _allFriends.addAll(friends);
      });
    } catch (e) {
      print('Error loading user friends: $e');
    }
  }

  /// Pick only the date (no time)
  void pickDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  /// Opens a dialog listing all friends with checkboxes so we can select multiple friend IDs
  Future<void> _showFriendSelectionDialog() async {
    // We'll keep a temporary set of selected IDs so user can confirm
    final Set<String> tempSelected = Set.of(selectedFriends);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Friends'),
          content: SingleChildScrollView(
            child: Column(
              children: _allFriends.map((friend) {
                final friendId = friend['id'] as String;
                final friendEmail = friend['email'] as String;

                final isSelected = tempSelected.contains(friendId);
                return CheckboxListTile(
                  title: Text(friendEmail),
                  value: isSelected,
                  onChanged: (bool? checked) {
                    if (checked == true) {
                      tempSelected.add(friendId);
                    } else {
                      tempSelected.remove(friendId);
                    }
                    // We call setState inside the dialog builder
                    (context as Element).markNeedsBuild();
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Cancel, do nothing
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Confirm selection
                setState(() {
                  selectedFriends.clear();
                  selectedFriends.addAll(tempSelected);
                });
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser;
    final Color primaryColor = Theme.of(context).colorScheme.primaryContainer;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Trip'),
        backgroundColor: primaryColor,
        actions: const [ThemeToggleWidget()],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: currentUser == null
            ? const Center(child: Text('Please log in to create a trip.'))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Trip Name
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Trip Name'),
                  ),
                  const SizedBox(height: 20),

                  // Select Date
                  ElevatedButton(
                    onPressed: () => pickDate(context),
                    child: Text(
                      selectedDate == null
                          ? 'Select Date'
                          : // Use intl to format date only
                            'Date: ${DateFormat('yyyy-MM-dd').format(selectedDate!)}',
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Add Friends - multi selection
                  ElevatedButton(
                    onPressed: _allFriends.isEmpty
                        ? null
                        : () {
                            _showFriendSelectionDialog();
                          },
                    child: Text('Add Friends (${selectedFriends.length})'),
                  ),
                  const SizedBox(height: 20),

                  // Single dropdown for picking one spot
                  const Text(
                    'Select a Fishing Spot:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  if (_allSpots.isEmpty)
                    const Text('No fishing spots found or still loading...')
                  else
                    DropdownButton<FishingSpot>(
                      value: _selectedSpot,
                      hint: const Text('Choose a spot'),
                      items: _allSpots.map((spot) {
                        return DropdownMenuItem<FishingSpot>(
                          value: spot,
                          child: Text(spot.title ?? 'Untitled Spot'),
                        );
                      }).toList(),
                      onChanged: (FishingSpot? newValue) {
                        setState(() {
                          _selectedSpot = newValue;
                        });
                      },
                    ),

                  const Spacer(),

                  // Create Trip button
                  ElevatedButton(
                    onPressed: () async {
                      if (selectedDate == null || nameController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please fill in all required fields.'),
                          ),
                        );
                        return;
                      }

                      final spotsToAdd = <String>[];
                      if (_selectedSpot != null) {
                        spotsToAdd.add(_selectedSpot!.id!);
                      }

                      await tripService.createTrip(
                        creatorId: currentUser.uid,
                        name: nameController.text.trim(),
                        participants: selectedFriends, // multiple friend IDs
                        spots: spotsToAdd,
                        date: selectedDate!,
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Trip created successfully!'),
                        ),
                      );

                      Navigator.pop(context);
                    },
                    child: const Text('Create Trip'),
                  ),
                ],
              ),
      ),
    );
  }
}
