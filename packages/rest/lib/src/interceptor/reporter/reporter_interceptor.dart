import 'package:dio/dio.dart';
import 'package:utopia_rest/src/interceptor/reporter/dio_log_util.dart';
import 'package:utopia_utils/reporter/reporter.dart';

class ReporterInterceptor implements Interceptor {
  final Reporter reporter;

  const ReporterInterceptor(this.reporter);

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    String buildMessage({bool sanitize = false}) {
      final response = err.response;
      if (response != null) {
        return DioLogUtil.buildResponseLog(response, sanitize: sanitize);
      } else {
        return 'Error: ${err.type.message}';
      }
    }

    reporter.error(
      buildMessage(),
      e: err.error,
      s: err.stackTrace ?? StackTrace.empty,
      sanitizedMessage: buildMessage(sanitize: true),
    );
    handler.next(err);
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    reporter.info(
      DioLogUtil.buildRequestLog(options),
      s: StackTrace.empty,
      sanitizedMessage: DioLogUtil.buildRequestLog(options, sanitize: true),
    );
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    reporter.info(
      DioLogUtil.buildResponseLog(response),
      s: StackTrace.empty,
      sanitizedMessage: DioLogUtil.buildResponseLog(response, sanitize: true),
    );
  }
}

extension on DioErrorType {
  String get message {
    switch (this) {
      case DioErrorType.connectTimeout:
        return 'Connect timeout';
      case DioErrorType.sendTimeout:
        return 'Send timeout';
      case DioErrorType.receiveTimeout:
        return 'Receive timeout';
      case DioErrorType.cancel:
        return 'Cancelled';
      case DioErrorType.other:
        return 'Other';
      case DioErrorType.response:
        throw StateError('Should be handled independently');
    }
  }
}
