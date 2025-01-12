import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TripsListPage extends StatelessWidget {
  const TripsListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Deine Trips')),
        body: const Center(
          child: Text('Bitte loggen Sie sich ein, um Ihre Trips zu sehen.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Deine Trips')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('trips')
            .where('creatorId', isEqualTo: currentUser.uid) // Lade nur die Trips des aktuellen Benutzers
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Keine Trips gefunden.'));
          }

          final trips = snapshot.data!.docs;

          return ListView.builder(
            itemCount: trips.length,
            itemBuilder: (context, index) {
              final trip = trips[index];
              final tripData = trip.data() as Map<String, dynamic>;

              return ListTile(
                title: Text(tripData['name']),
                subtitle: Text('Datum: ${tripData['date']}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TripDetailsPage(tripId: trip.id),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class TripDetailsPage extends StatelessWidget {
  final String tripId;

  const TripDetailsPage({Key? key, required this.tripId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trip Details')),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('trips').doc(tripId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Trip nicht gefunden.'));
          }

          final tripData = snapshot.data!.data() as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Name: ${tripData['name']}', style: const TextStyle(fontSize: 20)),
                const SizedBox(height: 10),
                Text('Datum: ${tripData['date']}'),
                const SizedBox(height: 10),
                Text('Teilnehmer: ${tripData['participants'].join(', ')}'),
                const SizedBox(height: 10),
                Text('Spots: ${tripData['spots'].join(', ')}'),
              ],
            ),
          );
        },
      ),
    );
  }
}
