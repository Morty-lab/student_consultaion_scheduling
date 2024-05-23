import 'package:facultyconsultationscheduling/views/consultations.dart';
import 'package:facultyconsultationscheduling/views/loginPage.dart';
import 'package:facultyconsultationscheduling/widgets/customDrawable.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
      appBar: AppBar(
        title: Text('Faculty Consultation Scheduling', style: TextStyle(color: Colors.blue.shade900),),
        backgroundColor: Colors.white, // Set background color to white
        elevation: 0, // Set elevation to 0
        iconTheme: IconThemeData(color: Colors.blue.shade900), // Set icon color to blue shade 900
      ),
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
