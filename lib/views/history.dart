import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:facultyconsultationscheduling/utils/format_date.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/consultation_request.dart';
import '../../models/faculty.dart';

class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  // Mock data for demonstration purposes
  List<Faculty> faculties = [];
  String facultyID = "";

  FirebaseAuth auth = FirebaseAuth.instance;

  Future<List<ConsultationRequest>> fetchAllConsultations() async {
    User? currentUser = auth.currentUser;
    String? userId = currentUser?.uid;
    QuerySnapshot querySnapshot =
        await consultationRequests.where('studentID', isEqualTo: userId).get();
    final allConsultationRequests = querySnapshot.docs
        .map((doc) => ConsultationRequest.fromMap(
            doc.data() as Map<String, dynamic>, doc.id))
        .toList();
    return allConsultationRequests;
  }

  void _showRequestDetails(ConsultationRequest request) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.requestTitle ?? "No Title",
                  style: TextStyle(
                    fontSize: 20,
                    color: Color.fromARGB(255, 63, 63, 63),
                  ),
                ),
                Divider(
                  color: Colors.black,
                  thickness: 0.2,
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Icon(Icons.description,
                        size: 18,
                        color: Colors.grey[
                            600]), // Built-in description icon (adjust as needed)
                    SizedBox(width: 5),
                    Text('Description',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 89, 89, 89))),
                  ],
                ),
                Text(
                  '${request.requestDescription ?? "No Description"}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Icon(Icons.calendar_month,
                        size: 18,
                        color: Colors.grey[
                            600]), // Built-in calendar icon (adjust as needed)
                    SizedBox(width: 5),
                    Text('Schedule',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 89, 89, 89))),
                  ],
                ),
                Text(
                  '${formatTimestamp(request.proposedTimeStart as Timestamp)} - ${formatTimestamp(request.proposedTimeEnd as Timestamp)}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                ),
                SizedBox(height: 5),
                Row(
                  children: [
                    Icon(Icons.people,
                        size: 18,
                        color: Colors.grey[
                            600]), // Built-in school icon (adjust as needed)
                    SizedBox(width: 5),
                    Text('Faculty',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 89, 89, 89))),
                  ],
                ),
                Text(
                  'Faculty',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Icon(Icons.account_circle,
                        size: 18,
                        color: Colors.grey[
                            600]), // Built-in user icon (adjust as needed)
                    SizedBox(width: 5),
                    Text('Requestor Name',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 89, 89, 89))),
                  ],
                ),
                Text(
                  '${request.requestDescription ?? "No Description"}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                ),
                SizedBox(height: 5),
                Row(
                  children: [
                    Icon(Icons.email,
                        size: 18,
                        color: Colors.grey[
                            600]), // Built-in email icon (adjust as needed)
                    SizedBox(width: 5),
                    Text('Requestor Email',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 89, 89, 89))),
                  ],
                ),
                Text(
                  '${request.requestDescription ?? "No Description"}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Icon(Icons.info_rounded,
                        size: 18,
                        color: Colors.grey[
                            600]), // Built-in email icon (adjust as needed)
                    SizedBox(width: 5),
                    Text('Status',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 89, 89, 89))),
                  ],
                ),
                Text(
                  'The Status',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: FutureBuilder<List<ConsultationRequest>>(
              future: fetchAllConsultations(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  return Container(
                    color: const Color.fromARGB(255, 255, 255, 255),
                    child: ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        var consultation = snapshot.data![index];
                        final isLastItem = index == snapshot.data!.length - 1;
                        return Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color.fromARGB(255, 220, 220, 220),// Border color
                              width: 1.0, // Border width
                            ),
                            borderRadius:
                                BorderRadius.circular(5.0), // Border radius
                          ),
                          margin: EdgeInsets.only(
                            top: 16,
                            left: 16,
                            right: 16,
                            bottom: isLastItem ? 90 : 0,
                          ),
                          child: Material(
                            color: Colors.white,
                            elevation: 0,
                            borderRadius: BorderRadius.circular(5.0),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: GestureDetector(
                                onTap: () {
                                  _showRequestDetails(snapshot.data![index]);
                                },
                                child: ListTile(
                                  title: Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          consultation.requestTitle ??
                                              "No Title",
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          "Description: ${consultation.requestDescription ?? "No Description"}",
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w300),
                                        ),
                                        Text(
                                          'Faculty: Faculty Name',
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w300),
                                        ),
                                        Text(
                                          'Schedule: ${formatTimestamp(consultation.proposedTimeStart!)} - ${formatTimestamp(consultation.proposedTimeStart!)}',
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w300),
                                        ),
                                        Text(
                                          (consultation.status ?? "No Status"),
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w300,
                                            color: _getColorForStatus(
                                                consultation.status ?? ""),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorForStatus(String status) {
    switch (status) {
      case 'Approved':
        return Colors.blue.shade900;
      case 'Declined':
        return Colors.red.shade900;
      case 'Pending':
        return Colors.yellow.shade700;
      case 'Cancelled':
        return Colors.redAccent;
      default:
        return Colors.black; // You can set a default color here if needed
    }
  }
}
