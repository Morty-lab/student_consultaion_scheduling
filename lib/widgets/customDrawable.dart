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
              color: Colors.blue,
            ),
            child: Text(
              "Faculty Consultation Scheduling",
              style: TextStyle(color: Colors.white),
            ),
          ),
          ListTile(
            title: Text('Consultations'),
            onTap: () {
              onPageChanged(Consultations());
            },
          ),
          ListTile(
            title: Text('Calendar'),
            onTap: () {
              // onPageChanged(FileUploadingPage());
            },
          ),
          ListTile(
            title: Text('Profile'),
            onTap: () {
              // onPageChanged(TextToSpeech());
            },
          ),
          ListTile(
            title: Text('Logout'),
            onTap: () async {
              await _auth.signOut();
              // Navigate back to the login page
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => LoginScreen()));
            },
          ),
        ],
      ),
    );
  }
}
