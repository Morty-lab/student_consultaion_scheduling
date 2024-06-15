import 'package:emailjs/emailjs.dart';
import 'package:facultyconsultationscheduling/models/app_user.dart';
import 'package:facultyconsultationscheduling/services/mail_sender.dart';
import 'package:facultyconsultationscheduling/views/tabs/approvedTab.dart';
import 'package:facultyconsultationscheduling/views/tabs/cancelledTab.dart';
import 'package:facultyconsultationscheduling/views/tabs/declinedTab.dart';
import 'package:facultyconsultationscheduling/views/tabs/pendingTab.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:facultyconsultationscheduling/models/consultation_request.dart';
import 'package:facultyconsultationscheduling/utils/format_date.dart';
import 'package:flutter/widgets.dart';
import '../models/faculty.dart'; // Adjust the path as necessary

enum Type { start, end }

class Consultations extends StatefulWidget {
  Consultations({Key? key}) : super(key: key);

  @override
  _ConsultationsState createState() => _ConsultationsState();
}

class _ConsultationsState extends State<Consultations>
    with SingleTickerProviderStateMixin {
  bool isLoading = false;
  List<Faculty> faculties = [];
  FirebaseAuth auth = FirebaseAuth.instance;

  String facultyID = "";
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime activityDateStart = DateTime.now();
  TimeOfDay activityTimeStart = TimeOfDay.now();
  DateTime activityDateEnd = DateTime.now();
  TimeOfDay activityTimeEnd = TimeOfDay.now();

  late TabController _tabController;
  List<Tab> myTabs = <Tab>[
    Tab(text: 'Approved'),
    Tab(text: 'Pending'),
    Tab(text: 'Denied'),
    Tab(text: "Cancelled")
  ];

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
    _tabController = TabController(vsync: this, length: myTabs.length);
    loadFaculties();
  }

  void resetControllers() {
    _titleController.clear();
    _descriptionController.clear();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    User? currentUser = auth.currentUser;
    String? userId = currentUser?.uid;

    void _sendEmail(String facultyID, Timestamp start, Timestamp end) async {
      Faculty? faculty = faculties.firstWhere((f) => f.id == facultyID);
      String date = "${formatTimestamp(start)} to ${formatTimestamp(end)}";
      try {
        await EmailJS.send(
          'service_xz7s429',
          'template_aqv3ke8',
          {
            'from_email': currentUser?.email,
            'to_email': faculty.email,
            'message': _descriptionController.text,
            'to_name': faculty.name,
            'date': date,
            'from_name': currentUser?.displayName
          },
          const Options(
            publicKey: 'z7ftgvbeNZajNRWkz',
            privateKey: 'CnaTN4WJiZK3CLTFuhVMd',
          ),
        );
        print('SUCCESS!');
      } catch (error) {
        if (error is EmailJSResponseStatus) {
          print('ERROR... ${error.status}: ${error.text}');
        }
        print(error.toString());
      }
    }

    return Scaffold(
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              tabs: myTabs,
              labelColor: const Color.fromARGB(
                  255, 22, 96, 165), // Set selected tab color to blue shade 900
              unselectedLabelColor:
                  Colors.grey, // Set unselected tab color to grey
            ),
          ),
          Expanded(
            child: Container(
              color: const Color.fromARGB(255, 255, 255, 255),
              child: TabBarView(
                controller: _tabController,
                children: [
                  Approvedtab(),
                  Pendingtab(),
                  DeclinedTab(),
                  CancelledTab()
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: SingleChildScrollView(
                  child: Form(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "Request Consultation",
                          style: TextStyle(
                              fontSize: 20,
                              color: Color.fromARGB(255, 63, 63, 63)),
                        ),
                        Divider(
                          color: Colors.black,
                          thickness: 0.2,
                        ),
                        TextFormField(
                          controller: _titleController,
                          decoration:
                              InputDecoration(labelText: 'Request Title'),
                          style: TextStyle(fontWeight: FontWeight.normal),
                        ),
                        TextFormField(
                          controller: _descriptionController,
                          decoration:
                              InputDecoration(labelText: 'Request Description'),
                          style: TextStyle(fontWeight: FontWeight.normal),
                        ),
                        SizedBox(height: 25),
                        Text(
                            'Time Start: (Selected: ${formatTimestamp(convertToFirebaseTimestamp(activityDateStart, activityTimeStart))})',
                            style: TextStyle(fontWeight: FontWeight.normal)),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: ElevatedButton(
                                  onPressed: () {
                                    _selectDate(activityDateStart, Type.start);
                                    setState(() {});
                                  },
                                  child: const Text('Select Start Date')),
                            ),
                            Flexible(
                              child: ElevatedButton(
                                  onPressed: () {
                                    _selectTime(activityTimeStart, Type.start);
                                    setState(() {});
                                  },
                                  child: const Text('Select Start Time')),
                            )
                          ],
                        ),
                        const SizedBox(height: 25),
                        Text(
                            'Time End: (Selected: ${formatTimestamp(convertToFirebaseTimestamp(activityDateEnd, activityTimeEnd))})',
                            style: TextStyle(fontWeight: FontWeight.normal)),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: ElevatedButton(
                                  onPressed: () {
                                    _selectDate(activityDateEnd, Type.end);
                                    setState(() {});
                                  },
                                  child: const Text('Select End Date')),
                            ),
                            Flexible(
                              child: ElevatedButton(
                                  onPressed: () {
                                    _selectTime(activityTimeEnd, Type.end);
                                    setState(() {});
                                  },
                                  child: const Text('Select End Time')),
                            )
                          ],
                        ),
                        SizedBox(height: 20),
                        DropdownButtonFormField<Faculty>(
                          hint: Text('Select Faculty'),
                          style: TextStyle(
                              fontWeight: FontWeight.normal,
                              color: Colors.black,
                              fontFamily: 'Satoshi',
                              fontSize: 16),
                          items: faculties.map((Faculty faculty) {
                            return DropdownMenuItem<Faculty>(
                              value: faculty,
                              child: Text(faculty
                                  .name!), // Display name in the dropdown
                            );
                          }).toList(),
                          onChanged: (Faculty? selectedFaculty) {
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
                  SizedBox(
                    height: 40,
                    child: TextButton.icon(
                      style: TextButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 22, 96, 165),
                          iconColor: Colors.white),
                      icon: Icon(Icons.add),
                      label: Text(
                        'Request Consultation',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        String requestTitle = _titleController.text;
                        String requestDescription = _descriptionController.text;
                        Timestamp proposedStartTime =
                            convertToFirebaseTimestamp(
                                activityDateStart, activityTimeStart);
                        Timestamp proposedEndTime = convertToFirebaseTimestamp(
                            activityDateEnd, activityTimeEnd);
                        String facultyId = facultyID!;

                        // Save to Firestore
                        FirebaseFirestore.instance
                            .collection('consultationRequests')
                            .add({
                          'studentID': userId,
                          'facultyID': facultyId,
                          'requestTitle': requestTitle,
                          'requestDescription': requestDescription,
                          'proposedTimeStart': proposedStartTime,
                          'proposedTimeEnd': proposedEndTime,
                          'status': 'Pending',
                          'statusUpdateDate': Timestamp.now(),
                          'createdAt': FieldValue.serverTimestamp()
                        }).then((value) {
                          _sendEmail(
                              facultyId, proposedStartTime, proposedEndTime);
                          _titleController.clear();
                          _descriptionController.clear();
                          activityDateStart = DateTime.now();
                          activityTimeStart = TimeOfDay.now();
                          activityDateEnd = DateTime.now();
                          activityTimeEnd = TimeOfDay.now();
                          facultyID = "";

                          print("Consultation Request Added");
                        }).catchError((error) {
                          print("Failed to add consultation request: $error");
                        });
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
        tooltip: 'Add New Request',
        icon: Icon(Icons.add),
        label: const Text('Request Consultation'),
      ),
    );
  }
}
