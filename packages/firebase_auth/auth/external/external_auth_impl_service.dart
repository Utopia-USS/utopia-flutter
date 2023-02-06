import 'package:firebase_auth/firebase_auth.dart';

abstract class ExternalAuthImplService {
  bool get isSupported => true;

  Future<AuthCredential?> authenticate();

  Future<void> deAuthenticate();
}
