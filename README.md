# WO Http

Opinionated HTTP toolkit for Flutter/Dart with:

- unified request/response models
- interceptor pipeline (`onRequest`, `onResponse`, `onError`)
- built-in retry interceptor
- optional auth refresh interceptor
- typed success/failure result wrappers
- multi-client factory support
- MIT licensed

## Installation

From `pub.dev`:

```yaml
dependencies:
  wo_http: ^0.1.0
```

Or local path:

```yaml
dependencies:
  wo_http:
    path: packages/wo_http
```

Then run:

```bash
flutter pub get
```

## Import

```dart
import 'package:wo_http/wo_http.dart';
```

## Quick Start

```dart
final client = WoDefaultHttpApiClient(
  baseUrl: 'https://api.example.com',
  interceptors: [
    WoDefaultRetryHttpInterceptor(maxRetries: 2),
  ],
);

final result = await client.get<Map<String, dynamic>>('/users/42');

if (result.isSuccess) {
  final user = result.data;
} else {
  final message = result.failure?.message;
  final type = result.failure?.errorType;
}
```

## Request Methods

`WoHttpClient` exposes:

- `get(path, {headers, parser, errorAdapter})`
- `post(path, {data, headers, parser, errorAdapter})`
- `put(path, {data, headers, parser, errorAdapter})`
- `patch(path, {data, headers, parser, errorAdapter})`
- `delete(path, {data, headers, parser, errorAdapter})`
- `upload(path, {method, fileFieldName, fields, files, headers, parser, errorAdapter})`

## Typed Parser Example

```dart
class User {
  final String id;
  final String name;

  User({required this.id, required this.name});

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as String,
        name: json['name'] as String,
      );
}

final result = await client.get<User>(
  '/users/42',
  parser: (raw) => User.fromJson(raw as Map<String, dynamic>),
);
```

## Upload Example

```dart
final upload = await client.upload<Map<String, dynamic>>(
  '/files/upload',
  fileFieldName: 'file',
  fields: {'folder': 'avatars'},
  files: [
    WoUploadFile(
      bytes: <int>[/* file bytes */],
      filename: 'profile.jpg',
      contentType: 'image/jpeg',
    ),
  ],
);
```

`WoUploadFile` supports either `bytes` or `path`.

## Error Adapter Example

`WoDefaultHttpErrorAdapter` is used by default. You can override it globally or per request.

```dart
class MyErrorAdapter implements WoHttpErrorAdapter {
  const MyErrorAdapter();

  @override
  String? adaptError(dynamic error) {
    if (error is Map<String, dynamic> && error['detail'] is String) {
      return error['detail'] as String;
    }
    return 'Unexpected error';
  }
}

final client = WoDefaultHttpApiClient(
  baseUrl: 'https://api.example.com',
  errorAdapter: const MyErrorAdapter(),
);
```

## Auth Refresh Example

```dart
class MyAuthStrategy extends WoAuthStrategy {
  const MyAuthStrategy() : super._();

  @override
  Future<String?> readAccessToken() async => 'access-token';

  @override
  Future<String?> refreshAccessToken() async => 'new-access-token';
}

final client = WoDefaultHttpApiClient(
  baseUrl: 'https://api.example.com',
  interceptors: [
    WoDefaultAuthInterceptor(
      authStrategy: const MyAuthStrategy(),
      excludedExactPaths: {'/auth/login', '/auth/refresh'},
      excludedPathPrefixes: {'/public/'},
    ),
    WoDefaultRetryHttpInterceptor(maxRetries: 2),
  ],
);
```

On `401`, the auth interceptor refreshes once and retries the request.

## Multi-Client Setup

Use `WoDataClientFactory` when your app talks to multiple backends.

```dart
final factory = WoDataClientFactory.fromDefinitions([
  WoDataClientDefinition(
    name: 'core',
    baseUrl: 'https://api.example.com',
    enableLogging: true,
    maxRetries: 2,
    requestTimeout: const Duration(seconds: 30),
  ),
  WoDataClientDefinition(
    name: 'ai',
    baseUrl: 'https://ai.example.com',
    enableLogging: true,
    maxRetries: 1,
    requestTimeout: const Duration(seconds: 15),
  ),
]);

final coreClient = factory.client('core');
final aiClient = factory.client('ai');
```

When `enableLogging` is true, factory-created clients include debug logging automatically.

## Registry Utility

```dart
final registry = WoDataRegistry();
registry.register<WoHttpClient>(client);

if (registry.isRegistered<WoHttpClient>()) {
  final resolved = registry.resolve<WoHttpClient>();
}
```

## Public Contracts

- `WoHttpClient`: consumer-facing HTTP operations.
- `WoHttpInterceptor`: request/response/error hooks.
- `WoHttpErrorAdapter`: maps raw error body to `String?`.
- `WoLogger`: logging abstraction.

## Public Models

- `WoHttpRequest`: normalized request passed through interceptors.
- `WoHttpResponse`: normalized response with `errorType`.
- `WoResult<T>`: success/failure wrapper returned by client methods.
- `WoDataFailure`: failure payload (`message`, `errorType`, `cause`).
- `WoUploadFile`: upload source (`bytes` or `path`) plus metadata.
- `WoAuthStrategy`: token read/refresh contract for auth interceptor.

## Enums

- `WoHttpMethod`: `get`, `post`, `put`, `patch`, `delete`.
- `WoHttpErrorType`: `network`, `timeout`, `unauthorized`, `forbidden`, `notFound`, `server`, `unknown`.

## Notes

- Retry behavior is status-code-based in `WoDefaultRetryHttpInterceptor`.
- Factory logging is active in debug mode (`kDebugMode`) only.

## Author

`Amanuel.T (emantggw)`
