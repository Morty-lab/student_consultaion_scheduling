import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/consultation_request.dart';
import '../../models/faculty.dart';
import '../../utils/format_date.dart';

class DeclinedTab extends StatefulWidget {
  const DeclinedTab({super.key});

  @override
  State<DeclinedTab> createState() => _DeclinedTabState();
}

class _DeclinedTabState extends State<DeclinedTab> {
  List<Faculty> faculties = [];

  Future<void> loadFaculties() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'faculty')
        .get();

    setState(() {
      faculties = querySnapshot.docs
          .map((doc) => Faculty(
                id: doc["id"],
                name: doc["name"],
                email: doc["email"],
              ))
          .toList();
    });
  }

  @override
  void initState() {
    super.initState();
    loadFaculties();
  }

  @override
  Widget build(BuildContext context) {
    FirebaseAuth auth = FirebaseAuth.instance;

    Future<List<ConsultationRequest>> fetchDeniedRequests() async {
      User? currentUser = auth.currentUser;
      String? userId = currentUser?.uid;
      QuerySnapshot querySnapshot = await consultationRequests
          .where('status', isEqualTo: 'Declined')
          .where('studentID', isEqualTo: userId)
          .get();
      final allConsultationRequests = querySnapshot.docs
          .map((doc) => ConsultationRequest.fromMap(
              doc.data() as Map<String, dynamic>, doc.id))
          .toList();
      return allConsultationRequests;
    }

    return FutureBuilder<List<ConsultationRequest>>(
      future: fetchDeniedRequests(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return Container(
                margin: EdgeInsets.only(left: 16, right: 16, top: 16),
                child: Material(
                  color: Colors.white,
                  elevation: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: ListTile(
                      title: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  snapshot.data![index].requestTitle ??
                                      "No Title",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  snapshot.data![index].requestDescription ??
                                      "No Description",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w300),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  //
                                  'Faculty: ',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w300)),
                              Text(
                                  'Start Date: ${formatTimestamp(snapshot.data![index].proposedTimeStart as Timestamp)}',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w300)),
                              Text(
                                  'End Date: ${formatTimestamp(snapshot.data![index].proposedTimeEnd as Timestamp)}',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w300)),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        return Scaffold(
            body: Center(
          child: CircularProgressIndicator(),
        ));
      },
    );
  }
}
