import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../drawer.dart';
import '../components/themetoggle.dart';

class TripsListPage extends StatelessWidget {
  const TripsListPage({Key? key}) : super(key: key);

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
        title: const Text('Your Trips'),
        backgroundColor: primaryColor, // Same background color as FishPage
        actions: const [ThemeToggleWidget()],
      ),
      drawer: const CustomDrawer(),
      body: currentUser == null
          ? const Center(
              child: Text('Please log in to view your trips.'),
            )
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('trips')
                  .where('creatorId', isEqualTo: currentUser.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No trips found.'));
                }

                final trips = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: trips.length,
                  itemBuilder: (context, index) {
                    final trip = trips[index];
                    final tripData = trip.data() as Map<String, dynamic>;

                    return ListTile(
                      title: Text(tripData['name']),
                      subtitle: Text('Date: ${tripData['date']}'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                TripDetailsPage(tripId: trip.id),
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
    // Grab the same color used in fish.dart:
    Color primaryColor = Theme.of(context).colorScheme.primaryContainer;

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
        title: const Text('Trip Details'),
        backgroundColor: primaryColor, // Same color here, too
        actions: const [ThemeToggleWidget()],
      ),
      drawer: const CustomDrawer(),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('trips').doc(tripId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Trip not found.'));
          }

          final tripData = snapshot.data!.data() as Map<String, dynamic>;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Name: ${tripData['name']}',
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 10),
                Text('Date: ${tripData['date']}'),
                const SizedBox(height: 10),
                Text('Participants: ${tripData['participants'].join(', ')}'),
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