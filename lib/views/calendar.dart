import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class Calendar extends StatefulWidget {
  const Calendar({Key? key}) : super(key: key);

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  late List<Appointment> _events;

  @override
  void initState() {
    super.initState();
    _events = [];
    _updateEvents();
  }

  void _updateEvents() {
    setState(() {
      // _events = getDynamicAppointments();
    });
  }

  Future<List<Appointment>> getDynamicAppointments() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final DateTime now = DateTime.now();

    // Query consultation requests with status "Approved"
    QuerySnapshot<Map<String, dynamic>> snapshot = await firestore
        .collection('consultationRequests')
        .where('status', isEqualTo: 'Approved')
        .get();

    List<Appointment> appointments = [];

    for (var doc in snapshot.docs) {
      Map<String, dynamic> data = doc.data();
      Timestamp proposedStartTime = data['proposedTimeStart'];
      Timestamp proposedEndTime = data['proposedTimeEnd'];

      DateTime parsedProposedStartTime = proposedStartTime.toDate();
      DateTime parsedProposedEndTime = proposedEndTime.toDate();

      // Assuming you want to add a 1-hour buffer around the proposed time
      DateTime adjustedStartTime =
          parsedProposedStartTime.add(Duration(minutes: 30));
      DateTime adjustedEndTime =
          parsedProposedEndTime.subtract(Duration(minutes: 30));

      appointments.add(Appointment(
        startTime: adjustedStartTime,
        endTime: adjustedEndTime,
        subject: data['requestTitle'],
        color: Colors
            .blue, // You might want to assign different colors based on facultyID or other criteria
      ));
    }

    return appointments;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Appointment>>(
        future: getDynamicAppointments(),
        builder:
            (BuildContext context, AsyncSnapshot<List<Appointment>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child:
                    CircularProgressIndicator()); // Show loading indicator while waiting for data
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}'); // Handle error case
          } else {
            // Once the data is fetched, pass it to the calendar data source
            return SfCalendar(
              dataSource: _DataSource(snapshot.data ?? []),
              view: CalendarView.month,
              allowedViews: [
                CalendarView.day,
                CalendarView.week,
                CalendarView.month,
                CalendarView.schedule,
              ],
              allowAppointmentResize: true,
            );
          }
        },
      ),
    );
  }
}

class _DataSource extends CalendarDataSource {
  _DataSource(List<Appointment> appointments) {
    this.appointments = appointments;
  }
}
