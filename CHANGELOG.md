# Changelog

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
