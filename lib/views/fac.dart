import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:facultyconsultationscheduling/models/faculty.dart'; // Adjust the path as necessary
import 'package:facultyconsultationscheduling/utils/format_date.dart'; // Adjust the path as necessary
import 'package:emailjs/emailjs.dart';
import 'package:facultyconsultationscheduling/services/mail_sender.dart'; // Adjust the path as necessary

enum Type { start, end }

class Fac extends StatefulWidget {
  const Fac({super.key});

  @override
  _FacState createState() => _FacState();
}

class _FacState extends State<Fac> {
  List<Faculty> faculties = [];
  FirebaseAuth auth = FirebaseAuth.instance;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime activityDateStart = DateTime.now();
  TimeOfDay activityTimeStart = TimeOfDay.now();
  DateTime activityDateEnd = DateTime.now();
  TimeOfDay activityTimeEnd = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    loadFaculties();
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
      setState(() {
        if (type == Type.start) {
          activityDateStart = pickedDate;
        } else {
          activityDateEnd = pickedDate;
        }
      });
    }
  }

  Future<void> _selectTime(TimeOfDay selectedTime, Type type) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (pickedTime != null && pickedTime != selectedTime) {
      setState(() {
        if (type == Type.start) {
          activityTimeStart = pickedTime;
        } else {
          activityTimeEnd = pickedTime;
        }
      });
    }
  }

  void resetControllers() {
    _titleController.clear();
    _descriptionController.clear();
    activityDateStart = DateTime.now();
    activityTimeStart = TimeOfDay.now();
    activityDateEnd = DateTime.now();
    activityTimeEnd = TimeOfDay.now();
  }

  void _sendEmail(String facultyID, Timestamp start, Timestamp end) async {
    Faculty? faculty = faculties.firstWhere((f) => f.id == facultyID);
    User? currentUser = auth.currentUser;
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

  void showRequestDialog(BuildContext context, Faculty faculty) {
    User? currentUser = auth.currentUser;
    String? userId = currentUser?.uid;

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
                        fontSize: 20, color: Color.fromARGB(255, 63, 63, 63)),
                  ),
                  SizedBox(
                    height: 3,
                  ),
                  Row(
                    children: [
                      Text(
                        "Faculty: ",
                        style: TextStyle(
                            fontSize: 16,
                            color: Color.fromARGB(255, 69, 69, 69),
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "${faculty.name}",
                        style: TextStyle(
                            fontSize: 16,
                            color: Color.fromARGB(255, 69, 69, 69),
                            fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 5,
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
                  Timestamp proposedStartTime = convertToFirebaseTimestamp(
                      activityDateStart, activityTimeStart);
                  Timestamp proposedEndTime = convertToFirebaseTimestamp(
                      activityDateEnd, activityTimeEnd);

                  // Save to Firestore
                  FirebaseFirestore.instance
                      .collection('consultationRequests')
                      .add({
                    'studentID': userId,
                    'facultyID': faculty.id,
                    'requestTitle': requestTitle,
                    'requestDescription': requestDescription,
                    'proposedTimeStart': proposedStartTime,
                    'proposedTimeEnd': proposedEndTime,
                    'status': 'Pending',
                    'statusUpdateDate': Timestamp.now(),
                    'createdAt': FieldValue.serverTimestamp()
                  }).then((value) {
                    _sendEmail(faculty.id, proposedStartTime, proposedEndTime);
                    resetControllers();
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              color: const Color.fromARGB(255, 255, 255, 255),
              child: ResponsiveGridList(
                horizontalGridMargin: 20,
                verticalGridMargin: 20,
                minItemWidth: 250,
                children: faculties.map((faculty) {
                  return GestureDetector(
                    onTap: () => showRequestDialog(context, faculty),
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                        side: BorderSide(color: const Color.fromARGB(255, 220, 220, 220), width: 1)
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(4),
                              topRight: Radius.circular(4),
                            ),
                            child: Image.network(
                              'https://via.placeholder.com/150',
                              width: double.infinity,
                              height: 270,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  faculty.name,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  faculty.email,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
