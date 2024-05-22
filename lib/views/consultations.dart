import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:facultyconsultationscheduling/models/consultation_request.dart';
import '../models/faculty.dart'; // Adjust the path as necessary

class Consultations extends StatefulWidget {
  Consultations({Key? key}) : super(key: key);

  @override
  _ConsultationsState createState() => _ConsultationsState();
}

class _ConsultationsState extends State<Consultations>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Tab> myTabs = <Tab>[
    Tab(text: 'Pending'),
    Tab(text: 'Approved'),
    Tab(text: 'Denied'),
  ];

  ConsultationRequest _newConsultation = new ConsultationRequest();

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
                          decoration:
                              InputDecoration(labelText: 'Request Title'),
                        ),
                        TextFormField(
                          decoration:
                              InputDecoration(labelText: 'Request Description'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now(),
                              builder: (BuildContext context, Widget? child) {
                                return Theme(
                                  data: ThemeData.light().copyWith(
                                    primaryColor: Colors.blue,
                                  ),
                                  child: child!,
                                );
                              },
                            ).then((pickedDate) {
                              if (pickedDate != null) {
                                Timestamp timestamp =
                                    Timestamp.fromDate(pickedDate);
                                _newConsultation.proposedTimeStart = timestamp;
                              }
                            });
                          },
                          child: Text('Select Proposed Start Date'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now(),
                              builder: (BuildContext context, Widget? child) {
                                return Theme(
                                  data: ThemeData.light().copyWith(
                                    primaryColor: Colors.blue,
                                  ),
                                  child: child!,
                                );
                              },
                            ).then((pickedDate) {
                              if (pickedDate != null) {
                                Timestamp timestamp =
                                    Timestamp.fromDate(pickedDate);
                                _newConsultation.proposedTimeEnd = timestamp;
                              }
                            });
                          },
                          child: Text('Select Proposed End Date'),
                        ),
                        DropdownButtonFormField<Faculty>(
                          hint: Text('Select Faculty'),
                          items: faculties.map((Faculty faculty) {
                            return DropdownMenuItem<Faculty>(
                              value: faculty,
                              child: Text(
                                  faculty.name), // Display name in the dropdown
                            );
                          }).toList(),
                          onChanged: (Faculty? selectedFaculty) {
                            _newConsultation.facultyID = selectedFaculty?.id;
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
    QuerySnapshot querySnapshot =
        await consultationRequests.where('status', isEqualTo: 'Pending').get();
    final allConsultationRequests = querySnapshot.docs
        .map((doc) => ConsultationRequest.fromMap(
            doc.data() as Map<String, dynamic>, doc.id))
        .toList();
    return allConsultationRequests;
  }

  Future<List<ConsultationRequest>> fetchApprovedRequests() async {
    QuerySnapshot querySnapshot =
        await consultationRequests.where('status', isEqualTo: 'Approved').get();
    final allConsultationRequests = querySnapshot.docs
        .map((doc) => ConsultationRequest.fromMap(
            doc.data() as Map<String, dynamic>, doc.id))
        .toList();
    return allConsultationRequests;
  }

  Future<List<ConsultationRequest>> fetchDeniedRequests() async {
    QuerySnapshot querySnapshot =
        await consultationRequests.where('status', isEqualTo: 'Denied').get();
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
          .map((doc) => Faculty(doc.id, doc['name']))
          .toList();
    });
  }
}
