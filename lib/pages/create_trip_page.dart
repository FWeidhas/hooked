import 'package:flutter/material.dart';
import 'package:hooked/database/trip_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../drawer.dart';
import '../components/themetoggle.dart';

class CreateTripPage extends StatefulWidget {
  const CreateTripPage({Key? key}) : super(key: key);

  @override
  _CreateTripPageState createState() => _CreateTripPageState();
}

class _CreateTripPageState extends State<CreateTripPage> {
  final TextEditingController nameController = TextEditingController();
  final List<String> selectedFriends = [];
  final List<String> selectedSpots = [];
  DateTime? selectedDate;

  final TripService tripService = TripService();

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
    // Grab the same color used in fish.dart:
    Color primaryColor = Theme.of(context).colorScheme.primaryContainer;
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        title: const Text('Create Trip'),
        backgroundColor: primaryColor,
        actions: const [ThemeToggleWidget()],
      ),
      drawer: const CustomDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: currentUser == null
            ? const Center(
                child: Text('Please log in to create a trip.'),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Trip Name'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => pickDate(context),
                    child: Text(
                      selectedDate == null
                          ? 'Select Date'
                          : 'Date: ${selectedDate!.toLocal()}',
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Show a dialog or another screen for selecting friends
                    },
                    child: Text('Add Friends (${selectedFriends.length})'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Show a dialog or screen for selecting fishing spots
                    },
                    child: Text('Add Spots (${selectedSpots.length})'),
                  ),
                  const Spacer(),
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

                      await tripService.createTrip(
                        creatorId: currentUser.uid,
                        name: nameController.text.trim(),
                        participants: selectedFriends,
                        spots: selectedSpots,
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