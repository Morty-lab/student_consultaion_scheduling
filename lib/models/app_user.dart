import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'mixins/display_mixin.dart';

final _firebase = FirebaseAuth.instance;
final CollectionReference users = FirebaseFirestore.instance.collection('users');


class AppUser with DisplayMixin{
  AppUser({
    this.name,
    this.email,
    this.password,
    this.context,
    this.uid,
  });

  final String? uid;
  final String? name;
  final String? email;
  final String? password;
  final BuildContext? context;

  factory AppUser.fromMap(Map<String, dynamic> data, id) {
    return AppUser(
      uid: id,
      name: data['name'],
      email: data['email'],
      password: data['password'],
    );
  }


  Future<void> register() async {
    try{
      UserCredential userCredential = await _firebase.createUserWithEmailAndPassword(
          email: email!,
          password: password!
      );

      await users.add({
        'id': userCredential.user!.uid,
        'name': name,
        'email': email,
      });

    } on FirebaseAuthException catch(e){
      showError(
          errorMessage: e.message!,
          errorTitle: 'Authentication Error!'
      );
      return;

    }
  }

  Future<void> login() async {
    try{
      await _firebase.signInWithEmailAndPassword(
          email: email!,
          password: password!
      );
    } on FirebaseAuthException catch(e){
      showError(
          errorMessage: e.message!,
          errorTitle: 'Authentication Error!'
      );
      return;
    }
  }

  Future<AppUser> getUserById(String id) async {
    QuerySnapshot querySnapshot =  await users
        .where('id', isEqualTo: id)
        .get();

    final result = querySnapshot.docs.map((doc) =>
        AppUser.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
    return result[0];
  }


}