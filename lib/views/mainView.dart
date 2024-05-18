import 'package:facultyconsultationscheduling/views/consultations.dart';
import 'package:facultyconsultationscheduling/views/loginPage.dart';
import 'package:facultyconsultationscheduling/widgets/customDrawable.dart';
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
  Widget currentPage = Consultations();

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
      appBar: AppBar(),
      drawer: CustomDrawer(onPageChanged: (page) {
        setState(() {
          currentPage = page;
        });
        Navigator.pop(context); // Close the drawer
      }),
      body: currentPage,
    );
  }
}
