<img src="https://raw.githubusercontent.com/Utopia-USS/utopia-flutter/master/packages/rest/docs/header.png" width="215" alt="Utopia REST"/>

# utopia_rest

Dio interceptors and shared configuration for REST API communication. Provides a standard `BaseOptions` preset, a token-injection interceptor, and a request/response logging interceptor that routes through `utopia_reporter`.

## Usage

```dart
import 'package:dio/dio.dart';
import 'package:utopia_rest/utopia_rest.dart';

final dio = Dio(UtopiaRest.standardDioOptions)
  ..interceptors.addAll([
    AuthTokenInterceptor(
      tokenProvider: () async => await myAuth.getToken(),
      // headerName defaults to 'Authorization'
      // headerValueBuilder defaults to 'Bearer <token>'
    ),
    ReporterInterceptor(reporter),
  ]);
```

To skip token injection for a specific request, set the extra flag:

```dart
dio.get('/public', options: Options(extra: {AuthTokenInterceptor.enabled: false}));
```

## API

- `UtopiaRest.standardDioOptions` - `BaseOptions` that treats 2xx as success and everything else as an error.
- `AuthTokenInterceptor` - injects a bearer token (or custom header value) on every request. Constructor parameters: `tokenProvider` (required), `headerName` (default `'Authorization'`), `headerValueBuilder` (optional; defaults to `'Bearer <token>'`). Set `options.extra[AuthTokenInterceptor.enabled] = false` to opt a single request out.
- `ReporterInterceptor` - logs every request, response, and error via a `Reporter`. Pass `reportErrorsAsWarnings: true` to downgrade errors to warnings.
