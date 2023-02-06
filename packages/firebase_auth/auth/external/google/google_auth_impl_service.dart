import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:haveagoodone/service/auth/external/external_auth_impl_service.dart';

class GoogleAuthImplService extends ExternalAuthImplService {
  late final _google = GoogleSignIn(scopes: ['https://www.googleapis.com/auth/userinfo.email']);

  @override
  Future<AuthCredential?> authenticate() async {
    final googleSignInAccount = await _google.signIn();
    if (googleSignInAccount == null) return null;
    final googleSignInAuthentication = await googleSignInAccount.authentication;

    return GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );
  }

  @override
  Future<void> deAuthenticate() async => _google.signOut();
}
