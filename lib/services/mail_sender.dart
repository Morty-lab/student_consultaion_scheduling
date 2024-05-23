import 'package:emailjs/emailjs.dart';
import 'package:facultyconsultationscheduling/models/app_user.dart';
import 'package:facultyconsultationscheduling/models/consultation_request.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MailSender {
  MailSender(
      {required this.student,
      required this.faculty,
      required this.consultation});

  final AppUser student;
  final AppUser faculty;
  final ConsultationRequest consultation;
}
