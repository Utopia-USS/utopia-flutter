import 'package:firebase_auth/firebase_auth.dart';

class PhoneAuthService {
  late final _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  String? get phoneNumber => currentUser?.phoneNumber;

  final Duration codeValidityDuration = const Duration(seconds: 60);

  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(PhoneAuthCredential) verificationCompleted,
    required void Function(FirebaseAuthException) verificationFailed,
    required void Function(String, int?) codeSent,
    required void Function(String) codeAutoRetrievalTimeout,
  }) async {
    return _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      timeout: codeValidityDuration,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
  }

  PhoneAuthCredential reauthenticateWithCredential({required String verificationId, required String otpCode}) {
    return PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otpCode,
    );
  }

  Future<void> signInWithCredentials({required String verificationId, required String otpCode}) async {
    final credential = reauthenticateWithCredential(
      verificationId: verificationId,
      otpCode: otpCode,
    );
    await _auth.signInWithCredential(credential);
  }

  Future<void> updatePhoneNumber({required String verificationId, required String otpCode}) async {
    final credential = reauthenticateWithCredential(
      verificationId: verificationId,
      otpCode: otpCode,
    );
    await _auth.currentUser?.updatePhoneNumber(credential);
  }

  Future<void> removeAccount({required String verificationId, required String otpCode}) async {
    final credential = reauthenticateWithCredential(
      verificationId: verificationId,
      otpCode: otpCode,
    );
    await _auth.currentUser?.reauthenticateWithCredential(credential);
    await _auth.currentUser?.delete();
  }
}
