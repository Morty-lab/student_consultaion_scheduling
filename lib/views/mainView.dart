import 'package:facultyconsultationscheduling/models/faculty.dart';
import 'package:facultyconsultationscheduling/views/calendar.dart';
import 'package:facultyconsultationscheduling/views/fac.dart';
import 'package:facultyconsultationscheduling/views/history.dart';
import 'package:facultyconsultationscheduling/views/profile.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:facultyconsultationscheduling/views/consultations.dart';
import 'package:facultyconsultationscheduling/views/loginPage.dart';
import 'package:facultyconsultationscheduling/widgets/customDrawable.dart';

class MainView extends StatefulWidget {
  @override
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  User? user;
  FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Widget currentPage = Consultations();

  // Function to get header title based on currentPage
  String getHeaderTitle() {
    if (currentPage is Consultations) {
      return 'Consultations';
    }
    if (currentPage is Fac) {
      return 'Faculty';
    }
    if (currentPage is Profile) {
      return 'Profile';
    }
    if (currentPage is History) {
      return 'History';
    }
    if (currentPage is Calendar) {
      return 'Calendar';
    }
    // Add more cases for other pages as needed
    return 'Default Title';
  }

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  Future<void> getUserData() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      DocumentSnapshot docSnapshot =
          await _firestore.collection('users').doc(currentUser.uid).get();
      if (docSnapshot.exists && docSnapshot.get('role') != 'student') {
        await _auth.signOut();
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (_) => LoginScreen()));
      } else {
        setState(() {
          user = currentUser;
        });
      }
    } else {
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (_) => LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    String headerTitle = getHeaderTitle();

    return Scaffold(
      drawer: CustomDrawer(
        onPageChanged: (page) {
          setState(() {
            currentPage = page;
          });
        },
        currentPage: currentPage,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 1000) {
            // For smaller screens (like phones), show a CustomDrawer toggle button
            return Scaffold(
              appBar: AppBar(
                elevation: 0,
                backgroundColor: Colors.white,
                title: Text(
                  headerTitle,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 22, 96, 165),
                  ),
                ),
                centerTitle: false,
                leading: IconButton(
                  icon: Icon(Icons.menu),
                  color: Color.fromARGB(255, 22, 96, 165),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                ),
              ),
              body: currentPage,
            );
          } else {
            // For larger screens (like tablets or desktops), use CustomDrawer
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 300.0,
                  child: CustomDrawer(
                    onPageChanged: (page) {
                      setState(() {
                        currentPage = page;
                      });
                    },
                    currentPage: currentPage,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 16.0,
                        ),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 255, 255, 255),
                        ),
                        child: Text(
                          headerTitle,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 22, 96, 165),
                          ),
                        ),
                      ),
                      Expanded(
                        child: currentPage,
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}

void main() => runApp(MaterialApp(home: MainView()));
