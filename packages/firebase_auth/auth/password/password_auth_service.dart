import 'package:firebase_auth/firebase_auth.dart';

class PasswordAuthService {
  late final _auth = FirebaseAuth.instance;

  Future<void> signIn({required String email, required String password}) async =>
      _auth.signInWithEmailAndPassword(email: email, password: password);

  Future<void> signUp({required String email, required String password}) async =>
      _auth.createUserWithEmailAndPassword(email: email, password: password);

  Future<void> updateEmail({required String newEmail, required String password}) async {
    await reauthenticate(password: password);
    await _auth.currentUser!.updateEmail(newEmail);
  }

  Future<void> updatePassword({required String newPassword, required String oldPassword}) async {
    await reauthenticate(password: oldPassword);
    await _auth.currentUser!.updatePassword(newPassword);
  }

  Future<void> resetPassword({required String email}) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> reauthenticate({required String password}) async {
    final credential = EmailAuthProvider.credential(email: _auth.currentUser!.email!, password: password);
    await _auth.currentUser!.reauthenticateWithCredential(credential);
  }
}
