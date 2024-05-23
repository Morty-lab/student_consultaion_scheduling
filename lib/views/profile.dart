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

  @override
  void initState() {
    super.initState();
    // Fetch data when the widget initializes
    // fetchData();
  }

  // Future<void> fetchData() async {
  //   String? userID = auth.currentUser?.uid;
  //   if (userID != null) {
  //     getUserDocument(userID);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    void getUserDocument(String userId) async {
      try {
        QuerySnapshot querySnapshot = await firestore.collection('users').get();
        for (var doc in querySnapshot.docs) {
          if (doc['id'] == userId) {
            print("User found!");
            // Ensure doc.data() is not null before calling fromMap
            if (doc.data() != null) {
              appUser = AppUser.fromMap(doc.data()! as Map<String, dynamic>,
                  userId); // Use! to assert non-null
            } else {
              print("No data found for user.");
            }
            break;
          }
        }
      } catch (e) {
        print("Error getting user document: $e");
      }
    }

    User? user = auth.currentUser;
    String? userID = user!.uid;
    getUserDocument("zMnr6AVgUrb5CU77BOnUBLA2yUM2");

    print(appUser?.name);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: IntrinsicHeight(
              // Wrap with IntrinsicHeight
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundImage:
                                  AssetImage('lib/assets/images/avatar.jpg'),
                            ),
                          ],
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Name',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue),
                            ),
                            SizedBox(height: 8),
                            Text(
                              appUser?.name as String,
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Email',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue),
                        ),
                        SizedBox(height: 8),
                        Text(
                          appUser?.email as String,
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Student ID',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "2021000000",
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
