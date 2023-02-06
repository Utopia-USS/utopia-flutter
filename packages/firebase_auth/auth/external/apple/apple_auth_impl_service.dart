import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:haveagoodone/service/auth/external/external_auth_impl_service.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AppleAuthImplService extends ExternalAuthImplService {
  @override
  bool get isSupported => Platform.isIOS;

  @override
  Future<AuthCredential?> authenticate() async {
    // based on https://firebase.flutter.dev/docs/auth/social#apple
    final rawNonce = generateNonce();
    final nonce = _sha256ofString(rawNonce);

    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName],
        nonce: nonce,
      );
      return OAuthProvider("apple.com").credential(idToken: appleCredential.identityToken, rawNonce: rawNonce);
    } on SignInWithAppleAuthorizationException catch(e) {
      if(e.code == AuthorizationErrorCode.canceled) return null;
      rethrow;
    }
  }

  @override
  Future<void> deAuthenticate() async {} // not supported

  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
