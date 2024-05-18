import 'package:flutter/material.dart';
import 'package:facultyconsultationscheduling/services/auth_service.dart'; // Import your AuthService
import 'package:facultyconsultationscheduling/models/app_user.dart';
import 'loginPage.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Register")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name')),
            TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email')),
            TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true),
            ElevatedButton(
              onPressed: () async {
                var appUser = AppUser(
                    name: _nameController.text,
                    email: _emailController.text,
                    password: _passwordController.text,
                    context: context);
                await appUser.register();
              },
              child: Text("Register"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (_) => LoginScreen()));
              },
              child: Text("Login"),
            ),
          ],
        ),
      ),
    );
  }
}
