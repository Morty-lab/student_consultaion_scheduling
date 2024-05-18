import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'package:facultyconsultationscheduling/models/activity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'mixins/display_mixin.dart';

final _firebase = FirebaseAuth.instance;
final CollectionReference consultationRequests =
    FirebaseFirestore.instance.collection('consultationRequests');

class ConsultationRequest with DisplayMixin {
  ConsultationRequest(
      {this.id,
      this.studentID,
      this.facultyID,
      this.requestTitle,
      this.requestDescription,
      this.proposedTimeStart,
      this.proposedTimeEnd,
      this.status,
      this.statusUpdateDate,
      this.context,
      this.facultyComment});

  final BuildContext? context;
  final String? id;
  final String? studentID;
  final String? facultyID;
  final String? requestTitle;
  final String? requestDescription;
  final Timestamp? proposedTimeStart;
  final Timestamp? proposedTimeEnd;
  final String? status;
  final Timestamp? statusUpdateDate;
  final String? facultyComment;

  factory ConsultationRequest.fromMap(Map<String, dynamic> data, id) {
    return ConsultationRequest(
        id: id,
        studentID: data['studentID'],
        facultyID: data['facultyID'],
        requestTitle: data['requestTitle'],
        requestDescription: data['requestDescription'],
        proposedTimeStart: data['proposedTimeStart'],
        proposedTimeEnd: data['proposedTimeEnd'],
        status: data['status'],
        statusUpdateDate: data['statusUpdateDate'],
        facultyComment: data['facultyComment']);
  }

  Future<void> manageConsultationRequest() async {
    DateTime now = DateTime.now();
    Timestamp timestamp = Timestamp.fromDate(now);
    try {
      await consultationRequests.doc(id).update({
        'status': status,
        'facultyComment': facultyComment,
        'statusUpdateDate': timestamp
      });

      if (status == 'Approved') {
        await Activity(
          activityTitle: requestTitle,
          activityDescription: requestDescription,
          timeStart: proposedTimeStart,
          timeEnd: proposedTimeEnd,
        ).addActivity();
      }
    } on FirebaseException catch (e) {
      showError(errorMessage: e.message!, errorTitle: 'Database Error!');
      return;
    }
  }

  Future<List<ConsultationRequest>> getConsultationRequests() async {
    QuerySnapshot querySnapshot = await consultationRequests.get();
    final allConsultationRequests = querySnapshot.docs
        .map((doc) => ConsultationRequest.fromMap(
            doc.data() as Map<String, dynamic>, doc.id))
        .toList();
    return allConsultationRequests;
  }

  Future<ConsultationRequest> getConsultationRequestByID() async {
    QuerySnapshot querySnapshot =
        await consultationRequests.where('id', isEqualTo: id).get();
    final result = querySnapshot.docs
        .map((doc) => ConsultationRequest.fromMap(
            doc.data() as Map<String, dynamic>, doc.id))
        .toList();
    return result[0];
  }

  Future<List<ConsultationRequest>> getConsultationRequestsByStatus() async {
    QuerySnapshot querySnapshot = await consultationRequests
        .where('status', isEqualTo: 'Pending')
        .where('facultyID', isEqualTo: _firebase.currentUser?.uid)
        .get();
    final allConsultationRequests = querySnapshot.docs
        .map((doc) => ConsultationRequest.fromMap(
            doc.data() as Map<String, dynamic>, doc.id))
        .toList();
    return allConsultationRequests;
  }

  Future<List<ConsultationRequest>> getConsultationRequestsByDone() async {
    QuerySnapshot querySnapshot = await consultationRequests
        .where('status', whereIn: ['Approved', 'Declined'])
        .where('facultyID', isEqualTo: _firebase.currentUser?.uid)
        .get();

    final allConsultationRequests = querySnapshot.docs
        .map((doc) => ConsultationRequest.fromMap(
            doc.data() as Map<String, dynamic>, doc.id))
        .toList();

    return allConsultationRequests;
  }
}
