class AuthProvider {
  final String firebaseId;

  const AuthProvider._(this.firebaseId);

  factory AuthProvider.fromFirebaseId(String firebaseId) => values.firstWhere((it) => it.firebaseId == firebaseId);

  static const phoneNumber = AuthProvider._('phone');
  static const password = AuthProvider._('password');
  static const facebook = ExternalAuthProvider._('facebook.com');
  static const google = ExternalAuthProvider._('google.com');
  static const apple = ExternalAuthProvider._('apple.com');

  static const values = [phoneNumber, password, facebook, google, apple];
}

class ExternalAuthProvider extends AuthProvider {
  const ExternalAuthProvider._(super.firebaseId) : super._();
}
