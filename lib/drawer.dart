import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    Color primaryColor = Theme.of(context).colorScheme.primaryContainer;
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: primaryColor,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                Image.asset(
                  'assets/hooked_icon-removebg.png',
                  height: 115,
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.map),
            title: const Text('Map'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/map');
            },
          ),
          ListTile(
            leading: const Icon(Icons.location_on),
            title: const Text('Fishing Spots'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/fishing_spots');
            },
          ),
          ListTile(
            leading: const Icon(FontAwesomeIcons.fish),
            title: const Text('Fish'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/fish');
            },
          ),
          ListTile(
          leading: const Icon(Icons.group),
          title: const Text('Friends'),
          onTap: () {
           Navigator.pop(context);
           Navigator.pushNamed(context, '/friends');
          },
        ),
          ListTile(
            leading: const Icon(Icons.trip_origin),
            title: const Text('Create Trip'),
            onTap: () {
              print('Navigiere zu Trips');
              Navigator.pop(context);
              Navigator.pushNamed(context, '/trips');
            },
          ),
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text('My Trips'), // Eintrag für die Trips-Liste
            onTap: () {
              print('Navigiere zu Trips List');
              Navigator.pop(context);
              Navigator.pushNamed(context, '/trips_list');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Logout'),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
