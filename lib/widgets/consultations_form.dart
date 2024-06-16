import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emailjs/emailjs.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/faculty.dart';
import '../utils/format_date.dart';

enum Type { start, end }

class ConsultationsForm extends StatefulWidget {
  const ConsultationsForm({super.key});

  @override
  State<ConsultationsForm> createState() => _ConsultationsFormState();
}

class _ConsultationsFormState extends State<ConsultationsForm> {
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
    loadFaculties();
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

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Form(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "Request Consultation",
              style: TextStyle(
                  fontSize: 20, color: Color.fromARGB(255, 63, 63, 63)),
            ),
            Divider(
              color: Colors.black,
              thickness: 0.2,
            ),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Request Title'),
              style: TextStyle(fontWeight: FontWeight.normal),
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Request Description'),
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
                      },
                      child: const Text('Select Start Date')),
                ),
                Flexible(
                  child: ElevatedButton(
                      onPressed: () {
                        _selectTime(activityTimeStart, Type.start);
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
                  child: Text(faculty.name!), // Display name in the dropdown
                );
              }).toList(),
              onChanged: (Faculty? selectedFaculty) {
                if (selectedFaculty != null) {
                  facultyID = selectedFaculty
                      .id; // Ensure this matches the property name in your Faculty model
                }
              },
            ),
            SizedBox(
              height: 10,
            ),
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
                  Timestamp proposedStartTime = convertToFirebaseTimestamp(
                      activityDateStart, activityTimeStart);
                  Timestamp proposedEndTime = convertToFirebaseTimestamp(
                      activityDateEnd, activityTimeEnd);
                  String facultyId = facultyID!;

                  if (_titleController.text.isEmpty ||
                      _descriptionController.text.isEmpty ||
                      activityDateStart == DateTime.now() ||
                      activityTimeStart.hour == 0 &&
                          activityTimeStart.minute == 0 ||
                      activityDateEnd == DateTime.now() ||
                      activityTimeEnd.hour == 0 &&
                          activityTimeEnd.minute == 0 ||
                      facultyID.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please fill in all required fields.'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                    return;
                  }

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
                    _sendEmail(facultyId, proposedStartTime, proposedEndTime);
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
        ),
      ),
    );
  }
}
