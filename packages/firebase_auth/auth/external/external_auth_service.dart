import 'package:firebase_auth/firebase_auth.dart';
import 'package:haveagoodone/model/auth/provider/auth_provider.dart';
import 'package:haveagoodone/service/auth/external/apple/apple_auth_impl_service.dart';
import 'package:haveagoodone/service/auth/external/external_auth_impl_service.dart';
import 'package:haveagoodone/service/auth/external/facebook/facebook_auth_impl_service.dart';
import 'package:haveagoodone/service/auth/external/google/google_auth_impl_service.dart';

class ExternalAuthService {
  late final _auth = FirebaseAuth.instance;

  final Map<ExternalAuthProvider, ExternalAuthImplService> _implServices;

  ExternalAuthService(
    FacebookAuthImplService facebookService,
    GoogleAuthImplService googleService,
    AppleAuthImplService appleService,
  ) : _implServices = {
          AuthProvider.facebook: facebookService,
          AuthProvider.google: googleService,
          AuthProvider.apple: appleService,
        };

  bool isSupported(ExternalAuthProvider provider) => _implServices[provider]?.isSupported ?? false;

  Future<bool> signIn(ExternalAuthProvider provider) async {
    final credential = await _implServices[provider]!.authenticate();
    if(credential == null) return false;
    await _auth.signInWithCredential(credential);
    return true;
  }

  Future<bool> reauthenticate(ExternalAuthProvider provider) async {
    final credential = await _implServices[provider]!.authenticate();
    if(credential == null) return false;
    await _auth.currentUser!.reauthenticateWithCredential(credential);
    return true;
  }

  Future<void> deAuthenticate(ExternalAuthProvider provider) async => _implServices[provider]!.deAuthenticate();
}
