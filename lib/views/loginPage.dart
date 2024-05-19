import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'mainView.dart';
import 'registerpage.dart';

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
    return Scaffold(
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(10.0),
          width: 800,
          height: 450,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Login", style: TextStyle(fontFamily: 'Satoshi', fontWeight: FontWeight.w700, fontSize: 20),),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: _emailController,
                        decoration: InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email),),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: _passwordController,
                        decoration: InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock)),
                        obscureText: true,
                      ),
                    ),
                    SizedBox(height: 10,),
                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: ElevatedButton(
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
                                  context: context,
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
                                context: context,
                                builder: (ctx) => AlertDialog(
                                      title: Text("Access Denied"),
                                      content: Text("Only students are allowed to sign in."),
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
                          // Handle non-student users
                          showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                    title: Text("Account Not Found"),
                                    content: Text("Please check your credentials or try registering to the system"),
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
                    ),
                    SizedBox(height: 15),
                    Row(
                      children: [
                        Text('Don\'t have an account?'),
                        SizedBox(width: 5,),
                        InkWell(
                          onTap: () {
                          Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (_) => RegisterScreen()));
                        },
                        child: Text("Register", style: TextStyle(color: Colors.blue.shade900),),
                        )
                      ],
                    ),
                  ],
                ),
                ),
              ),
              Expanded(
                child: Container(
                   decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                    color: const Color.fromARGB(255, 9, 76, 119)),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),  // Add padding of 10
                    child: Column(
                      children: [
                        SizedBox(height: 30),
                        Text(
                          'Faculty Support Desk',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontFamily: 'Satoshi',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Image.asset(
                          'lib/assets/images/auth-illustration.png',
                          width: 300,
                          height: 300,
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Schedule your consultation with faculty directly through Faculty Support Desk', textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'Satoshi',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
