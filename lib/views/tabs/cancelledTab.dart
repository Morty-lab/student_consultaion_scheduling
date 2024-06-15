import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:facultyconsultationscheduling/models/consultation_request.dart';
import 'package:facultyconsultationscheduling/utils/format_date.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CancelledTab extends StatefulWidget {
  const CancelledTab({super.key});

  @override
  State<CancelledTab> createState() => _CancelledTabState();
}

class _CancelledTabState extends State<CancelledTab> {
  @override
  Widget build(BuildContext context) {
    FirebaseAuth auth = FirebaseAuth.instance;

    Future<List<ConsultationRequest>> fetchDeniedRequests() async {
      User? currentUser = auth.currentUser;
      String? userId = currentUser?.uid;
      QuerySnapshot querySnapshot = await consultationRequests
          .where('status', isEqualTo: 'Cancelled')
          .where('studentID', isEqualTo: userId)
          .get();
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
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
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
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
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
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
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
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
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
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
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
                    'Cancelled',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    return FutureBuilder<List<ConsultationRequest>>(
      future: fetchDeniedRequests(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final isLastItem = index == snapshot.data!.length - 1;
              return Container(
                margin: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16,
                  bottom: isLastItem ? 90 : 0,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color.fromARGB(
                        255, 220, 220, 220), // Border color
                    width: 1.0, // Border width
                  ),
                  borderRadius: BorderRadius.circular(5.0), // Border radius
                ),
                child: Material(
                  borderRadius: BorderRadius.circular(5.0),
                  color: Colors.white,
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: GestureDetector(
                      onTap: () {
                        _showRequestDetails(snapshot.data![index]);
                      },
                      child: ListTile(
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${snapshot.data![index].requestTitle ?? "No Title"}',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              'Description: ${snapshot.data![index].requestDescription ?? "No Description"}',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.normal),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                                'Schedule: ${formatTimestamp(snapshot.data![index].proposedTimeStart as Timestamp)} - ${formatTimestamp(snapshot.data![index].proposedTimeEnd as Timestamp)}',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w300)),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                                //
                                'Faculty: Faculty',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w300)),
                          ],
                        ),
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
