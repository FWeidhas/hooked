import 'package:flutter/material.dart';
import 'package:hooked/database/trip_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../components/themetoggle.dart';
import 'package:hooked/models/fishingSpot.dart';

class CreateTripPage extends StatefulWidget {
  const CreateTripPage({Key? key}) : super(key: key);

  @override
  _CreateTripPageState createState() => _CreateTripPageState();
}

class _CreateTripPageState extends State<CreateTripPage> {
  final TextEditingController nameController = TextEditingController();

  final List<String> selectedFriends = [];
  DateTime? selectedDate;

  List<FishingSpot> _allSpots = [];
  FishingSpot? _selectedSpot;

  final TripService tripService = TripService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _loadFishingSpots();
  }

  Future<void> _loadFishingSpots() async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('FishingSpot')
          .get();

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

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser;
    Color primaryColor = Theme.of(context).colorScheme.primaryContainer; 

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
                          : 'Date: ${selectedDate!.toLocal()}',
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Add Friends (placeholder)
                  ElevatedButton(
                    onPressed: () {
                      // Placeholder
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
                        participants: selectedFriends,
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