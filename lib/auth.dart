import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solwoe/model/shared_preferences.dart';

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<String?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return 'Logged in';
    } on FirebaseAuthException catch (signInError) {
    if (signInError.code == 'user-not-found') {
      return 'No user found for that email.';
    } else if (signInError.code == 'wrong-password') {
      return 'Wrong password provided for that user.';
    } else {
      return 'An error occurred while signing in.';
    }

    }
  }

  Future<String?> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      currentUser!.sendEmailVerification();
      return 'Verification Link sent to Email';
    } on FirebaseAuthException catch (signUpError) {
      if (signUpError.code == 'email-already-in-use') {
        return 'Email Already Registered';
      }
      else {
        return 'Error Occured while Registering';
      }
    }
    
  }

  Future<String?> resetPassword({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return 'Password Reset Link Sent to Email';
    } on FirebaseAuthException catch (_) {
      return 'Email Not Registered';
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut().then((value)async {
      SharedPreferences _pref = await SharedPreferencesService.getSharedPreferencesInstance(); 
      _pref.clear();
    });
  }
}
