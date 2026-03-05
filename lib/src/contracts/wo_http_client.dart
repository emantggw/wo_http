import '../../wo_http.dart';

/// High-level HTTP client contract used by feature modules.
abstract class WoHttpClient {
  /// Executes an HTTP GET request.
  Future<WoResult<T>> get<T>(
    /// Relative path appended to the configured base URL.
    String path, {
    /// Extra headers merged with default headers.
    Map<String, String>? headers,

    /// Optional mapper from raw body to type `T`.
    T Function(dynamic raw)? parser,

    /// Optional per-call error normalization adapter.
    WoHttpErrorAdapter? errorAdapter,
  });

  /// Executes an HTTP POST request.
  Future<WoResult<T>> post<T>(
    /// Relative path appended to the configured base URL.
    String path, {
    /// Request body sent as JSON or raw string.
    dynamic data,

    /// Extra headers merged with default headers.
    Map<String, String>? headers,

    /// Optional mapper from raw body to type `T`.
    T Function(dynamic raw)? parser,

    /// Optional per-call error normalization adapter.
    WoHttpErrorAdapter? errorAdapter,
  });

  /// Executes an HTTP PUT request.
  Future<WoResult<T>> put<T>(
    /// Relative path appended to the configured base URL.
    String path, {
    /// Request body sent as JSON or raw string.
    dynamic data,

    /// Extra headers merged with default headers.
    Map<String, String>? headers,

    /// Optional mapper from raw body to type `T`.
    T Function(dynamic raw)? parser,

    /// Optional per-call error normalization adapter.
    WoHttpErrorAdapter? errorAdapter,
  });

  /// Executes an HTTP PATCH request.
  Future<WoResult<T>> patch<T>(
    /// Relative path appended to the configured base URL.
    String path, {
    /// Request body sent as JSON or raw string.
    dynamic data,

    /// Extra headers merged with default headers.
    Map<String, String>? headers,

    /// Optional mapper from raw body to type `T`.
    T Function(dynamic raw)? parser,

    /// Optional per-call error normalization adapter.
    WoHttpErrorAdapter? errorAdapter,
  });

  /// Executes an HTTP DELETE request.
  Future<WoResult<T>> delete<T>(
    /// Relative path appended to the configured base URL.
    String path, {
    /// Optional request body for delete endpoints that accept one.
    dynamic data,

    /// Extra headers merged with default headers.
    Map<String, String>? headers,

    /// Optional mapper from raw body to type `T`.
    T Function(dynamic raw)? parser,

    /// Optional per-call error normalization adapter.
    WoHttpErrorAdapter? errorAdapter,
  });

  /// Executes a multipart upload request.
  Future<WoResult<T>> upload<T>(
    /// Relative path appended to the configured base URL.
    String path, {
    /// Upload request method, defaults to POST.
    WoHttpMethod method = WoHttpMethod.post,

    /// Form key used for each uploaded file part.
    String fileFieldName = 'files',

    /// Additional form fields sent with multipart request.
    Map<String, String>? fields,

    /// Files to upload. Each item can use `bytes` or `path`.
    List<WoUploadFile>? files,

    /// Extra headers merged with default headers.
    Map<String, String>? headers,

    /// Optional mapper from raw body to type `T`.
    T Function(dynamic raw)? parser,

    /// Optional per-call error normalization adapter.
    WoHttpErrorAdapter? errorAdapter,
  });

  /// Releases underlying resources (for example `http.Client`).
  void close();
}
