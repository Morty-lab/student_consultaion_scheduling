import 'package:facultyconsultationscheduling/views/loginPage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:facultyconsultationscheduling/services/auth_service.dart'; // Assuming you have an AuthService for user-related operations
import 'package:facultyconsultationscheduling/models/app_user.dart'; // Assuming you have an AppUser model for user data

class MainView extends StatefulWidget {
  @override
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  User? user;
  FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  Future<void> getUserData() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      // Check the user's role in Firestore
      DocumentSnapshot docSnapshot =
          await _firestore.collection('users').doc(currentUser.uid).get();
      if (docSnapshot.exists && docSnapshot.get('role') != 'student') {
        // If the user is not a student, sign them out
        await _auth.signOut();
        // Redirect to the login screen
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (_) => LoginScreen()));
      } else {
        // If the user is a student or no role is set, proceed normally
        setState(() {
          user = currentUser;
        });
      }
    } else {
      // If there is no current user, redirect to the login screen
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (_) => LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Main View'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Welcome ${user?.email ?? 'Guest'},', // Displaying guest if no user is found
              style: Theme.of(context).textTheme.headline4,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Sign out the user
                await _auth.signOut();
                // Navigate back to the login page
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (_) =>
                        LoginScreen())); // Ensure LoginPage is the correct route
              },
              child: Text('Log Out'),
            ),
          ],
        ),
      ),
    );
  }
}
