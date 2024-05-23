import 'package:facultyconsultationscheduling/views/consultations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../views/loginPage.dart';

class CustomDrawer extends StatelessWidget {
  final ValueChanged<Widget> onPageChanged;

  const CustomDrawer({Key? key, required this.onPageChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseAuth _auth = FirebaseAuth.instance;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: Text(
              "Faculty Consultation Scheduling",
              style: TextStyle(color: Colors.blue.shade900),
            ),
          ),
          ListTile(
            leading: Icon(Icons.list),
            title: Text('Consultations'),
            onTap: () {
              onPageChanged(Consultations());
            },
          ),
          ListTile(
            leading: Icon(Icons.history),
            title: Text('Consultation History'),
            onTap: () {
              
            },
          ),
          ListTile(
            leading: Icon(Icons.calendar_today),
            title: Text('Calendar'),
            onTap: () {
              
            },
          ),
          ListTile(
            leading: Icon(Icons.people),
            title: Text('Faculties'),
            onTap: () {
              
            },
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Profile'),
            onTap: () {
              
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: () async {
              await _auth.signOut();
              
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => LoginScreen()));
            },
          ),

        ],
      ),
    );
  }
}
