import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:facultyconsultationscheduling/models/consultation_request.dart';
import 'package:facultyconsultationscheduling/utils/format_date.dart';
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

  List<Faculty> faculties = [];
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Consultations'),
        bottom: TabBar(
          controller: _tabController,
          tabs: myTabs,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          FutureBuilder<List<ConsultationRequest>>(
            future: fetchPendingRequests(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                          snapshot.data![index].requestTitle ?? "No Title"),
                      subtitle: Text(snapshot.data![index].requestDescription ??
                          "No Description"),
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
                    return ListTile(
                      title: Text(
                          snapshot.data![index].requestTitle ?? "No Title"),
                      subtitle: Text(snapshot.data![index].requestDescription ??
                          "No Description"),
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
                    return ListTile(
                      title: Text(
                          snapshot.data![index].requestTitle ?? "No Title"),
                      subtitle: Text(snapshot.data![index].requestDescription ??
                          "No Description"),
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
      floatingActionButton: FloatingActionButton(
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
        child: Icon(Icons.add),
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
              ))
          .toList();
    });
  }
}
