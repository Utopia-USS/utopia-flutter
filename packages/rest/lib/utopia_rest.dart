import 'package:dio/dio.dart';

export 'src/interceptor/auth/auth_token_interceptor.dart';
export 'src/interceptor/reporter/reporter_interceptor.dart';

class UtopiaRest {
  static final BaseOptions standardDioOptions = BaseOptions(
    validateStatus: (status) => status != null && (status >= 200 && status < 300),
  );

  const UtopiaRest._();
}
