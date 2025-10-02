import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../Chat/controller.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Controller c = Get.put(Controller());

  /// Get Google Sign-In instance (singleton)
  GoogleSignIn get _googleSignIn => GoogleSignIn.instance;

  bool _isInitialized = false;

  /// Initialize Google Sign-In (must be called once before use)
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _googleSignIn.initialize();
      _isInitialized = true;
      debugPrint('Google Sign-In initialized successfully');
    } catch (e) {
      debugPrint('Error initializing Google Sign-In: $e');
      rethrow;
    }
  }

  /// Sign in with Google account
  /// Returns User if successful, null if cancelled
  /// Throws FirebaseAuthException or GoogleSignInException on error
  Future<User?> signInWithGoogle() async {
    try {
      // Ensure Google Sign-In is initialized
      await initialize();

      // Trigger Google Sign-In authentication (v7.x API)
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      // Get authentication tokens
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      // Validate that we have an ID token
      if (googleAuth.idToken == null) {
        throw FirebaseAuthException(
          code: 'missing-id-token',
          message: 'ID token is required for Firebase authentication',
        );
      }

      // Create Firebase credential using ID token
      // Note: In v7.x, access tokens are handled differently - we only need the ID token for Firebase
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the credential
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      // Update controller state
      final User? user = userCredential.user;
      if (user != null) {
        c.displayName.value =
            user.displayName ?? googleUser.displayName ?? 'User';
        c.signedIn.value = true;
        debugPrint('Successfully signed in: ${user.email}');
      }

      return user;
    } on GoogleSignInException catch (e) {
      debugPrint('GoogleSignInException: ${e.code} - ${e.description}');
      if (e.code == GoogleSignInExceptionCode.canceled) {
        debugPrint('User cancelled sign-in');
        return null;
      }
      rethrow;
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Error signing in with Google: $e');
      rethrow;
    }
  }

  /// Sign out from both Google and Firebase
  Future<void> signOutFromGoogle() async {
    try {
      // Disconnect from Google (full sign out)
      await _googleSignIn.disconnect();

      // Sign out from Firebase
      await _auth.signOut();

      // Update controller state
      c.displayName.value = "";
      c.signedIn.value = false;

      debugPrint('Successfully signed out');
    } catch (e) {
      debugPrint('Error signing out: $e');
      rethrow;
    }
  }

  /// Get current Firebase user
  User? get currentUser => _auth.currentUser;

  /// Check if user is signed in
  bool get isSignedIn => _auth.currentUser != null;

  /// Get user display name
  String get displayName => _auth.currentUser?.displayName ?? 'User';

  /// Get user email
  String? get userEmail => _auth.currentUser?.email;

  /// Get user photo URL
  String? get photoUrl => _auth.currentUser?.photoURL;
}
