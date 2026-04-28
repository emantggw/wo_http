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
    String? contentType,
  }) : contentType = contentType ?? _inferContentType(filename);

  static String? _inferContentType(String filename) {
    final extension = filename.split('.').last.toLowerCase();
    switch (extension) {
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'mp3':
        return 'audio/mpeg';
      case 'wav':
        return 'audio/wav';
      case 'm4a':
        return 'audio/mp4';
      case 'ogg':
        return 'audio/ogg';
      default:
        return null;
    }
  }
}
