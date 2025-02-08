import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //signup the user function
  Future<String> signUpUser({
    required String email,
    required String username,
    required String password,
  }) async {
    String res = 'Some error ocurred';
    try {
      if (email.isNotEmpty || username.isNotEmpty || password.isNotEmpty) {

        //register the user
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);

        if (kDebugMode) {
          print(cred.user!.uid);
        }

        //adding user to our database
        await _firestore.collection('users').doc(cred.user!.uid).set({
          'email': email,
          'uid': cred.user!.uid,
          'username': username,
          'password': password,
        });
        res = 'User registered successfully';
        if(res == 'User registered successfully'){
          User? user = _auth.currentUser;
          if(user != null) {
            await user.updateDisplayName(username);
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        res = 'The password should have at least 6 characters.';
      } else if (e.code == 'email-already-in-use') {
        res = 'The account already exists for that email.';
      } else if (e.code == 'invalid-email') {
        res = 'The email address is not valid.';
      }
    } catch (e) {
      res = e.toString();
    }

    return res;
  }



  //loggin the user function
  Future<String> logginUser({
    required String email,
    required String password,
  }) async {
    String res = 'Some error ocurred';
    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        //login the user
        UserCredential cred = await _auth.signInWithEmailAndPassword(
            email: email, password: password);

        if (kDebugMode) {
          print(cred.user!.uid);
        }

        res = 'User logged in successfully';
      }else{
        res = 'Please fill all the fields';
        }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        res = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        res = 'Wrong password provided for that user.';
      } else if (e.code == 'invalid-email') {
        res = 'The email address is not valid.';
      }
    } catch (e) {
      res = e.toString();
    }

    return res;
  }
}
