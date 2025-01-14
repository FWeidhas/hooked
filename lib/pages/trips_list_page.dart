import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../drawer.dart';
import '../components/themetoggle.dart';

class TripsListPage extends StatelessWidget {
  const TripsListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
        backgroundColor: primaryColor,
        actions: const [ThemeToggleWidget()],
      ),
      drawer: const CustomDrawer(),

      // The main content
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

                    // Parse the date string
                    final dateString = tripData['date'] ?? '';
                    DateTime? dateTime;
                    try {
                      dateTime = DateTime.parse(dateString);
                    } catch (e) {
                      // If parsing fails, do nothing special
                    }

                    // Format the date if parse was successful
                    String formattedDate = 'Unknown';
                    if (dateTime != null) {
                      formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
                    }

                    return ListTile(
                      title: Text(tripData['name'] ?? 'No Trip Name'),
                      subtitle: Text('Date: $formattedDate'),
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

      // Add the floatingActionButton to create a new Trip
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: () {
          // Navigate to the create trip page
          Navigator.pushNamed(context, '/trips');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TripDetailsPage extends StatelessWidget {
  final String tripId;
  const TripDetailsPage({Key? key, required this.tripId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
        backgroundColor: primaryColor,
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

          // Parse and format date
          final dateString = tripData['date'] ?? '';
          DateTime? dateTime;
          try {
            dateTime = DateTime.parse(dateString);
          } catch (e) {
            // ignore
          }
          String formattedDate = 'Unknown';
          if (dateTime != null) {
            formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
          }

          // Participants
          final participants = tripData['participants'] as List<dynamic>? ?? [];
          final spots = tripData['spots'] as List<dynamic>? ?? [];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Name: ${tripData['name'] ?? 'No Trip Name'}',
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 10),
                Text('Date: $formattedDate'),
                const SizedBox(height: 10),
                Text('Participants: ${participants.join(', ')}'),
                const SizedBox(height: 10),

                if (spots.isEmpty)
                  const Text('Spot: None selected')
                else
                  FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('FishingSpot')
                        .doc(spots[0])
                        .get(),
                    builder: (context, spotSnapshot) {
                      if (spotSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Text('Loading spot...');
                      }
                      if (!spotSnapshot.hasData ||
                          !spotSnapshot.data!.exists) {
                        return Text('Spot not found: ${spots[0]}');
                      }

                      final spotData =
                          spotSnapshot.data!.data() as Map<String, dynamic>;
                      final spotName = spotData['title'] ?? 'No Title';

                      return Text('Spot: $spotName');
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}