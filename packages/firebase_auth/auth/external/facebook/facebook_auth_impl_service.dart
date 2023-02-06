import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:haveagoodone/service/auth/external/external_auth_impl_service.dart';
import 'package:utopia_utils/utopia_utils.dart';

class FacebookAuthImplService extends ExternalAuthImplService {
  late final _facebook = FacebookAuth.instance;

  @override
  Future<AuthCredential?> authenticate() async {
    final fbAccount = await _facebook.login(permissions: ['email', 'public_profile']);
    return fbAccount.accessToken?.token.let(FacebookAuthProvider.credential);
  }

  @override
  Future<void> deAuthenticate() async => _facebook.logOut();
}
