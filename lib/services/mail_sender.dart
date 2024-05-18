import 'package:facultyconsultationscheduling/models/app_user.dart';
import 'package:facultyconsultationscheduling/models/consultation_request.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class MailSender {
  MailSender(
      {required this.student,
      required this.faculty,
      required this.consultation});

  final AppUser student;
  final AppUser faculty;
  final ConsultationRequest consultation;

  // final smtpServer = gmail(dotenv.env['USERNAME']!, dotenv.env['PASSWORD']!);
  final smtpServer = SmtpServer(
    'smtp.titan.email',
    username: dotenv.env['USERNAME']!,
    password: dotenv.env['PASSWORD']!,
  );
  Future<void> sendEmail() async {
    final message = Message()
      ..from = Address(dotenv.env['USERNAME']!, faculty.name)
      ..recipients.add(student.email)
      ..subject = 'Consultation Request Feedback'
      ..html = '''
        <!DOCTYPE html>
        <html lang="en">
        <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Consultation Request Feedback</title>
        <link href="https://api.fontshare.com/v2/css?f[]=satoshi@1&display=swap" rel="stylesheet">
        <style>
          *{
            font-family: 'Satoshi', sans-serif !important;
          }
          body {
            background-color: #f4f4f4;
            margin: 0;
            padding: 0;
          }
          .container {
            max-width: 600px;
            margin: 20px auto;
            padding: 20px;
            background-color: #fff;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
          }
          h5 {
            color: #333;
            text-align: center;
            margin-top: 0;
          }
          p {
            color: #555;
            margin-bottom: 15px;
          }
          .feedback {
            background-color: #f9f9f9;
            padding: 10px;
            border-radius: 5px;
          }
        </style>
        </head>
        <body>
          <div class="container">
            <h3>Consultation Request Feedback</h3>
            <p>Hi ${student.name},</p>
            <p>This is to inform you that ${faculty.name} ${consultation.status!.toLowerCase()} your consultation request entitled "${consultation.requestTitle}".</p>
            <p>Additionally, the said faculty have this feedback:</p>
            <div class="feedback">
              <p>${consultation.facultyComment}</p>
            </div>
            <p>Thank you!</p>
          </div>
        </body>
        </html>
      ''';

    print('hi');
    try {
      final sendReport = await send(message, smtpServer);
    } on MailerException catch (e) {
      // print('Message not sent.');
      // print(e);
      for (var p in e.problems) {
        // print('Problem: ${p.code}: ${p.msg}');
      }
    }
  }
}
