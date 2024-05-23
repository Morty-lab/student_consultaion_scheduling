import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/consultation_request.dart';
import '../../models/faculty.dart';
import '../../utils/format_date.dart';

enum Type { start, end }

class Pendingtab extends StatefulWidget {
  const Pendingtab({super.key});

  @override
  State<Pendingtab> createState() => _PendingtabState();
}

class _PendingtabState extends State<Pendingtab> {
  List<Faculty> faculties = [];
  String facultyID = "";

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime activityDateStart = DateTime.now();
  TimeOfDay activityTimeStart = TimeOfDay.now();
  DateTime activityDateEnd = DateTime.now();
  TimeOfDay activityTimeEnd = TimeOfDay.now();

  Future<List<ConsultationRequest>> fetchPendingRequests() async {
    FirebaseAuth auth = FirebaseAuth.instance;

    User? currentUser = auth.currentUser;
    String? userId = currentUser?.uid;
    QuerySnapshot querySnapshot = await consultationRequests
        .where('status', isEqualTo: 'Pending')
        .where('studentID', isEqualTo: userId)
        .get();
    final allConsultationRequests = querySnapshot.docs
        .map((doc) => ConsultationRequest.fromMap(
            doc.data() as Map<String, dynamic>, doc.id))
        .toList();
    return allConsultationRequests;
  }

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

  Future<void> _selectDate(DateTime selectedDate, Type type) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != selectedDate) {
      if (type == Type.start) {
        setState(() {
          activityDateStart = pickedDate;
        });
      } else {
        setState(() {
          activityDateEnd = pickedDate;
        });
      }
    }
  }

  Future<void> _selectTime(TimeOfDay selectedTime, Type type) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (pickedTime != null && pickedTime != selectedTime) {
      if (type == Type.start) {
        setState(() {
          activityTimeStart = pickedTime;
        });
      } else {
        setState(() {
          activityTimeEnd = pickedTime;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    loadFaculties();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ConsultationRequest>>(
      future: fetchPendingRequests(),
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
                                  'Faculty: ${faculties.firstWhere((f) => f.id == snapshot.data![index].facultyID).name}',
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
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text("Edit Request"),
                                    content: SingleChildScrollView(
                                      child: Form(
                                        child: Column(
                                          children: <Widget>[
                                            TextFormField(
                                              controller: _titleController,
                                              decoration: InputDecoration(
                                                  labelText: 'Request Title'),
                                            ),
                                            TextFormField(
                                              controller:
                                                  _descriptionController,
                                              decoration: InputDecoration(
                                                  labelText:
                                                      'Request Description'),
                                            ),
                                            SizedBox(height: 10),
                                            Text(
                                                'Time Start: (Selected: ${formatTimestamp(convertToFirebaseTimestamp(activityDateStart, activityTimeStart))})',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.w500)),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                ElevatedButton(
                                                    onPressed: () {
                                                      _selectDate(
                                                          activityDateStart,
                                                          Type.start);
                                                      setState(() {});
                                                    },
                                                    child: const Text(
                                                        'Select Start Date')),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                ElevatedButton(
                                                    onPressed: () {
                                                      _selectTime(
                                                          activityTimeStart,
                                                          Type.start);
                                                      setState(() {});
                                                    },
                                                    child: const Text(
                                                        'Select Start Time'))
                                              ],
                                            ),
                                            const SizedBox(height: 10),
                                            Text(
                                                'Time End: (Selected: ${formatTimestamp(convertToFirebaseTimestamp(activityDateEnd, activityTimeEnd))})',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.w500)),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                ElevatedButton(
                                                    onPressed: () {
                                                      _selectDate(
                                                          activityDateEnd,
                                                          Type.end);
                                                      setState(() {});
                                                    },
                                                    child: const Text(
                                                        'Select End Date')),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                ElevatedButton(
                                                    onPressed: () {
                                                      _selectTime(
                                                          activityTimeEnd,
                                                          Type.end);
                                                      setState(() {});
                                                    },
                                                    child: const Text(
                                                        'Select End Time'))
                                              ],
                                            ),
                                            SizedBox(height: 10),
                                            DropdownButtonFormField<Faculty>(
                                              hint: Text('Select Faculty'),
                                              items: faculties
                                                  .map((Faculty faculty) {
                                                return DropdownMenuItem<
                                                    Faculty>(
                                                  value: faculty,
                                                  child: Text(faculty
                                                      .name!), // Display name in the dropdown
                                                );
                                              }).toList(),
                                              onChanged:
                                                  (Faculty? selectedFaculty) {
                                                if (selectedFaculty != null) {
                                                  facultyID = selectedFaculty
                                                      .id; // Ensure this matches the property name in your Faculty model
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        style: TextButton.styleFrom(
                                          backgroundColor: Colors.blue.shade900,
                                        ),
                                        child: Text(
                                          'Submit',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        onPressed: () {
                                          // String requestTitle = _titleController.text;
                                          // String requestDescription = _descriptionController.text;
                                          // Timestamp proposedStartTime = convertToFirebaseTimestamp(
                                          //     activityDateStart, activityTimeStart);
                                          // Timestamp proposedEndTime = convertToFirebaseTimestamp(
                                          //     activityDateEnd, activityTimeEnd);
                                          // String facultyId = facultyID!;

                                          // // Save to Firestore
                                          // FirebaseFirestore.instance
                                          //     .collection('consultationRequests')
                                          //     .add({
                                          //   'studentID': userId,
                                          //   'facultyID': facultyId,
                                          //   'requestTitle': requestTitle,
                                          //   'requestDescription': requestDescription,
                                          //   'proposedTimeStart': proposedStartTime,
                                          //   'proposedTimeEnd': proposedEndTime,
                                          //   'status': 'Pending',
                                          //   'statusUpdateDate': Timestamp.now(),
                                          //   'createdAt': FieldValue.serverTimestamp()
                                          // }).then((value) {
                                          //   _titleController.clear();
                                          //   _descriptionController.clear();
                                          //   activityDateStart = DateTime.now();
                                          //   activityTimeStart = TimeOfDay.now();
                                          //   activityDateEnd = DateTime.now();
                                          //   activityTimeEnd = TimeOfDay.now();
                                          //   facultyID = "";
                                          //   print("Consultation Request Added");
                                          // }).catchError((error) {
                                          //   print("Failed to add consultation request: $error");
                                          // });
                                          // Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.cancel),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Text(
                                          'Do you want to cancel the request?',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.center,
                                        ),
                                        SizedBox(
                                            height:
                                                20), // Add some space between the text and buttons
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: <Widget>[
                                            TextButton(
                                              style: TextButton.styleFrom(
                                                backgroundColor:
                                                    Colors.blue.shade900,
                                              ),
                                              onPressed: () async {
                                                // Assuming you have a way to identify the document you want to update
                                                String documentId = snapshot
                                                        .data![index].id
                                                    as String; // Replace with your actual document ID

                                                FirebaseFirestore firestore =
                                                    FirebaseFirestore.instance;
                                                await firestore
                                                    .collection(
                                                        'consultationRequests')
                                                    .doc(documentId)
                                                    .update({
                                                  'status':
                                                      'cancelled', // Change the status to 'cancelled'
                                                });

                                                Navigator.of(context).pop();
                                              },
                                              child: Text(
                                                'Yes',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                            TextButton(
                                              style: TextButton.styleFrom(
                                                backgroundColor:
                                                    Colors.blue.shade900,
                                              ),
                                              onPressed: () {
                                                // Add your "No" button action here
                                                Navigator.of(context).pop();
                                              },
                                              child: Text(
                                                'No',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          ),
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
        return CircularProgressIndicator();
      },
    );
  }
}
