import 'package:flutter/material.dart';
import 'package:hooked/database/trip_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateTripPage extends StatefulWidget {
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
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: Text('Neuen Trip erstellen')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Trip-Name'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => pickDate(context),
              child: Text(selectedDate == null
                  ? 'Datum auswählen'
                  : 'Datum: ${selectedDate!.toLocal()}'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Hier könnten Freunde angezeigt und ausgewählt werden
              },
              child: Text('Freunde hinzufügen (${selectedFriends.length})'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Hier könnten Spots angezeigt und ausgewählt werden
              },
              child: Text('Angel-Spots hinzufügen (${selectedSpots.length})'),
            ),
            Spacer(),
            ElevatedButton(
              onPressed: () async {
                if (currentUser == null || selectedDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Bitte alle Felder ausfüllen.'),
                  ));
                  return;
                }

                await tripService.createTrip(
                  creatorId: currentUser.uid,
                  name: nameController.text.trim(),
                  participants: selectedFriends,
                  spots: selectedSpots,
                  date: selectedDate!,
                );

                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Trip erfolgreich erstellt!'),
                ));

                Navigator.pop(context);
              },
              child: Text('Trip erstellen'),
            ),
          ],
        ),
      ),
    );
  }
}
