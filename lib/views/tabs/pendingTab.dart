import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

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
                    Text('Proposed Time',
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
                  '${faculties.firstWhere((f) => f.id == request.facultyID).name}',
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
                  '${request.requestDescription ?? "No Description"}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                ),
              ],
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: SizedBox(
                height: 40,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 22, 96, 165),
                    elevation: 0,
                  ),
                  icon: Icon(Icons.edit),
                  label: Text('Edit Request'),
                  onPressed: () {
                    Navigator.of(context).pop();
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
                                    "Edit Request",
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
                                    decoration: InputDecoration(
                                        labelText: 'Request Title'),
                                    style:
                                        TextStyle(fontWeight: FontWeight.normal),
                                  ),
                                  TextFormField(
                                    controller: _descriptionController,
                                    decoration: InputDecoration(
                                        labelText: 'Request Description'),
                                    style:
                                        TextStyle(fontWeight: FontWeight.normal),
                                  ),
                                  SizedBox(height: 25),
                                  Text(
                                    'Time Start: (Selected: ${formatTimestamp(convertToFirebaseTimestamp(activityDateStart, activityTimeStart))})',
                                    style:
                                        TextStyle(fontWeight: FontWeight.normal),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: ElevatedButton(
                                          onPressed: () {
                                            _selectDate(
                                                activityDateStart, Type.start);
                                            setState(() {});
                                          },
                                          child: const Text('Select Start Date'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Color.fromARGB(255, 22, 96, 165),
                                            elevation: 0,
                                          ),
                                        ),
                                      ),
                                      Flexible(
                                        child: ElevatedButton(
                                          onPressed: () {
                                            _selectTime(
                                                activityTimeStart, Type.start);
                                            setState(() {});
                                          },
                                          child: const Text('Select Start Time'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Color.fromARGB(255, 22, 96, 165),
                                            elevation: 0,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 25),
                                  Text(
                                    'Time End: (Selected: ${formatTimestamp(convertToFirebaseTimestamp(activityDateEnd, activityTimeEnd))})',
                                    style:
                                        TextStyle(fontWeight: FontWeight.normal),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: ElevatedButton(
                                            onPressed: () {
                                              _selectDate(
                                                  activityDateEnd, Type.end);
                                              setState(() {});
                                            },
                                            child: const Text('Select End Date')),
                                      ),
                                     
                                      Flexible(
                                        child: ElevatedButton(
                                            onPressed: () {
                                              _selectTime(
                                                  activityTimeEnd, Type.end);
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
                                    backgroundColor:
                                        Color.fromARGB(255, 22, 96, 165),
                                    iconColor: Colors.white),
                                icon: Icon(Icons.edit),
                                label: Text(
                                  'Edit Request',
                                  style: TextStyle(color: Colors.white),
                                ),
                                onPressed: () {
                                  // Handle form submission
                                  Navigator.of(context).pop();
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: SizedBox(
                height: 40,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 90, 108, 126),
                      elevation: 0),
                  icon: Icon(Icons.cancel),
                  label: Text('Cancel Request'),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Icon(
                                Icons.sentiment_dissatisfied,
                                size: 40,
                                color: Color.fromARGB(255, 89, 89, 89),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Do you want to cancel the request?',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Color.fromARGB(255, 50, 50, 50)),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(
                                  height:
                                      30), // Add some space between the text and buttons
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  SizedBox(
                                    height: 40,
                                    width: 100,
                                    child: TextButton(
                                      style: TextButton.styleFrom(
                                        backgroundColor: Colors.blue.shade900,
                                      ),
                                      onPressed: () async {
                                        String documentId = request.id
                                            as String; // Replace with your actual document ID
              
                                        FirebaseFirestore firestore =
                                            FirebaseFirestore.instance;
                                        await firestore
                                            .collection('consultationRequests')
                                            .doc(documentId)
                                            .update({
                                          'status':
                                              'Cancelled', // Change the status to 'cancelled'
                                        });
              
                                        Navigator.of(context).pop();
                                      },
                                      child: Text(
                                        'Yes',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 40,
                                    width: 100,
                                    child: TextButton(
                                      style: TextButton.styleFrom(
                                        backgroundColor: Colors.blue.shade900,
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text(
                                        'No',
                                        style: TextStyle(color: Colors.white),
                                      ),
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
              ),
            ),
          ],
        );
      },
    );
  }

// List View

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ConsultationRequest>>(
      future: fetchPendingRequests(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final isLastItem = index == snapshot.data!.length - 1;
              return Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color.fromARGB(
                        255, 220, 220, 220), // Border color
                    width: 1.0, // Border width
                  ),
                  borderRadius: BorderRadius.circular(5.0), // Border radius
                ),
                margin: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16,
                  bottom: isLastItem ? 90 : 0,
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
                              snapshot.data![index].requestTitle ?? "No Title",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Description: ${snapshot.data![index].requestDescription ?? "No Description"}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Proposed Time: ${formatTimestamp(snapshot.data![index].proposedTimeStart as Timestamp)} - ${formatTimestamp(snapshot.data![index].proposedTimeEnd as Timestamp)}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              'Faculty: ${faculties.firstWhere((f) => f.id == snapshot.data![index].facultyID).name}',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.normal),
                            ),
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
