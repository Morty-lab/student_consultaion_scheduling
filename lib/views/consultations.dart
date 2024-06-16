import 'package:emailjs/emailjs.dart';
import 'package:facultyconsultationscheduling/models/app_user.dart';
import 'package:facultyconsultationscheduling/services/mail_sender.dart';
import 'package:facultyconsultationscheduling/views/tabs/approvedTab.dart';
import 'package:facultyconsultationscheduling/views/tabs/cancelledTab.dart';
import 'package:facultyconsultationscheduling/views/tabs/declinedTab.dart';
import 'package:facultyconsultationscheduling/views/tabs/pendingTab.dart';
import 'package:facultyconsultationscheduling/widgets/consultations_form.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../models/faculty.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: myTabs.length);
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
              return SimpleDialog(
                children: [ConsultationsForm()],
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
