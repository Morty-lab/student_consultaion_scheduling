import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:facultyconsultationscheduling/models/mixins/display_mixin.dart';
import 'package:facultyconsultationscheduling/utils/format_date.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

final _firebase = FirebaseAuth.instance;
final CollectionReference activities =
    FirebaseFirestore.instance.collection('activities');

class Activity with DisplayMixin {
  Activity(
      {this.id,
      this.context,
      this.activityDescription,
      this.activityTitle,
      this.facultyID,
      this.timeEnd,
      this.timeStart,
      this.color});

  final BuildContext? context;
  final String? id;
  final String? facultyID;
  final String? activityTitle;
  final String? activityDescription;
  final Timestamp? timeStart;
  final Timestamp? timeEnd;
  final List<int>? color;

  factory Activity.fromMap(Map<String, dynamic> data, String id) {
    // Extract color data from the map
    List<int> colorData = (data['color'] as List<dynamic>).cast<int>();

    return Activity(
      id: id,
      activityDescription: data['activityDescription'],
      activityTitle: data['activityTitle'],
      facultyID: data['facultyID'],
      timeStart: data['timeStart'],
      timeEnd: data['timeEnd'],
      color: colorData,
    );
  }

  Appointment convertToAppointment(Map<String, dynamic> data, id) {
    Timestamp startTimeStamp = data['timeStart'] as Timestamp;
    Timestamp endTimeStamp = data['timeEnd'] as Timestamp;

    DateTime dateTimeStart = startTimeStamp.toDate();
    DateTime dateTimeEnd = endTimeStamp.toDate();

    // Retrieve color data as a dynamic list
    List<dynamic> colorData = data['color'] as List<dynamic>;

    // Cast each element of the color data to an integer
    List<int> colorIntegers =
        colorData.map((dynamic value) => value as int).toList();

    // Use the color integers to create a Color object
    Color color = Color.fromRGBO(
      colorIntegers[0],
      colorIntegers[1],
      colorIntegers[2],
      1.0, // Opacity
    );

    return Appointment(
        color: color,
        subject: data['activityTitle'],
        notes: data['activityDescription'],
        startTime: dateTimeStart,
        endTime: dateTimeEnd
        // startTime: DateTime(dateTimeStart.year, dateTimeStart.month, dateTimeStart.day, dateTimeStart.hour, dateTimeStart.minute),
        // endTime: DateTime(dateTimeEnd.year, dateTimeEnd.month, dateTimeEnd.day, dateTimeEnd.hour,dateTimeEnd.minute),
        );
  }

  Future<void> addActivity() async {
    try {
      await activities.add({
        'activityTitle': activityTitle,
        'activityDescription': activityDescription,
        'facultyID': _firebase.currentUser?.uid!,
        'timeStart': timeStart,
        'timeEnd': timeEnd,
        'color': getRandomColor()
      });
    } on FirebaseException catch (e) {
      showError(errorMessage: e.message!, errorTitle: 'Database Error!');
      return;
    }
  }

  Future<void> updateActivity() async {
    try {
      await activities.doc(id).update({
        'activityTitle': activityTitle,
        'activityDescription': activityDescription,
        'timeStart': timeStart,
        'timeEnd': timeEnd,
      });
    } on FirebaseException catch (e) {
      showError(errorMessage: e.message!, errorTitle: 'Database Error!');
      return;
    }
  }

  Future<void> deleteActivity() async {
    try {
      await activities.doc(id).delete();
    } on FirebaseException catch (e) {
      showError(errorMessage: e.message!, errorTitle: 'Database Error!');
      return;
    }
  }

  Future<Activity> getActivityById() async {
    QuerySnapshot querySnapshot =
        await activities.where('id', isEqualTo: id).get();
    final result = querySnapshot.docs
        .map((doc) =>
            Activity.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
    return result[0];
  }

  Future<List<Activity>> getActivitiesByFacultyID() async {
    QuerySnapshot querySnapshot = await activities
        .where('facultyID', isEqualTo: _firebase.currentUser?.uid)
        .get();
    final allActivities = querySnapshot.docs
        .map((doc) =>
            Activity.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
    return allActivities;
  }

  Future<List<Activity>> getAllActivities() async {
    QuerySnapshot querySnapshot = await activities.get();
    final allActivities = querySnapshot.docs
        .map((doc) =>
            Activity.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
    return allActivities;
  }

  Future<List<Appointment>> getAppointmentsByFacultyID() async {
    QuerySnapshot querySnapshot = await activities.get();
    final allActivities = querySnapshot.docs
        .map((doc) =>
            convertToAppointment(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
    return allActivities;
  }

  List<int> getRandomColor() {
    List<int> colorInts = [];
    Random random = Random();
    for (int j = 0; j < 3; j++) {
      colorInts.add(random.nextInt(256));
    }
    return colorInts;
  }
}
