import 'package:facultyconsultationscheduling/themes/theme.dart';
import 'package:facultyconsultationscheduling/views/loginPage.dart';
import 'package:facultyconsultationscheduling/views/mainView.dart';
import 'package:facultyconsultationscheduling/views/registerpage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      home: LoginScreen(),
    );
  }
}
