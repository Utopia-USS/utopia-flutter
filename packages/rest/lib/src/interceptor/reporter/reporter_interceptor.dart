import 'package:dio/dio.dart';
import 'package:utopia_reporter/utopia_reporter.dart';
import 'package:utopia_rest/src/interceptor/reporter/dio_log_util.dart';

class ReporterInterceptor implements Interceptor {
  final Reporter reporter;
  final bool reportErrorsAsWarnings;

  const ReporterInterceptor(this.reporter, {this.reportErrorsAsWarnings = false});

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    String buildMessage({bool sanitize = false}) {
      final response = err.response;
      if (response != null) {
        return DioLogUtil.buildResponseLog(response, sanitize: sanitize);
      } else {
        return 'Error: ${err.type.name}';
      }
    }

    final report = reportErrorsAsWarnings ? reporter.warning : reporter.error;

    report(
      buildMessage(),
      e: err.error,
      s: err.stackTrace,
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
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    reporter.info(
      DioLogUtil.buildResponseLog(response),
      s: StackTrace.empty,
      sanitizedMessage: DioLogUtil.buildResponseLog(response, sanitize: true),
    );
    handler.next(response);
  }
}
