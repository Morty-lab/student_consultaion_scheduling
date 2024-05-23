import 'package:emailjs/emailjs.dart';
import 'package:facultyconsultationscheduling/models/app_user.dart';
import 'package:facultyconsultationscheduling/services/mail_sender.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  final _form = GlobalKey<FormState>();
  String facultyID = "";
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime activityDateStart = DateTime.now();
  TimeOfDay activityTimeStart = TimeOfDay.now();
  DateTime activityDateEnd = DateTime.now();
  TimeOfDay activityTimeEnd = TimeOfDay.now();
  FirebaseAuth auth = FirebaseAuth.instance;
  List<Faculty> faculties = [];

  late TabController _tabController;
  List<Tab> myTabs = <Tab>[
    Tab(text: 'Pending'),
    Tab(text: 'Approved'),
    Tab(text: 'Denied'),
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: myTabs.length);
    loadFaculties();
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
              labelColor: Colors
                  .blue.shade900, // Set selected tab color to blue shade 900
              unselectedLabelColor:
                  Colors.grey, // Set unselected tab color to grey
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                FutureBuilder<List<ConsultationRequest>>(
                  future: fetchPendingRequests(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin:
                                EdgeInsets.only(left: 16, right: 16, top: 16),
                            child: Material(
                              color: Colors.white,
                              elevation: 1,
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: ListTile(
                                  title: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.3,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              snapshot.data![index]
                                                      .requestTitle ??
                                                  "No Title",
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              snapshot.data![index]
                                                      .requestDescription ??
                                                  "No Description",
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w300),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('Faculty: Axl',
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w300)),
                                          Text('Start Date: 05/26/2024 10:00AM',
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w300)),
                                          Text('End Date: 05/26/2024 11:00AM',
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
                                          // Add edit action
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.cancel),
                                        onPressed: () {
                                          // Add cancel action
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
                ),
                FutureBuilder<List<ConsultationRequest>>(
                  future: fetchApprovedRequests(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin:
                                EdgeInsets.only(left: 16, right: 16, top: 16),
                            child: Material(
                              color: Colors.white,
                              elevation: 1,
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: ListTile(
                                  title: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.3,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              snapshot.data![index]
                                                      .requestTitle ??
                                                  "No Title",
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              snapshot.data![index]
                                                      .requestDescription ??
                                                  "No Description",
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w300),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('Faculty: Axl',
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w300)),
                                          Text('Start Date: 05/26/2024 10:00AM',
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w300)),
                                          Text('End Date: 05/26/2024 11:00AM',
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
                                          // Add edit action
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.cancel),
                                        onPressed: () {
                                          // Add cancel action
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
                ),
                FutureBuilder<List<ConsultationRequest>>(
                  future: fetchDeniedRequests(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin:
                                EdgeInsets.only(left: 16, right: 16, top: 16),
                            child: Material(
                              color: Colors.white,
                              elevation: 1,
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: ListTile(
                                  title: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.3,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              snapshot.data![index]
                                                      .requestTitle ??
                                                  "No Title",
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              snapshot.data![index]
                                                      .requestDescription ??
                                                  "No Description",
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w300),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('Faculty: Axl',
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w300)),
                                          Text('Start Date: 05/26/2024 10:00AM',
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w300)),
                                          Text('End Date: 05/26/2024 11:00AM',
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
                                          // Add edit action
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.cancel),
                                        onPressed: () {
                                          // Add cancel action
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
                ),
              ],
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
                title: Text("New Request"),
                content: SingleChildScrollView(
                  child: Form(
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          controller: _titleController,
                          decoration:
                              InputDecoration(labelText: 'Request Title'),
                        ),
                        TextFormField(
                          controller: _descriptionController,
                          decoration:
                              InputDecoration(labelText: 'Request Description'),
                        ),
                        Text(
                            'Time Start: (Selected: ${formatTimestamp(convertToFirebaseTimestamp(activityDateStart, activityTimeStart))})',
                            style: TextStyle(fontWeight: FontWeight.w500)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            ElevatedButton(
                                onPressed: () {
                                  _selectDate(activityDateStart, Type.start);
                                  setState(() {});
                                },
                                child: const Text('Select Start Date')),
                            const SizedBox(
                              width: 5,
                            ),
                            ElevatedButton(
                                onPressed: () {
                                  _selectTime(activityTimeStart, Type.start);
                                  setState(() {});
                                },
                                child: const Text('Select Start Time'))
                          ],
                        ),
                        const SizedBox(height: 25),
                        Text(
                            'Time End: (Selected: ${formatTimestamp(convertToFirebaseTimestamp(activityDateEnd, activityTimeEnd))})',
                            style: TextStyle(fontWeight: FontWeight.w500)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            ElevatedButton(
                                onPressed: () {
                                  _selectDate(activityDateEnd, Type.end);
                                  setState(() {});
                                },
                                child: const Text('Select End Date')),
                            const SizedBox(
                              width: 5,
                            ),
                            ElevatedButton(
                                onPressed: () {
                                  _selectTime(activityTimeEnd, Type.end);
                                  setState(() {});
                                },
                                child: const Text('Select End Time'))
                          ],
                        ),
                        DropdownButtonFormField<Faculty>(
                          hint: Text('Select Faculty'),
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
                  TextButton(
                    child: Text('Submit'),
                    onPressed: () {
                      String requestTitle = _titleController.text;
                      String requestDescription = _descriptionController.text;
                      Timestamp proposedStartTime = convertToFirebaseTimestamp(
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

  Future<List<ConsultationRequest>> fetchPendingRequests() async {
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

  Future<List<ConsultationRequest>> fetchApprovedRequests() async {
    User? currentUser = auth.currentUser;
    String? userId = currentUser?.uid;
    QuerySnapshot querySnapshot = await consultationRequests
        .where('status', isEqualTo: 'Approved')
        .where('studentID', isEqualTo: userId)
        .get();
    final allConsultationRequests = querySnapshot.docs
        .map((doc) => ConsultationRequest.fromMap(
            doc.data() as Map<String, dynamic>, doc.id))
        .toList();
    return allConsultationRequests;
  }

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
}
