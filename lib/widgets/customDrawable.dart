import 'package:facultyconsultationscheduling/views/consultations.dart';
import 'package:facultyconsultationscheduling/views/fac.dart';
import 'package:facultyconsultationscheduling/views/history.dart';
import 'package:facultyconsultationscheduling/views/profile.dart';
import 'package:facultyconsultationscheduling/views/calendar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../views/loginPage.dart';

class CustomDrawer extends StatelessWidget {
  final ValueChanged<Widget> onPageChanged;
  final Widget currentPage;

  const CustomDrawer({
    Key? key,
    required this.onPageChanged,
    required this.currentPage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseAuth _auth = FirebaseAuth.instance;

    return Drawer(
      backgroundColor: Colors.white,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(
                color: const Color.fromARGB(255, 220, 220, 220),
                width: 1.0), // Add right border
          ),
        ),
        child: ListView(
          padding: EdgeInsets.all(5),
          children: [
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: Center(
                child: Text(
                  "Faculty Consultation Scheduling",
                  style: TextStyle(
                      color: Colors.black87,
                      fontSize: 18,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ),
            _buildDrawerItem(
              icon: Icons.list,
              text: 'Consultations',
              onTap: () => onPageChanged(Consultations()),
              isSelected: currentPage is Consultations,
            ),
            _buildDrawerItem(
              icon: Icons.history,
              text: 'Consultation History',
              onTap: () => onPageChanged(History()),
              isSelected: currentPage is History,
            ),
            _buildDrawerItem(
              icon: Icons.calendar_today,
              text: 'Calendar',
              onTap: () => onPageChanged(Calendar()),
              isSelected: currentPage is Calendar,
            ),
            _buildDrawerItem(
              icon: Icons.people,
              text: 'Faculties',
              onTap: () => onPageChanged(Fac()),
              isSelected: currentPage is Fac,
            ),
            _buildDrawerItem(
              icon: Icons.person,
              text: 'Profile',
              onTap: () => onPageChanged(Profile()),
              isSelected: currentPage is Profile,
            ),
            _buildDrawerItem(
              icon: Icons.logout,
              text: 'Logout',
              onTap: () async {
                await _auth.signOut();
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => LoginScreen()));
              },
              isSelected: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String text,
    required GestureTapCallback onTap,
    required bool isSelected,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 25.0),
      leading: Icon(icon,
          color: isSelected
              ? const Color.fromARGB(255, 22, 96, 165)
              : Colors.black54),
      title: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: isSelected
              ? const Color.fromARGB(255, 22, 96, 165)
              : Colors.black54,
        ),
      ),
      onTap: onTap,
    );
  }
}
