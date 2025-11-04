import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart'; 

class AuthService {
  
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);

    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'account-exists-with-different-credential':
          message = 'Ovaj račun je već povezan s drugim načinom prijave.';
          break;
        case 'invalid-credential':
          message = 'Neispravan Google credential. Pokušajte ponovo.';
          break;
        default:
          message = 'Došlo je do greške pri Google prijavi. Pokušajte ponovo.';
      }

     
      debugPrint('FirebaseAuthException [Google Sign-In]: ${e.code} - ${e.message}');
      rethrow;

    } catch (e, stackTrace) {

      debugPrint('Neuhvaćena greška kod Google prijave: $e');
      debugPrintStack(stackTrace: stackTrace);
      throw Exception('Došlo je do neočekivane greške pri Google prijavi. Pokušajte ponovo.');
    }
  }
}
