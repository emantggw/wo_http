import '../enums/wo_http_method.dart';
import 'wo_upload_file.dart';

/// Internal normalized request model passed through interceptors.
class WoHttpRequest {
  /// HTTP method (GET/POST/PUT/PATCH/DELETE).
  final WoHttpMethod method;

  /// Fully resolved target URI.
  final Uri uri;

  /// Original relative path used to create [uri].
  final String path;

  /// Request headers to send.
  final Map<String, String> headers;

  /// Body payload for non-multipart requests.
  final dynamic body;

  /// Form fields for multipart uploads.
  final Map<String, String>? formFields;

  /// Form key used for file parts in multipart uploads.
  final String fileFieldName;

  /// Files attached to multipart requests.
  final List<WoUploadFile>? files;

  /// Request-scoped metadata used by interceptors (retry/auth flags, etc.).
  final Map<String, dynamic> metadata;

  const WoHttpRequest({
    required this.method,
    required this.uri,
    required this.path,
    this.headers = const {},
    this.body,
    this.formFields,
    this.fileFieldName = 'files',
    this.files,
    this.metadata = const {},
  });

  WoHttpRequest copyWith({
    WoHttpMethod? method,
    Uri? uri,
    String? path,
    Map<String, String>? headers,
    dynamic body,
    Map<String, String>? formFields,
    String? fileFieldName,
    List<WoUploadFile>? files,
    Map<String, dynamic>? metadata,
  }) {
    return WoHttpRequest(
      method: method ?? this.method,
      uri: uri ?? this.uri,
      path: path ?? this.path,
      headers: headers ?? this.headers,
      body: body ?? this.body,
      formFields: formFields ?? this.formFields,
      fileFieldName: fileFieldName ?? this.fileFieldName,
      files: files ?? this.files,
      metadata: metadata ?? this.metadata,
    );
  }
}
