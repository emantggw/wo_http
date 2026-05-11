# Changelog

## 0.1.4

- Fixed disabled logging so explicitly provided default logging interceptors are skipped when `enableLogging` is `false`.
- Added coverage for `WoDataClientFactory` logging interceptor filtering.

## 0.1.3

- Added automatic Content-Type inference for `WoUploadFile` based on common image and audio extensions.
- Integrated inferred `contentType` into `WoDefaultHttpApiClient` multipart uploads.
- Added tests for `WoUploadFile` content-type logic.

## 0.1.2

- Added `retryOnlyGet` to `WoDataClientDefinition` with default `true`.
- Added `retryableStatusCodes` to `WoDataClientDefinition` with default `{0, 408, 429, 500, 502, 503, 504}`.
- Wired factory retry configuration into `WoDefaultRetryHttpInterceptor` for per-client retry policy.

## 0.1.1

- Apply error adapter only for HTTP status codes below `500`.
- Return a generic server message for `5xx` responses.

## 0.1.0

- Initial public release of `wo_http`.
- Added `WoDefaultHttpApiClient` with typed result wrappers.
- Added request/response/error interceptor pipeline.
- Added default retry and auth refresh interceptors.
- Added multi-client factory and lightweight data registry.
- Added multipart upload support and default error adapter.
