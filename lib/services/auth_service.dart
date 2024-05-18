import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:facultyconsultationscheduling/models/mixins/display_mixin.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
import 'package:facultyconsultationscheduling/firebase_options.dart';

import '../models/app_user.dart';

final _firebase = FirebaseAuth.instance;
final CollectionReference users =
    FirebaseFirestore.instance.collection('users');

class AuthService with DisplayMixin {
  // Future<void> signInWithGoogle() async {
  //   try {
  //     if (DefaultFirebaseOptions.currentPlatform == DefaultFirebaseOptions.windows) {
  //
  //     }
  //     final GoogleSignInAccount? googleUser = await GoogleSignIn(
  //         clientId: '1031424794749-d7ih8en1unk5q10gnb96ktfl9hsqrt6e.apps.googleusercontent.com'
  //     ).signIn();
  //     final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
  //
  //     final credential = GoogleAuthProvider.credential(
  //       accessToken: googleAuth?.accessToken,
  //       idToken: googleAuth?.idToken,
  //     );
  //
  //     final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
  //
  //     handleSignIn(userCredential);
  //
  //   } on FirebaseException catch(e){
  //     showError(
  //         errorMessage: e.message!,
  //         errorTitle: 'Authentication Error!'
  //     );
  //     return;
  //   }
  // }

  Future<AppUser?> getCurrentUser() async {
    // Get the current user from Firebase Auth
    User? firebaseUser = _firebase.currentUser;

    // If there is a current user, fetch the user document from Firestore
    if (firebaseUser != null) {
      DocumentSnapshot docSnapshot = await users.doc(firebaseUser.uid).get();

      // Convert the document data to an AppUser instance
      return AppUser.fromMap(
          docSnapshot.data() as Map<String, dynamic>, firebaseUser.uid);
    }

    // Return null if no user is currently signed in
    return null;
  }

  Future<void> logout() async {
    try {
      // Sign out the user from Firebase Auth
      await _firebase.signOut();
      // Optionally, clear any local storage or cache related to the user's session
      // For example, if you're storing tokens or user info locally:
      // await _clearLocalCache();
    } catch (e) {
      // Handle any errors that occur during sign-out
      print(e.toString());
    }
  }

  Future<void> signInWithGithub() async {
    try {
      final provider = GithubAuthProvider();
      provider.addScope('repo');
      final result = await FirebaseAuth.instance.signInWithPopup(provider);
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(result.credential!);
      handleSignIn(userCredential);
    } on FirebaseException catch (e) {
      showError(errorMessage: e.message!, errorTitle: 'Authentication Error!');
      return;
    }
  }

  Future<void> handleSignIn(UserCredential userCredential) async {
    QuerySnapshot querySnapshot =
        await users.where('id', isEqualTo: userCredential.user?.uid).get();

    if (querySnapshot.docs.isEmpty) {
      await users.add({
        'id': userCredential.user!.uid,
        'name': userCredential.user!.displayName,
        'email': userCredential.user!.email,
      });
    }
  }
}
