import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'mainView.dart';
import 'registerpage.dart';
import 'package:facultyconsultationscheduling/main.dart'; // Adjust based on your project structure

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    checkIfLoggedIn();
  }

  Future<void> checkIfLoggedIn() async {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (_) => MainView()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email')),
            TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true),
            ElevatedButton(
              onPressed: () async {
                QuerySnapshot userDoc = await firestore
                    .collection('users')
                    .where('email', isEqualTo: _emailController.text)
                    .get();

                // Check if the user is a student based on the roles field

                if (userDoc.docs.isNotEmpty) {
                  DocumentSnapshot docs = userDoc.docs.first;

                  String role = docs['role'];
                  if (role == "student") {
                    try {
                      await FirebaseAuth.instance.signInWithEmailAndPassword(
                          email: _emailController.text,
                          password: _passwordController.text);

                      Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => MainView()));
                    } on FirebaseAuthException catch (e) {
                      showDialog(
                          context: context!,
                          builder: (ctx) => AlertDialog(
                                title: Text("Login Error"),
                                content: Text(e.message!),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        Navigator.pop(ctx);
                                      },
                                      child: const Text('Okay'))
                                ],
                              ));
                    }
                  } else {
                    showDialog(
                        context: context!,
                        builder: (ctx) => AlertDialog(
                              title: Text("Access Denied"),
                              content:
                                  Text("Only students are allowed to sign in."),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.pop(ctx);
                                    },
                                    child: const Text('Okay'))
                              ],
                            ));
                  }
                  // Proceed if the user is a student
                } else {
                  // Handle non-student users
                  showDialog(
                      context: context!,
                      builder: (ctx) => AlertDialog(
                            title: Text("Account Not Found"),
                            content: Text(
                                "Please check your credentials or try registering to the system}"),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.pop(ctx);
                                  },
                                  child: const Text('Okay'))
                            ],
                          ));
                }
              },
              child: Text("Login"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => RegisterScreen()));
              },
              child: Text("Register"),
            ),
          ],
        ),
      ),
    );
  }
}
