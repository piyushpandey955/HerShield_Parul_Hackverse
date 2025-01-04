import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;

  // Future<UserCredential?> loginWithGoogle() async{
  //   try{
  //     final googleUser = await GoogleSignIn().signIn();
  //     final googleAuth = await googleUser?.authentication;
  //     final cred = GoogleAuthProvider.credential(idToken: googleAuth?.idToken, accessToken: googleAuth?.accessToken);
  //     return await _auth.signInWithCredential(cred);
  //   } catch(e){
  //     print(e.toString());
  //   }
  //   return null;
  // }

  // final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Future<User?> signInWithGoogle() async {
  //   try {
  //     // Trigger the Google authentication flow
  //     final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

  //     if (googleUser == null) {
  //       // The user canceled the sign-in
  //       return null;
  //     }

  //     // Obtain the Google authentication details
  //     final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

  //     // Create a credential for Firebase
  //     final credential = GoogleAuthProvider.credential(
  //       accessToken: googleAuth.accessToken,
  //       idToken: googleAuth.idToken,
  //     );

  //     // Sign in to Firebase with the credential
  //     final UserCredential userCredential = await _auth.signInWithCredential(credential);

  //     return userCredential.user;
  //   } 
  //   catch (e) {
  //     print('Error during Google Sign-In: $e');
  //     return null;
  //   }

  // }

  Future<User?> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return cred.user;
    } on FirebaseAuthException catch(e){
      exceptionHandler(e.code);
    } 
    catch (e) {
      log("Something went wrong");
    }
    return null;
  }

  Future<User?> loginUserWithEmailAndPassword(
      String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return cred.user;
    } on FirebaseAuthException catch(e){
      exceptionHandler(e.code);
    } 
    catch (e) {
      log("Something went wrong");
    }
    return null;
  }

  Future<void> signout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      log("Something went wrong");
    }
  }
}

exceptionHandler(String code){
  switch(code){
    case "invalid-credentials" :
     log("your login credentials are invalid");

    case "weak-password" :
     log("your password must be atleast 8 characters");

    case "email-already-in-use" :
     log("User Already Exixts");
    
    default:
     log("something went wrong");

  }
}