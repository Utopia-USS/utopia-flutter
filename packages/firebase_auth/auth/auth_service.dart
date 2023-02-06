import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:haveagoodone/model/auth/provider/auth_provider.dart';
import 'package:haveagoodone/service/auth/external/external_auth_service.dart';
import 'package:utopia_utils/utopia_utils.dart';

class AuthService {
  late final _auth = FirebaseAuth.instance;
  final ExternalAuthService _externalAuthService;

  AuthService(this._externalAuthService);

  User? get currentUser => _auth.currentUser;

  AuthProvider? get authProvider => currentUser?.providerData
      .map((it) => AuthProvider.fromFirebaseId(it.providerId))
      .where((it) => it is! ExternalAuthProvider || _externalAuthService.isSupported(it))
      .firstOrNull();

  Stream<User?> userStream() async* {
    yield _auth.currentUser;
    yield* _auth.userChanges();
  }

  Future<void> signOut() async {
    await _deAuthenticateIfNeeded();
    await _auth.signOut();
  }

  Future<void> removeAccount() async {
    await _deAuthenticateIfNeeded();
    await _auth.currentUser?.delete();
  }

  Future<void> _deAuthenticateIfNeeded() async {
    final provider = authProvider!;
    if (provider is ExternalAuthProvider) await _externalAuthService.deAuthenticate(provider);
  }
}
