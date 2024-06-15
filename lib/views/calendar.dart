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
      _events = _getDummyEvents();
    });
  }

  List<Appointment> _getDummyEvents() {
    final DateTime now = DateTime.now();
    final DateTime startTime1 = DateTime(now.year, now.month, now.day, 10, 0, 0);
    final DateTime endTime1 = startTime1.add(const Duration(hours: 1));
    final DateTime startTime2 = DateTime(now.year, now.month, now.day, 14, 0, 0);
    final DateTime endTime2 = startTime2.add(const Duration(hours: 1));
    final DateTime startTime3 = DateTime(now.year, now.month, now.day, 16, 0, 0);
    final DateTime endTime3 = startTime3.add(const Duration(hours: 1));
    final DateTime startTime4 = DateTime(now.year, now.month, now.day, 18, 0, 0);
    final DateTime endTime4 = startTime4.add(const Duration(hours: 1));
    final DateTime startTime5 = DateTime(now.year, now.month, now.day, 20, 0, 0);
    final DateTime endTime5 = startTime5.add(const Duration(hours: 1));

    return <Appointment>[
      Appointment(
        startTime: startTime1,
        endTime: endTime1,
        subject: 'Meeting 1',
        color: Colors.blue,
      ),
      Appointment(
        startTime: startTime2,
        endTime: endTime2,
        subject: 'Meeting 2',
        color: Colors.green,
      ),
      Appointment(
        startTime: startTime3,
        endTime: endTime3,
        subject: 'Meeting 3',
        color: Colors.red,
      ),
      Appointment(
        startTime: startTime4,
        endTime: endTime4,
        subject: 'Meeting 4',
        color: Colors.orange,
      ),
      Appointment(
        startTime: startTime5,
        endTime: endTime5,
        subject: 'Meeting 5',
        color: Colors.purple,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SfCalendar(
                  dataSource: _DataSource(_events),
                  view: CalendarView.week,
                  allowedViews: [
                    CalendarView.day,
                    CalendarView.week,
                    CalendarView.month,
                    CalendarView.schedule,
                  ],
                  allowAppointmentResize: true,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DataSource extends CalendarDataSource {
  _DataSource(List<Appointment> appointments) {
    this.appointments = appointments;
  }
}
