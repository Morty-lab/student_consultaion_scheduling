import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:facultyconsultationscheduling/utils/format_date.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/consultation_request.dart';

class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  // Mock data for demonstration purposes
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Consultation History',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900),
            ),
            SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<ConsultationRequest>>(
                future: fetchAllConsultations(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        var consultation = snapshot.data![index];
                        return Container(
                          margin: EdgeInsets.only(bottom: 16),
                          child: Material(
                            color: Colors.white,
                            elevation: 1,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: ListTile(
                                title: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
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
                                            consultation.requestDescription ??
                                                "No Description",
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w300),
                                          ),
                                          Text(
                                            'Status: ' +
                                                (consultation.status ??
                                                    "No Status"),
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
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            'Faculty: ${consultation.facultyID ?? "Unknown"}',
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w300),
                                          ),
                                          Text(
                                            'Start Date: ${formatTimestamp(consultation.proposedTimeStart!)}',
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w300),
                                          ),
                                          Text(
                                            'End Date: ${formatTimestamp(consultation.proposedTimeStart!)}',
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w300),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
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
