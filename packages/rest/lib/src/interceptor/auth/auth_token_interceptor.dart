import 'dart:async';

import 'package:dio/dio.dart';

class AuthTokenInterceptor extends Interceptor {
  static const enabled = "AuthTokenInterceptor.enabled";

  final FutureOr<String?> Function() tokenProvider;
  final String headerName;
  final String Function(String token)? headerValueBuilder;

  AuthTokenInterceptor({
    required this.tokenProvider,
    this.headerName = 'Authorization',
    this.headerValueBuilder,
  }) : super();

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if(options.extra[enabled] == false) return handler.next(options);
    final token = await tokenProvider();
    if (token != null) {
      options.headers[headerName] = headerValueBuilder?.call(token) ?? 'Bearer $token';
    }
    handler.next(options);
  }
}
