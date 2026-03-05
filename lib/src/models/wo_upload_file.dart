/// File descriptor used for multipart upload requests.
class WoUploadFile {
  /// Raw file bytes; preferred in-memory upload source when provided.
  final List<int>? bytes;

  /// File system path used when [bytes] is not provided.
  final String? path;

  /// File name sent to the server.
  final String filename;

  /// Optional MIME type hint for the upload (metadata only).
  final String? contentType;

  WoUploadFile({
    this.bytes,
    this.path,
    required this.filename,
    this.contentType,
  });
}
