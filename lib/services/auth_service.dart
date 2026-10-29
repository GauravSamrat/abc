import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // 👈 Web check ke liye

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Current user (agar login hai toh)
  User? get currentUser => _auth.currentUser;

  // Auth state stream (auto-login ke liye)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign Up (Naya account)
  Future<String?> signUp(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return null; // Success
    } on FirebaseAuthException catch (e) {
      return e.message; // Error message return karein
    } catch (e) {
      return e.toString();
    }
  }

  // 👇 UPDATED: Google Sign-In (Web + Mobile both supported)
  Future<String?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // 🌐 WEB FIX: Direct Firebase Popup use karo, plugin ki zaroorat nahi
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        await _auth.signInWithPopup(googleProvider);
        return null; // Success
      } else {
        // 📱 MOBILE FIX: Google Sign-In plugin use karo
        final GoogleSignIn googleSignIn = GoogleSignIn(
          clientId:
              '67022605578-srh905g95mbe2i0njmght0cmo68pmugl.apps.googleusercontent.com',
        );

        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
        if (googleUser == null) {
          return 'Sign in cancelled'; // User ne cancel kar diya
        }

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        await _auth.signInWithCredential(credential);
        return null; // Success!
      }
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // Sign In (Purana account)
  Future<String?> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return null; // Success
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // Logout
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
