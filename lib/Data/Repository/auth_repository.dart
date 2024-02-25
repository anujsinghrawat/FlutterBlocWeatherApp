import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:weather/Data/Hive/person.dart';
import 'package:weather/boxes.dart';

class AuthRepository {
  final _firebaseAuth = FirebaseAuth.instance;

  Future<void> signUp(
      {required String email,
      required String password,
      required String name}) async {
    // const String dummyProfilePicUrl =
    //     "https://static.vecteezy.com/system/resources/previews/007/226/475/original/user-account-circle-glyph-color-icon-user-profile-picture-userpic-silhouette-symbol-on-white-background-with-no-outline-negative-space-illustration-vector.jpg";
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      String profileUrl = FirebaseAuth.instance.currentUser!.photoURL!;
      boxPersons.put('key_$name',
          Person(email: email, name: name, profileUrl: profileUrl));
      await FirebaseAuth.instance.currentUser?.updateDisplayName(name);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw Exception('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        throw Exception('The account already exists for that email.');
      }
    } catch (e) {
      debugPrint("Error: while creating user with firebase $e");
      throw Exception(e.toString());
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      String name = FirebaseAuth.instance.currentUser!.displayName!;
      String profileUrl = FirebaseAuth.instance.currentUser!.photoURL!;
      boxPersons.put('key_$name',
          Person(email: email, name: name, profileUrl: profileUrl));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        throw Exception('Wrong password provided for that user.');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      String name = FirebaseAuth.instance.currentUser!.displayName!;
      String profileUrl = FirebaseAuth.instance.currentUser!.photoURL!;
      String email = FirebaseAuth.instance.currentUser!.email!;
      boxPersons.put('key_$name',
          Person(email: email, name: name, profileUrl: profileUrl));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> signOut() async {
    String name = FirebaseAuth.instance.currentUser!.displayName!;
    try {
      await _firebaseAuth.signOut();
      boxPersons.delete('key_$name');
    } catch (e) {
      throw Exception(e);
    }
  }
}
