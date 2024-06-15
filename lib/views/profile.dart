import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/app_user.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  AppUser? appUser;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    String? userID = auth.currentUser?.uid;
    if (userID != null) {
      await getUserDocument(userID);
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> getUserDocument(String userId) async {
    try {
      QuerySnapshot querySnapshot = await firestore.collection('users').get();
      for (var doc in querySnapshot.docs) {
        if (doc['id'] == userId) {
          print("User found!");
          appUser =
              AppUser.fromMap(doc.data()! as Map<String, dynamic>, userId);
          break;
        }
      }
    } catch (e) {
      print("Error getting user document: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = auth.currentUser;
    String? userID = user?.uid;

    return Scaffold(
      body: Container(
        color: const Color.fromARGB(255, 255, 255, 255),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        side: BorderSide(color: const Color.fromARGB(255, 220, 220, 220), width: 1.0),
                      ), // Add rounded corners
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 24.0),
                        child: LayoutBuilder(
                          builder:
                              (BuildContext context, BoxConstraints constraints) {
                            // Check width constraints to determine the layout
                            if (constraints.maxWidth < 600) {
                              // Mobile and smaller tablets: Student ID below Email
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Avatar and Name
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 50.0,
                                        backgroundImage: AssetImage(
                                            'lib/assets/images/avatar.jpg'),
                                      ),
                                      const SizedBox(width: 16.0),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Name',
                                              style: TextStyle(
                                                fontSize: 18.0,
                                                fontWeight: FontWeight.bold,
                                                color: Color.fromARGB(255, 22, 96, 165),
                                              ),
                                            ),
                                            Text(
                                              appUser?.name ?? 'Loading...',
                                              style: TextStyle(fontSize: 16.0),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(thickness: 1.0),
                                  const SizedBox(height: 16.0),
                                  // Email
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Email',
                                        style: TextStyle(
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold,
                                          color: Color.fromARGB(255, 22, 96, 165),
                                        ),
                                      ),
                                      const SizedBox(height: 8.0),
                                      Text(
                                        appUser?.email ?? 'Loading...',
                                        style: TextStyle(fontSize: 16.0),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16.0),
                                  // Student ID
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Student ID',
                                        style: TextStyle(
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold,
                                          color: Color.fromARGB(255, 22, 96, 165),
                                        ),
                                      ),
                                      const SizedBox(height: 8.0),
                                      Text(
                                        "2021000000",
                                        style: TextStyle(fontSize: 16.0),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            } else {
                              // Larger tablets and desktop: Email and Student ID side by side
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Avatar and Name
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 50.0,
                                        backgroundImage: AssetImage(
                                            'lib/assets/images/avatar.jpg'),
                                      ),
                                      const SizedBox(width: 16.0),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Name',
                                              style: TextStyle(
                                                fontSize: 18.0,
                                                fontWeight: FontWeight.bold,
                                                color: Color.fromARGB(255, 22, 96, 165),
                                              ),
                                            ),
                                            Text(
                                              appUser?.name ?? 'Loading...',
                                              style: TextStyle(fontSize: 16.0),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5.0),
                                  const Divider(thickness: 1.0),
                                  const SizedBox(height: 16.0),
                                  // Email and Student ID in Row
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Email',
                                              style: TextStyle(
                                                fontSize: 18.0,
                                                fontWeight: FontWeight.bold,
                                                color: Color.fromARGB(255, 22, 96, 165),
                                              ),
                                            ),
                                            const SizedBox(height: 8.0),
                                            Text(
                                              appUser?.email ?? 'Loading...',
                                              style: TextStyle(fontSize: 16.0),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 16.0),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Student ID',
                                              style: TextStyle(
                                                fontSize: 18.0,
                                                fontWeight: FontWeight.bold,
                                                color: Color.fromARGB(255, 22, 96, 165),
                                              ),
                                            ),
                                            const SizedBox(height: 8.0),
                                            Text(
                                              "2021000000",
                                              style: TextStyle(fontSize: 16.0),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            }
                          },
                        ),
                      ),
                    ),
            )
          ],
        ),
      ),
    );
  }
}
